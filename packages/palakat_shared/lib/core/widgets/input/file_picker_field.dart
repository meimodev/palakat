import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilePickerValue {
  const FilePickerValue({
    required this.name,
    this.path,
    this.bytes,
    this.sizeBytes,
  });

  final String name;
  final String? path;
  final Uint8List? bytes;
  final int? sizeBytes;

  String? get extension {
    final parts = name.split('.');
    if (parts.length < 2) return null;
    final ext = parts.last.trim().toLowerCase();
    return ext.isEmpty ? null : ext;
  }

  bool get isImage {
    final ext = extension;
    if (ext == null) return false;
    return ext == 'jpg' ||
        ext == 'jpeg' ||
        ext == 'png' ||
        ext == 'webp' ||
        ext == 'gif' ||
        ext == 'bmp';
  }
}

class FilePickerField extends StatelessWidget {
  const FilePickerField({
    super.key,
    required this.onChanged,
    this.value,
    this.previewUrl,
    this.isLoadingPreview = false,
    this.label,
    this.helperText,
    this.enabled = true,
    this.allowedExtensions,
    this.pickButtonLabel,
    this.previewHeight = 140,
    this.showImagePreview = true,
    this.canClear = true,
  });

  final FilePickerValue? value;
  final ValueChanged<FilePickerValue?> onChanged;

  final String? previewUrl;
  final bool isLoadingPreview;

  final String? label;
  final String? helperText;
  final String? pickButtonLabel;

  final bool enabled;
  final List<String>? allowedExtensions;
  final double previewHeight;
  final bool showImagePreview;

  final bool canClear;

  Future<void> _pickFile(BuildContext context) async {
    if (!enabled) return;

    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    final file = result?.files.single;
    if (file == null) return;

    onChanged(
      FilePickerValue(
        name: file.name,
        path: file.path,
        bytes: file.bytes,
        sizeBytes: file.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasValue = value != null;
    final hasImageBytes = hasValue && value!.bytes != null && value!.isImage;
    final hasPreviewUrl = previewUrl != null && previewUrl!.trim().isNotEmpty;
    final showPreview =
        showImagePreview && (hasImageBytes || hasPreviewUrl || isLoadingPreview);

    final borderColor = theme.colorScheme.outlineVariant;
    final borderRadius = BorderRadius.circular(12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
            color: theme.colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton.icon(
                onPressed: enabled ? () => _pickFile(context) : null,
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(pickButtonLabel ?? 'Choose file'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  alignment: AlignmentDirectional.centerStart,
                ),
              ),
              if (hasValue) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      value!.isImage
                          ? Icons.image_outlined
                          : Icons.insert_drive_file_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        value!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (canClear) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: enabled ? () => onChanged(null) : null,
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).deleteButtonTooltip,
                        icon: Icon(Icons.close, color: theme.colorScheme.error),
                      ),
                    ],
                  ],
                ),
              ],
              if (showPreview) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    color: theme.colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.all(12),
                    child: isLoadingPreview
                        ? SizedBox(
                            height: previewHeight,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : hasImageBytes
                            ? Image.memory(
                                value!.bytes!,
                                height: previewHeight,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return SizedBox(
                                    height: previewHeight,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image_outlined,
                                            size: 48,
                                            color: theme.colorScheme.error
                                                .withValues(alpha: 0.7),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Failed to load image',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : hasPreviewUrl
                                ? Image.network(
                                    previewUrl!,
                                    height: previewHeight,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        height: previewHeight,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return SizedBox(
                                        height: previewHeight,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.broken_image_outlined,
                                                size: 48,
                                                color: theme.colorScheme.error
                                                    .withValues(alpha: 0.7),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Failed to load image',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: theme.colorScheme.error,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : SizedBox(
                                    height: previewHeight,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 48,
                                        color: theme.colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 8),
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
