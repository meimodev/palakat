import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../data/church_requests_repository.dart';

enum _ChurchRequestDecision { approve, reject }

class ChurchRequestDetailScreen extends ConsumerStatefulWidget {
  const ChurchRequestDetailScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<ChurchRequestDetailScreen> createState() =>
      _ChurchRequestDetailScreenState();
}

class _ChurchRequestDetailScreenState
    extends ConsumerState<ChurchRequestDetailScreen> {
  ChurchRequest? _request;
  bool _isLoadingRequest = false;
  _ChurchRequestDecision? _pendingDecision;

  String _statusLabel(BuildContext context, RequestStatus status) {
    final l10n = context.l10n;
    switch (status) {
      case RequestStatus.todo:
        return l10n.churchRequest_status_onReview;
      case RequestStatus.doing:
        return l10n.churchRequest_status_onProgress;
      case RequestStatus.done:
        return l10n.status_completed;
      case RequestStatus.rejected:
        return l10n.status_rejected;
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return DateFormat('d MMM yyyy, HH:mm').format(value.toLocal());
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoadingRequest = true);
    try {
      final repo = ref.read(churchRequestsRepositoryProvider);
      final req = await repo.fetchChurchRequest(widget.id);
      if (mounted) setState(() => _request = req);
    } finally {
      if (mounted) setState(() => _isLoadingRequest = false);
    }
  }

  Future<void> _approve() async {
    final noteController = TextEditingController();
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.btn_approve),
          content: TextField(
            controller: noteController,
            decoration: InputDecoration(
              labelText: '${l10n.lbl_note} ${l10n.lbl_optional}',
            ),
            minLines: 2,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.btn_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.btn_approve),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _pendingDecision = _ChurchRequestDecision.approve);
    try {
      final repo = ref.read(churchRequestsRepositoryProvider);
      await repo.approve(id: widget.id, decisionNote: noteController.text);
      if (!mounted) return;
      AppSnackbars.showSuccess(context, message: l10n.status_approved);
      await _load();
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, message: e.toString());
      }
    } finally {
      if (mounted) setState(() => _pendingDecision = null);
    }
  }

  Future<void> _reject() async {
    final noteController = TextEditingController();
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.btn_reject),
          content: TextField(
            controller: noteController,
            decoration: InputDecoration(labelText: l10n.lbl_note),
            minLines: 2,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.btn_cancel),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.btn_reject),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _pendingDecision = _ChurchRequestDecision.reject);
    try {
      final repo = ref.read(churchRequestsRepositoryProvider);
      await repo.reject(id: widget.id, decisionNote: noteController.text);
      if (!mounted) return;
      AppSnackbars.showSuccess(context, message: l10n.status_rejected);
      await _load();
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, message: e.toString());
      }
    } finally {
      if (mounted) setState(() => _pendingDecision = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isBusy = _isLoadingRequest || _pendingDecision != null;

    final request = _request;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${l10n.churchRequest_title} #${widget.id}',
              style: theme.textTheme.headlineMedium,
            ),
          ],
        ),
        Gap.h16,
        SurfaceCard(
          title: l10n.churchRequest_title,
          subtitle: l10n.churchRequest_churchInformation,
          trailing: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: isBusy || request == null ? null : _reject,
                child: LoadingActionContent(
                  isLoading: _pendingDecision == _ChurchRequestDecision.reject,
                  loaderSize: 14,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cancel_outlined),
                      Gap.w8,
                      Text(l10n.btn_reject),
                    ],
                  ),
                ),
              ),
              FilledButton(
                onPressed: isBusy || request == null ? null : _approve,
                child: LoadingActionContent(
                  isLoading: _pendingDecision == _ChurchRequestDecision.approve,
                  loaderSize: 14,
                  loaderBaseColor: theme.colorScheme.onPrimary.withValues(
                    alpha: 0.28,
                  ),
                  loaderHighlightColor: theme.colorScheme.onPrimary,
                  loaderBackgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.12,
                  ),
                  loaderBorderColor: theme.colorScheme.onPrimary.withValues(
                    alpha: 0.18,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline),
                      Gap.w8,
                      Text(l10n.btn_approve),
                    ],
                  ),
                ),
              ),
            ],
          ),
          child: request == null && _isLoadingRequest
              ? const _ChurchRequestDetailLoadingBody()
              : request == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Row(
                      label: l10n.tbl_status,
                      value: _statusLabel(context, request.status),
                    ),
                    _Row(label: l10n.lbl_churchName, value: request.churchName),
                    _Row(
                      label: l10n.lbl_churchAddress,
                      value: request.churchAddress,
                    ),
                    _Row(
                      label: l10n.lbl_contactPerson,
                      value: request.contactPerson,
                    ),
                    _Row(label: l10n.lbl_phone, value: request.contactPhone),
                    _Row(
                      label: l10n.lbl_note,
                      value: request.decisionNote ?? '-',
                      multiline: true,
                    ),
                    _Row(
                      label: l10n.lbl_reviewedAt,
                      value: _formatDateTime(request.reviewedAt),
                    ),
                    _Row(
                      label: l10n.lbl_name,
                      value: request.requester?.name ?? '-',
                    ),
                    _Row(
                      label: l10n.lbl_phone,
                      value: request.requester?.phone ?? '-',
                    ),
                  ],
                ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedHeight) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: content,
          );
        }
        return content;
      },
    );
  }
}

class _ChurchRequestDetailLoadingBody extends StatelessWidget {
  const _ChurchRequestDetailLoadingBody();

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      isLoading: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _ChurchRequestDetailPlaceholderRow(),
          _ChurchRequestDetailPlaceholderRow(),
          _ChurchRequestDetailPlaceholderRow(),
          _ChurchRequestDetailPlaceholderRow(),
          _ChurchRequestDetailPlaceholderRow(),
          _ChurchRequestDetailPlaceholderRow(multiline: true),
          _ChurchRequestDetailPlaceholderRow(),
          _ChurchRequestDetailPlaceholderRow(),
          _ChurchRequestDetailPlaceholderRow(),
        ],
      ),
    );
  }
}

class _ChurchRequestDetailPlaceholderRow extends StatelessWidget {
  const _ChurchRequestDetailPlaceholderRow({this.multiline = false});

  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = multiline || constraints.maxWidth < 680;
          final labelWidth = (constraints.maxWidth * 0.28)
              .clamp(120.0, 160.0)
              .toDouble();
          final labelWidget = ShimmerPlaceholders.text(width: 88, height: 12);
          final valueWidget = multiline
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerPlaceholders.text(
                      width: double.infinity,
                      height: 14,
                    ),
                    Gap.h6,
                    ShimmerPlaceholders.text(
                      width: constraints.maxWidth * 0.72,
                      height: 14,
                    ),
                  ],
                )
              : ShimmerPlaceholders.text(
                  width: stacked
                      ? constraints.maxWidth * 0.72
                      : (constraints.maxWidth - labelWidth - 12)
                            .clamp(120.0, constraints.maxWidth)
                            .toDouble(),
                  height: 14,
                );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelWidget, Gap.h6, valueWidget],
            );
          }

          return Row(
            children: [
              SizedBox(width: labelWidth, child: labelWidget),
              Gap.w12,
              Expanded(child: valueWidget),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = multiline || constraints.maxWidth < 680;
          final labelWidth = (constraints.maxWidth * 0.28)
              .clamp(120.0, 160.0)
              .toDouble();
          final labelWidget = Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
          final valueWidget = Text(value, style: theme.textTheme.bodyMedium);

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelWidget, Gap.h4, valueWidget],
            );
          }

          return Row(
            children: [
              SizedBox(width: labelWidth, child: labelWidget),
              Gap.w12,
              Expanded(child: valueWidget),
            ],
          );
        },
      ),
    );
  }
}
