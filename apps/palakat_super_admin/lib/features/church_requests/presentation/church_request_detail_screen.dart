import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../data/church_requests_repository.dart';

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
  bool _loading = false;

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
    setState(() => _loading = true);
    try {
      final repo = ref.read(churchRequestsRepositoryProvider);
      final req = await repo.fetchChurchRequest(widget.id);
      if (mounted) setState(() => _request = req);
    } finally {
      if (mounted) setState(() => _loading = false);
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

    setState(() => _loading = true);
    try {
      final repo = ref.read(churchRequestsRepositoryProvider);
      await repo.approve(id: widget.id, decisionNote: noteController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.status_approved)));
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.btn_reject),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(churchRequestsRepositoryProvider);
      await repo.reject(id: widget.id, decisionNote: noteController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.status_rejected)));
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

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
            if (_loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          title: l10n.churchRequest_title,
          subtitle: l10n.churchRequest_churchInformation,
          trailing: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _loading ? null : _reject,
                icon: const Icon(Icons.cancel_outlined),
                label: Text(l10n.btn_reject),
              ),
              FilledButton.icon(
                onPressed: _loading ? null : _approve,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(l10n.btn_approve),
              ),
            ],
          ),
          child: request == null
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
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
          final stacked = multiline || constraints.maxWidth < 560;
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
              children: [labelWidget, const SizedBox(height: 4), valueWidget],
            );
          }

          return Row(
            children: [
              SizedBox(width: 160, child: labelWidget),
              const SizedBox(width: 12),
              Expanded(child: valueWidget),
            ],
          );
        },
      ),
    );
  }
}
