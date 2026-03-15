import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../data/article_model.dart';
import '../data/articles_repository.dart';

class _ArticleTypeOption {
  const _ArticleTypeOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

const _articleTypeOptions = <_ArticleTypeOption>[
  _ArticleTypeOption(
    value: 'PREACHING_MATERIAL',
    label: 'Preaching material',
    icon: Icons.menu_book_outlined,
  ),
  _ArticleTypeOption(
    value: 'GAME_INSTRUCTION',
    label: 'Game instruction',
    icon: Icons.sports_esports_outlined,
  ),
];

class ArticleEditorScreen extends ConsumerStatefulWidget {
  const ArticleEditorScreen({super.key, this.articleId});

  final int? articleId;

  @override
  ConsumerState<ArticleEditorScreen> createState() =>
      _ArticleEditorScreenState();
}

class _ArticleEditorScreenState extends ConsumerState<ArticleEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _excerptController = TextEditingController();
  final _contentController = TextEditingController();
  String _type = 'PREACHING_MATERIAL';
  String? _coverImageUrl;

  bool _loading = false;
  ArticleModel? _loaded;

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _excerptController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadIfNeeded();
  }

  Future<void> _loadIfNeeded() async {
    final id = widget.articleId;
    if (id == null) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(articlesRepositoryProvider);
      final article = await repo.fetchArticle(id);
      _loaded = article;
      _type = article.type;
      _titleController.text = article.title;
      _slugController.text = article.slug;
      _excerptController.text = article.excerpt ?? '';
      _contentController.text = article.content;
      _coverImageUrl = article.coverImageUrl;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _archive() async {
    final id = widget.articleId;
    if (id == null) return;
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.dlg_confirmAction_title),
          content: Text(l10n.dlg_articleArchive_content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.btn_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.btn_archive),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(articlesRepositoryProvider);
      await repo.archive(id);
      if (mounted) {
        AppSnackbars.showSuccess(context, message: l10n.msg_archived);
        context.go('/articles');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveDraft() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(articlesRepositoryProvider);
      final title = _titleController.text.trim();
      final content = _contentController.text;

      ArticleModel saved;
      if (widget.articleId == null) {
        saved = await repo.create(
          type: _type,
          title: title,
          slug: _slugController.text.trim().isEmpty
              ? null
              : _slugController.text.trim(),
          excerpt: _excerptController.text.trim().isEmpty
              ? null
              : _excerptController.text.trim(),
          content: content,
          coverImageUrl: _coverImageUrl,
        );
        if (!mounted) return;
        context.go('/articles/${saved.id}');
        return;
      } else {
        saved = await repo.update(
          id: widget.articleId!,
          type: _type,
          title: title,
          slug: _slugController.text,
          excerpt: _excerptController.text.isEmpty
              ? null
              : _excerptController.text,
          content: content,
          coverImageUrl: _coverImageUrl,
        );
      }

      _loaded = saved;
      if (mounted) {
        AppSnackbars.showSuccess(context, message: context.l10n.msg_saved);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbars.showError(context, message: e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _publish() async {
    if (widget.articleId == null) {
      await _saveDraft();
      return;
    }
    final id = widget.articleId ?? _loaded?.id;
    if (id == null) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(articlesRepositoryProvider);
      await repo.publish(id);
      await _loadIfNeeded();
      if (mounted) {
        AppSnackbars.showSuccess(context, message: context.l10n.msg_published);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _unpublish() async {
    final id = widget.articleId;
    if (id == null) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(articlesRepositoryProvider);
      await repo.unpublish(id);
      await _loadIfNeeded();
      if (mounted) {
        AppSnackbars.showSuccess(context, message: context.l10n.msg_unpublished);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _uploadCover() async {
    final id = widget.articleId ?? _loaded?.id;
    if (id == null) {
      AppSnackbars.showSuccess(context, message: context.l10n.dlg_articleCoverUploadRequiresDraft_content,);
      return;
    }

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    final file = picked?.files.single;
    if (file == null || file.bytes == null) return;
    final bytes = file.bytes!;

    String? inferContentType(String? ext) {
      final e = (ext ?? '').toLowerCase().trim();
      if (e == 'jpg' || e == 'jpeg') return 'image/jpeg';
      if (e == 'png') return 'image/png';
      if (e == 'webp') return 'image/webp';
      return null;
    }

    final ext = (file.extension?.trim().isNotEmpty == true)
        ? file.extension!.trim()
        : 'png';
    final filename = file.name.trim().isNotEmpty ? file.name : 'cover.$ext';

    final progress = ref.read(fileTransferProgressControllerProvider.notifier);
    final progressId = progress.start(
      direction: FileTransferDirection.upload,
      totalBytes: bytes.length,
      label: filename,
    );

    setState(() => _loading = true);
    try {
      final repo = ref.read(articlesRepositoryProvider);
      final updated = await repo.uploadCover(
        id: id,
        bytes: bytes,
        filename: filename,
        contentType: inferContentType(ext),
        onProgress: (sent, total) {
          progress.update(
            progressId,
            transferredBytes: sent,
            totalBytes: total,
          );
        },
      );
      progress.complete(progressId);
      _loaded = updated;
      _coverImageUrl = updated.coverImageUrl;

      if (mounted) {
        AppSnackbars.showSuccess(context, message: context.l10n.msg_coverUploaded);
        setState(() {});
      }
    } catch (e) {
      progress.fail(progressId, errorMessage: e.toString());
      if (mounted) {
        AppSnackbars.showError(context, message: e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.articleId == null;
    final status = _loaded?.status;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final pageTitle = isNew
        ? '${l10n.btn_add} ${l10n.article_titleFallback}'
        : l10n.article_titleFallback;

    String articleTypeLabel(String value) {
      switch (value) {
        case 'PREACHING_MATERIAL':
          return l10n.articleType_preachingMaterial;
        case 'GAME_INSTRUCTION':
          return l10n.articleType_gameInstruction;
        default:
          return value;
      }
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final actions = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!isNew)
                  FilledButton.tonal(
                    onPressed: _loading ? null : _archive,
                    child: Text(l10n.btn_archive),
                  ),
                if (!isNew)
                  OutlinedButton(
                    onPressed: _loading ? null : _unpublish,
                    child: Text(l10n.btn_unpublish),
                  ),
                FilledButton(
                  onPressed: _loading ? null : _publish,
                  child: Text(l10n.btn_publish),
                ),
                FilledButton.tonal(
                  onPressed: _loading ? null : _saveDraft,
                  child: Text(l10n.btn_save),
                ),
              ],
            );

            if (constraints.maxWidth < 760) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(pageTitle, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  actions,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(pageTitle, style: theme.textTheme.headlineMedium),
                ),
                const SizedBox(width: 16),
                Flexible(child: actions),
              ],
            );
          },
        ),
        if (status != null) ...[
          const SizedBox(height: 8),
          Text('${l10n.tbl_status}: $status'),
        ],
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final editorCard = SurfaceCard(
              title: l10n.articles_title,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final typeSelector = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.lbl_type,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _articleTypeOptions.map((opt) {
                                final selected = _type == opt.value;
                                return ChoiceChip(
                                  avatar: Icon(
                                    opt.icon,
                                    size: 18,
                                    color: selected
                                        ? theme.colorScheme.onSecondaryContainer
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  label: Text(articleTypeLabel(opt.value)),
                                  selected: selected,
                                  onSelected: _loading
                                      ? null
                                      : (v) {
                                          if (!v) return;
                                          setState(() => _type = opt.value);
                                        },
                                );
                              }).toList(),
                            ),
                          ],
                        );

                        final uploadButton = OutlinedButton.icon(
                          onPressed: _loading ? null : _uploadCover,
                          icon: const Icon(Icons.upload),
                          label: Text(l10n.btn_uploadCover),
                        );

                        if (constraints.maxWidth < 720) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              typeSelector,
                              const SizedBox(height: 12),
                              uploadButton,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: typeSelector),
                            const SizedBox(width: 12),
                            uploadButton,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: l10n.lbl_title),
                      enabled: !_loading,
                      textInputAction: TextInputAction.next,
                      validator: (v) => Validators.required(
                        l10n.validation_requiredField,
                      ).asFormFieldValidator(v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _slugController,
                      decoration: const InputDecoration(labelText: 'Slug'),
                      enabled: !_loading,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _excerptController,
                      decoration: const InputDecoration(labelText: 'Excerpt'),
                      enabled: !_loading,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content (Markdown)',
                      ),
                      minLines: 10,
                      maxLines: 20,
                      enabled: !_loading,
                      onChanged: (_) => setState(() {}),
                      validator: (v) => Validators.required(
                        l10n.validation_requiredField,
                      ).asFormFieldValidator(v),
                    ),
                    const SizedBox(height: 12),
                    if (_coverImageUrl != null &&
                        _coverImageUrl!.isNotEmpty) ...[
                      Text(l10n.lbl_coverUrl(_coverImageUrl!)),
                    ],
                  ],
                ),
              ),
            );
            final previewCard = SurfaceCard(
              title: 'Preview',
              child: MarkdownBody(data: _contentController.text),
            );

            if (constraints.maxWidth < 1100) {
              return Column(
                children: [editorCard, const SizedBox(height: 16), previewCard],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: editorCard),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: previewCard),
              ],
            );
          },
        ),
        if (_loading) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
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
