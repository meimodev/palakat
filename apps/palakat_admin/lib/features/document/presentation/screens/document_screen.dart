import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/document/presentation/state/document_controller.dart';
import 'package:palakat_admin/features/document/presentation/state/document_screen_state.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';

class DocumentScreen extends ConsumerWidget {
  const DocumentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final DocumentScreenState state = ref.watch(documentControllerProvider);
    final DocumentController controller = ref.watch(
      documentControllerProvider.notifier,
    );
    final settingsAsync = ref.watch(documentSettingsProvider);

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Document Settings', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Manage document identity numbers and view recent approvals.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Document Identity Number card
            settingsAsync.when(
              data: (settings) => SurfaceCard(
                title: 'Document Identity Number',
                subtitle: 'Current template used for new documents.',
                trailing: FilledButton.icon(
                  onPressed: () => _openIdentityDrawer(
                    context,
                    ref,
                    settings?.identityNumberTemplate ?? '',
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Template:',
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
                title: 'Document Identity Number',
                subtitle: 'Loading...',
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
                title: 'Document Identity Number',
                subtitle: 'Failed to load settings',
                child: _buildErrorWidget(
                  theme: theme,
                  error: error,
                  onRetry: () => ref.invalidate(documentSettingsProvider),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Document Directory Section
            SurfaceCard(
              title: 'Document Directory',
              subtitle: 'A record of all approved church documents.',
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
                    columns: _buildTableColumns(),
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
  static List<AppTableColumn<Document>> _buildTableColumns() {
    return [
      AppTableColumn<Document>(
        title: 'Document Name',
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
        title: 'Account Number',
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
        title: 'Created Date',
        flex: 2,
        cellBuilder: (ctx, document) {
          final theme = Theme.of(ctx);
          return Text(
            document.createdAt?.toCustomFormat('yyyy-MM-dd HH:mm') ?? 'N/A',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    ];
  }

  Widget _buildErrorWidget({
    required ThemeData theme,
    required Object error,
    required VoidCallback onRetry,
  }) {
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
            label: const Text('Retry'),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Template updated successfully')),
            );
          }
        },
        onClose: () {
          DrawerUtils.closeDrawer(context);
        },
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
        _errorMessage = 'Template cannot be empty';
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
    return SideDrawer(
      title: 'Edit Document Identity Number',
      subtitle: 'Update the template used for new documents',
      onClose: widget.onClose,
      isLoading: _isLoading,
      loadingMessage: 'Saving template...',
      errorMessage: _errorMessage,
      onRetry: _errorMessage != null ? _handleRetry : null,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Template',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'e.g., DOC-2024-001',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
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
                    'Changing the identity number template may cause certain numbers to be skipped.',
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
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
