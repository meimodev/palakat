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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Approve request'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'Decision note (optional)',
            ),
            minLines: 2,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Approve'),
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
      ).showSnackBar(const SnackBar(content: Text('Approved')));
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject request'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'Decision note (required)',
            ),
            minLines: 2,
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reject'),
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
      ).showSnackBar(const SnackBar(content: Text('Rejected')));
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

    final request = _request;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Church Request #${widget.id}',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SurfaceCard(
          title: 'Request details',
          subtitle: 'Review submission and decide approval status.',
          trailing: Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _loading ? null : _reject,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Reject'),
              ),
              FilledButton.icon(
                onPressed: _loading ? null : _approve,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Approve'),
              ),
            ],
          ),
          child: request == null
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Loading...'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Row(label: 'Status', value: request.status.name),
                    _Row(label: 'Church Name', value: request.churchName),
                    _Row(label: 'Address', value: request.churchAddress),
                    _Row(label: 'Contact Person', value: request.contactPerson),
                    _Row(label: 'Contact Phone', value: request.contactPhone),
                    _Row(
                      label: 'Decision Note',
                      value: request.decisionNote ?? '-',
                      multiline: true,
                    ),
                    _Row(
                      label: 'Reviewed At',
                      value: request.reviewedAt?.toIso8601String() ?? '-',
                    ),
                    _Row(
                      label: 'Requester',
                      value: request.requester?.name ?? '-',
                    ),
                    _Row(
                      label: 'Requester Phone',
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
          return SingleChildScrollView(child: content);
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
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
