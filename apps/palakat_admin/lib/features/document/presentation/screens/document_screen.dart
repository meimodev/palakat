import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/document/presentation/state/document_controller.dart';
import 'package:palakat_admin/features/document/presentation/state/document_screen_state.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

final churchLetterheadProvider = FutureProvider<ChurchLetterhead?>((ref) async {
  final repo = ref.read(churchLetterheadRepositoryProvider);
  final result = await repo.fetchMyLetterhead();
  return result.when(
    onSuccess: (letterhead) => letterhead,
    onFailure: (failure) {
      throw AppError.serverError(failure.message, statusCode: failure.code);
    },
  );
});

class DocumentScreen extends ConsumerWidget {
  const DocumentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final DocumentScreenState state = ref.watch(documentControllerProvider);
    final DocumentController controller = ref.watch(
      documentControllerProvider.notifier,
    );
    final settingsAsync = ref.watch(documentSettingsProvider);
    final letterheadAsync = ref.watch(churchLetterheadProvider);

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.admin_documentSettings_title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.admin_documentSettings_subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Document Identity Number card
            settingsAsync.when(
              data: (settings) => SurfaceCard(
                title: l10n.admin_documentIdentityNumber_title,
                subtitle: l10n.admin_documentIdentityNumber_subtitle,
                trailing: FilledButton.icon(
                  onPressed: () => _openIdentityDrawer(
                    context,
                    ref,
                    settings?.identityNumberTemplate ?? '',
                  ),
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.btn_edit),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${l10n.lbl_template}:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          settings?.identityNumberTemplate ?? '',
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => SurfaceCard(
                title: l10n.admin_documentIdentityNumber_title,
                subtitle: l10n.loading_data,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: LoadingShimmer(
                    child: ShimmerPlaceholders.text(
                      width: double.infinity,
                      height: 40,
                    ),
                  ),
                ),
              ),
              error: (error, stack) => SurfaceCard(
                title: l10n.admin_documentIdentityNumber_title,
                subtitle: l10n.err_loadFailed,
                child: _buildErrorWidget(
                  context: context,
                  theme: theme,
                  error: error,
                  onRetry: () => ref.invalidate(documentSettingsProvider),
                ),
              ),
            ),

            const SizedBox(height: 16),

            letterheadAsync.when(
              data: (letterhead) => _LetterheadCard(
                letterhead: letterhead,
                onEdit: () => _openLetterheadDrawer(context, ref, letterhead),
              ),
              loading: () => SurfaceCard(
                title: 'Letterhead',
                subtitle: l10n.loading_data,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: LoadingShimmer(
                    child: ShimmerPlaceholders.text(
                      width: double.infinity,
                      height: 40,
                    ),
                  ),
                ),
              ),
              error: (error, stack) => SurfaceCard(
                title: 'Letterhead',
                subtitle: l10n.err_loadFailed,
                child: _buildErrorWidget(
                  context: context,
                  theme: theme,
                  error: error,
                  onRetry: () => ref.invalidate(churchLetterheadProvider),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Document Directory Section
            SurfaceCard(
              title: l10n.admin_documentDirectory_title,
              subtitle: l10n.admin_documentDirectory_subtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTable<Document>(
                    loading: state.documents.isLoading,
                    data: state.documents.value?.data ?? [],
                    errorText: state.documents.hasError
                        ? state.documents.error.toString()
                        : null,
                    onRetry: () => controller.refresh(),
                    columns: _buildTableColumns(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the table column configuration for the documents table
  static List<AppTableColumn<Document>> _buildTableColumns(
    BuildContext context,
    WidgetRef ref,
  ) {
    final l10n = context.l10n;
    return [
      AppTableColumn<Document>(
        title: l10n.tbl_documentName,
        flex: 3,
        cellBuilder: (ctx, document) {
          final theme = Theme.of(ctx);
          return Text(
            document.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<Document>(
        title: l10n.tbl_accountNumber,
        flex: 2,
        cellBuilder: (ctx, document) {
          final theme = Theme.of(ctx);
          return Text(
            document.accountNumber,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<Document>(
        title: l10n.tbl_createdDate,
        flex: 2,
        cellBuilder: (ctx, document) {
          final theme = Theme.of(ctx);
          return Text(
            document.createdAt?.toCustomFormat('yyyy-MM-dd HH:mm') ??
                l10n.lbl_na,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
      AppTableColumn<Document>(
        title: l10n.tbl_file,
        flex: 2,
        cellBuilder: (ctx, document) {
          final theme = Theme.of(ctx);
          final file = document.file;
          if (file == null) {
            return Text(ctx.l10n.lbl_na, style: theme.textTheme.bodySmall);
          }
          final fileName =
              file.originalName ??
              (file.path?.split('/').last ?? ctx.l10n.lbl_na);
          return Text(
            fileName,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
      AppTableColumn<Document>(
        title: '',
        flex: 1,
        cellBuilder: (ctx, document) {
          final theme = Theme.of(ctx);
          final l10n = ctx.l10n;
          final fileId = document.fileId;
          if (fileId == null) {
            return const SizedBox.shrink();
          }
          return IconButton(
            onPressed: () async {
              final fileRepo = ref.read(fileManagerRepositoryProvider);
              final result = await fileRepo.resolveDownloadUrl(fileId: fileId);
              if (!ctx.mounted) return;

              String? resolved;
              result.when(
                onSuccess: (url) {
                  resolved = url;
                },
                onFailure: (failure) {
                  AppSnackbars.showError(
                    ctx,
                    title: l10n.msg_invalidUrl,
                    message: failure.message,
                  );
                },
              );
              if (resolved == null) return;

              final uri = Uri.tryParse(resolved!);
              if (uri == null) {
                AppSnackbars.showError(
                  ctx,
                  title: l10n.msg_invalidUrl,
                  message: l10n.msg_cannotOpenReportFile,
                );
                return;
              }

              AppSnackbars.showSuccess(
                ctx,
                title: l10n.msg_opening,
                message: l10n.msg_openingReport(document.name),
              );
              try {
                await launchUrl(uri);
              } catch (_) {
                // ignore
              }
            },
            icon: const Icon(Icons.download),
            color: theme.colorScheme.primary,
            tooltip: l10n.tooltip_downloadReport,
          );
        },
      ),
    ];
  }

  Widget _buildErrorWidget({
    required BuildContext context,
    required ThemeData theme,
    required Object error,
    required VoidCallback onRetry,
  }) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            error.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.btn_retry),
          ),
        ],
      ),
    );
  }

  void _openIdentityDrawer(
    BuildContext context,
    WidgetRef ref,
    String currentTemplate,
  ) {
    final l10n = context.l10n;
    DrawerUtils.showDrawer(
      context: context,
      drawer: _IdentityNumberEditDrawer(
        currentTemplate: currentTemplate,
        onSave: (val) async {
          final repo = ref.read(documentRepositoryProvider);
          await repo.updateIdentityTemplate(val);
          // Refresh provider and show snackbar after successful save
          ref.invalidate(documentSettingsProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.msg_templateUpdated)));
          }
        },
        onClose: () {
          DrawerUtils.closeDrawer(context);
        },
      ),
    );
  }

  void _openLetterheadDrawer(
    BuildContext context,
    WidgetRef ref,
    ChurchLetterhead? letterhead,
  ) {
    DrawerUtils.showDrawer(
      context: context,
      drawer: _LetterheadEditDrawer(
        letterhead: letterhead,
        onClose: () => DrawerUtils.closeDrawer(context),
        onSaved: () {
          ref.invalidate(churchLetterheadProvider);
        },
      ),
    );
  }
}

class _LetterheadEditDrawer extends ConsumerStatefulWidget {
  const _LetterheadEditDrawer({
    required this.letterhead,
    required this.onClose,
    required this.onSaved,
  });

  final ChurchLetterhead? letterhead;
  final VoidCallback onClose;
  final VoidCallback onSaved;

  @override
  ConsumerState<_LetterheadEditDrawer> createState() =>
      _LetterheadEditDrawerState();
}

class _LetterheadEditDrawerState extends ConsumerState<_LetterheadEditDrawer> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late final TextEditingController _line3Controller;

  Uint8List? _pickedLogoBytes;
  String? _pickedLogoFilename;

  String? _existingLogoUrl;
  bool _isLoadingLogo = false;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isFormValid = false;
  bool _didInitialize = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.letterhead?.title);
    _line1Controller = TextEditingController(text: widget.letterhead?.line1);
    _line2Controller = TextEditingController(text: widget.letterhead?.line2);
    _line3Controller = TextEditingController(text: widget.letterhead?.line3);
    _titleController.addListener(_handleFormChanged);
    _line1Controller.addListener(_handleFormChanged);
    _line2Controller.addListener(_handleFormChanged);
    _line3Controller.addListener(_handleFormChanged);
    // Schedule logo loading after the frame to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadExistingLogo());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialize) {
      _didInitialize = true;
      _handleFormChanged();
    }
  }

  void _handleFormChanged() {
    final l10n = context.l10n;

    bool isValidField(String value, {required bool requiredField}) {
      final v = value.trim();
      if (requiredField && v.isEmpty) return false;
      if (v.length > 200) return false;
      return true;
    }

    final nextValid =
        isValidField(_titleController.text, requiredField: true) &&
        isValidField(_line1Controller.text, requiredField: true) &&
        isValidField(_line2Controller.text, requiredField: false) &&
        isValidField(_line3Controller.text, requiredField: false);

    if (_isFormValid != nextValid) {
      setState(() => _isFormValid = nextValid);
    }

    if (_errorMessage == l10n.validation_required && nextValid) {
      setState(() => _errorMessage = null);
    }
  }

  String? _validateLine(String? value, {required bool requiredField}) {
    final l10n = context.l10n;
    final v = (value ?? '').trim();
    if (requiredField && v.isEmpty) {
      return l10n.validation_required;
    }
    if (v.length > 200) {
      return l10n.validation_maxLength(200);
    }
    return null;
  }

  Future<void> _loadExistingLogo() async {
    final fileId =
        widget.letterhead?.logoFileId ?? widget.letterhead?.logoFile?.id;
    if (fileId == null) return;

    setState(() => _isLoadingLogo = true);

    try {
      final fileRepo = ref.read(fileManagerRepositoryProvider);
      final result = await fileRepo.resolveDownloadUrl(fileId: fileId);

      if (!mounted) return;

      result.when(
        onSuccess: (url) {
          setState(() {
            _existingLogoUrl = url;
            _isLoadingLogo = false;
          });
        },
        onFailure: (_) {
          setState(() => _isLoadingLogo = false);
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingLogo = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_handleFormChanged);
    _line1Controller.removeListener(_handleFormChanged);
    _line2Controller.removeListener(_handleFormChanged);
    _line3Controller.removeListener(_handleFormChanged);
    _titleController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _line3Controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() => _isFormValid = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(churchLetterheadRepositoryProvider);
      final result = await repo.updateMyLetterhead(
        data: {
          'title': _titleController.text.trim(),
          'line1': _line1Controller.text.trim(),
          'line2': _line2Controller.text.trim(),
          'line3': _line3Controller.text.trim(),
        },
      );

      result.when(
        onSuccess: (_) {},
        onFailure: (failure) => throw Exception(failure.message),
      );

      final pickedBytes = _pickedLogoBytes;
      final pickedFilename = _pickedLogoFilename;
      if (pickedBytes != null && pickedFilename != null) {
        final uploadRes = await repo.uploadLogo(
          bytes: pickedBytes,
          filename: pickedFilename,
        );

        uploadRes.when(
          onSuccess: (_) {},
          onFailure: (failure) => throw Exception(failure.message),
        );
      }

      widget.onSaved();
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onClose();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pickedLogoBytes = _pickedLogoBytes;
    final pickedLogoFilename = _pickedLogoFilename;
    final existingLogoFilename = widget.letterhead?.logoFile?.originalName;
    final effectiveLogoFilename = pickedLogoFilename ?? existingLogoFilename;
    // Use URL for existing logo, null if we have picked bytes
    final previewUrl = pickedLogoBytes == null ? _existingLogoUrl : null;

    return SideDrawer(
      title: 'Letterhead',
      subtitle: 'Edit your church letterhead information',
      onClose: widget.onClose,
      isLoading: _isLoading,
      loadingMessage: l10n.loading_saving,
      errorMessage: _errorMessage,
      onRetry: _errorMessage != null
          ? () {
              setState(() => _errorMessage = null);
            }
          : null,
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _titleController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: l10n.lbl_title,
                      border: const OutlineInputBorder(),
                    ),
                    maxLength: 200,
                    validator: (v) => _validateLine(v, requiredField: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _line1Controller,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Line 1',
                border: OutlineInputBorder(),
              ),
              maxLength: 200,
              validator: (v) => _validateLine(v, requiredField: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _line2Controller,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Line 2',
                border: OutlineInputBorder(),
              ),
              maxLength: 200,
              validator: (v) => _validateLine(v, requiredField: false),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _line3Controller,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                labelText: 'Line 3',
                border: OutlineInputBorder(),
              ),
              maxLength: 200,
              validator: (v) => _validateLine(v, requiredField: false),
            ),
            const SizedBox(height: 16),
            FilePickerField(
              enabled: !_isLoading,
              label: 'Logo',
              pickButtonLabel: 'Choose Logo',
              helperText: 'JPG, JPEG, PNG',
              allowedExtensions: const ['jpg', 'jpeg', 'png'],
              previewUrl: previewUrl,
              isLoadingPreview: _isLoadingLogo,
              canClear: pickedLogoFilename != null,
              value: (effectiveLogoFilename != null || pickedLogoBytes != null)
                  ? FilePickerValue(
                      name: effectiveLogoFilename ?? 'logo',
                      bytes: pickedLogoBytes,
                    )
                  : null,
              onChanged: (picked) {
                setState(() {
                  _pickedLogoFilename = picked?.name;
                  _pickedLogoBytes = picked?.bytes;
                });
              },
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            onPressed: _isLoading || !_isFormValid ? null : _handleSave,
            child: Text(l10n.btn_saveChanges),
          ),
        ],
      ),
    );
  }
}

class _IdentityNumberEditDrawer extends StatefulWidget {
  final String currentTemplate;
  final Future<void> Function(String) onSave;
  final VoidCallback onClose;

  const _IdentityNumberEditDrawer({
    required this.currentTemplate,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<_IdentityNumberEditDrawer> createState() =>
      _IdentityNumberEditDrawerState();
}

class _IdentityNumberEditDrawerState extends State<_IdentityNumberEditDrawer> {
  late final TextEditingController _controller;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTemplate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final newTemplate = _controller.text.trim();
    if (newTemplate.isEmpty) {
      setState(() {
        _errorMessage = context.l10n.validation_required;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onSave(newTemplate);
      // On success, schedule drawer close after any triggered rebuilds complete
      // This avoids Navigator !_debugLocked assertion when onSave invalidates providers
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onClose();
        }
      });
    } catch (e) {
      // On error, show inline error and keep drawer open
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _handleRetry() {
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return SideDrawer(
      title: l10n.drawer_editDocumentId_title,
      subtitle: l10n.drawer_editDocumentId_subtitle,
      onClose: widget.onClose,
      isLoading: _isLoading,
      loadingMessage: l10n.loading_saving,
      errorMessage: _errorMessage,
      onRetry: _errorMessage != null ? _handleRetry : null,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lbl_template,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: l10n.hint_documentIdExample,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.msg_documentTemplateWarning,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            onPressed: _handleSave,
            child: Text(l10n.btn_saveChanges),
          ),
        ],
      ),
    );
  }
}

class _LetterheadCard extends ConsumerWidget {
  const _LetterheadCard({required this.letterhead, required this.onEdit});

  final ChurchLetterhead? letterhead;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final fileId = letterhead?.logoFileId ?? letterhead?.logoFile?.id;

    return SurfaceCard(
      title: 'Letterhead',
      subtitle: 'Configure your church letterhead for reports',
      trailing: FilledButton.icon(
        onPressed: onEdit,
        icon: const Icon(Icons.edit),
        label: Text(l10n.btn_edit),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo preview
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: fileId != null
                    ? CachedFileImage(
                        fileId: fileId,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        errorWidget: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 32,
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 32,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (letterhead?.title ?? '').isEmpty
                        ? l10n.lbl_na
                        : (letterhead?.title ?? ''),
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      letterhead?.line1,
                      letterhead?.line2,
                      letterhead?.line3,
                    ].where((e) => (e ?? '').trim().isNotEmpty).join(' • '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
