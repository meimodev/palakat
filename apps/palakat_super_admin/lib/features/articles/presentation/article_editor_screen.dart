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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archive this article?'),
          content: const Text(
            'This will hide the article from the public app. You can still edit it later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archive'),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Archived')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved')));
      }
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Published')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unpublished')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _uploadCover() async {
    final id = widget.articleId ?? _loaded?.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save draft first to upload cover.')),
      );
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

    setState(() => _loading = true);
    try {
      final repo = ref.read(articlesRepositoryProvider);
      final updated = await repo.uploadCover(
        id: id,
        bytes: bytes,
        filename: filename,
        contentType: inferContentType(ext),
      );
      _loaded = updated;
      _coverImageUrl = updated.coverImageUrl;

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cover uploaded')));
        setState(() {});
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

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              isNew ? 'New Article' : 'Edit Article',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Spacer(),
            if (!isNew) ...[
              OutlinedButton(
                onPressed: _loading ? null : _archive,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Archive'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _loading ? null : _unpublish,
                child: const Text('Unpublish'),
              ),
              const SizedBox(width: 8),
            ],
            FilledButton(
              onPressed: _loading ? null : _publish,
              child: const Text('Publish'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _loading ? null : _saveDraft,
              child: const Text('Save'),
            ),
          ],
        ),
        if (status != null) ...[
          const SizedBox(height: 8),
          Text('Status: $status'),
        ],
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Type',
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
                                  label: Text(opt.label),
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
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _loading ? null : _uploadCover,
                        icon: const Icon(Icons.upload),
                        label: const Text('Upload cover'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    enabled: !_loading,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.required(
                      'Title is required',
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
                      'Content is required',
                    ).asFormFieldValidator(v),
                  ),
                  const SizedBox(height: 12),
                  if (_coverImageUrl != null && _coverImageUrl!.isNotEmpty) ...[
                    Text('Cover URL: $_coverImageUrl'),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Preview', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                MarkdownBody(data: _contentController.text),
              ],
            ),
          ),
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
          return SingleChildScrollView(child: content);
        }
        return content;
      },
    );
  }
}
