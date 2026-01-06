import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/file_transfer_progress_service.dart';

class FileTransferProgressBanner extends ConsumerStatefulWidget {
  const FileTransferProgressBanner({super.key, required this.child});

  final Widget? child;

  @override
  ConsumerState<FileTransferProgressBanner> createState() =>
      _FileTransferProgressBannerState();
}

class _FileTransferProgressBannerState
    extends ConsumerState<FileTransferProgressBanner> {
  bool _expanded = false;

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
    double v = bytes.toDouble();
    int unit = 0;
    while (v >= 1024 && unit < units.length - 1) {
      v /= 1024;
      unit++;
    }
    final text = v >= 10 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return '$text ${units[unit]}';
  }

  String _bytesText(FileTransferProgress t) {
    final sent = _formatBytes(t.transferredBytes);
    if (t.totalBytes <= 0) return sent;
    return '$sent / ${_formatBytes(t.totalBytes)}';
  }

  String _titleFor(FileTransferProgress t) {
    final base = t.direction == FileTransferDirection.upload
        ? 'Upload'
        : 'Download';
    return switch (t.status) {
      FileTransferStatus.inProgress => '${base}ing',
      FileTransferStatus.completed => '$base completed',
      FileTransferStatus.failed => '$base failed',
    };
  }

  ({Color background, Color foreground, Color accent}) _colorsFor(
    ThemeData theme,
    FileTransferProgress t,
  ) {
    final cs = theme.colorScheme;
    return switch (t.status) {
      FileTransferStatus.inProgress => (
        background: cs.surface,
        foreground: cs.onSurface,
        accent: cs.primary,
      ),
      FileTransferStatus.completed => (
        background: cs.tertiaryContainer,
        foreground: cs.onTertiaryContainer,
        accent: cs.tertiary,
      ),
      FileTransferStatus.failed => (
        background: cs.errorContainer,
        foreground: cs.onErrorContainer,
        accent: cs.error,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final transfers = ref.watch(fileTransferProgressControllerProvider);
    final rawChild = widget.child ?? const SizedBox.shrink();
    if (transfers.isEmpty) return rawChild;

    final ordered = transfers.reversed.toList(growable: false);
    final visible = _expanded
        ? ordered
        : ordered.take(1).toList(growable: false);
    final extraCount = ordered.length - visible.length;

    final theme = Theme.of(context);

    final controller = ref.read(
      fileTransferProgressControllerProvider.notifier,
    );

    return Stack(
      children: [
        rawChild,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Semantics(
              container: true,
              label: 'File transfer progress',
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final t in visible) ...[
                      _TransferTile(
                        transfer: t,
                        bytesText: _bytesText(t),
                        title: _titleFor(t),
                        theme: theme,
                        colors: _colorsFor(theme, t),
                        onDismiss: () => controller.clear(t.id),
                      ),
                    ],
                    if (extraCount > 0)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.dividerColor),
                          ),
                          color: theme.colorScheme.surface,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => setState(() => _expanded = true),
                            child: Text('Show $extraCount more'),
                          ),
                        ),
                      )
                    else if (_expanded && ordered.length > 1)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.dividerColor),
                          ),
                          color: theme.colorScheme.surface,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => setState(() => _expanded = false),
                            child: const Text('Hide'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TransferTile extends StatelessWidget {
  const _TransferTile({
    required this.transfer,
    required this.bytesText,
    required this.title,
    required this.theme,
    required this.colors,
    required this.onDismiss,
  });

  final FileTransferProgress transfer;
  final String bytesText;
  final String title;
  final ThemeData theme;
  final ({Color background, Color foreground, Color accent}) colors;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final label = transfer.label;
    final name = (label == null || label.trim().isEmpty)
        ? title
        : '$title • $label';

    final fraction = transfer.fraction;
    final progressText = fraction == null
        ? bytesText
        : '${(fraction * 100).toStringAsFixed(0)}%';

    final icon = transfer.direction == FileTransferDirection.upload
        ? Icons.upload
        : Icons.download;

    final progressValue = switch (transfer.status) {
      FileTransferStatus.inProgress => fraction,
      FileTransferStatus.completed => 1.0,
      FileTransferStatus.failed => fraction,
    };

    final error = transfer.status == FileTransferStatus.failed
        ? (transfer.errorMessage ?? 'Failed')
        : null;

    return Material(
      color: colors.background,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colors.foreground),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  progressText,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.foreground,
                  ),
                ),
                const SizedBox(width: 6),
                Builder(
                  builder: (context) {
                    final hasOverlay = Overlay.maybeOf(context) != null;
                    return IconButton(
                      onPressed: onDismiss,
                      tooltip: hasOverlay ? 'Dismiss' : null,
                      iconSize: 18,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.close, color: colors.foreground),
                    );
                  },
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(
                error,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressValue,
              color: colors.accent,
              backgroundColor: colors.foreground.withValues(alpha: 0.15),
            ),
          ],
        ),
      ),
    );
  }
}
