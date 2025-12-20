import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../data/admin_song_model.dart';
import '../data/admin_song_part_model.dart';
import '../data/songs_repository.dart';

class SongEditorScreen extends ConsumerStatefulWidget {
  const SongEditorScreen({super.key, this.songId});

  final int? songId;

  @override
  ConsumerState<SongEditorScreen> createState() => _SongEditorScreenState();
}

class _SongEditorScreenState extends ConsumerState<SongEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _indexController = TextEditingController();
  final _linkController = TextEditingController();

  String _book = 'KJ';
  bool _loading = false;
  AdminSongModel? _loaded;

  @override
  void initState() {
    super.initState();
    _loadIfNeeded();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _indexController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _loadIfNeeded() async {
    final id = widget.songId;
    if (id == null) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(songsRepositoryProvider);
      final song = await repo.fetchSong(id);
      _loaded = song;
      _titleController.text = song.title;
      _indexController.text = song.index.toString();
      _linkController.text = song.link;
      _book = song.book;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(songsRepositoryProvider);
      final title = _titleController.text.trim();
      final index = int.parse(_indexController.text.trim());
      final link = _linkController.text.trim();

      AdminSongModel saved;
      if (widget.songId == null) {
        saved = await repo.createSong(
          title: title,
          index: index,
          book: _book,
          link: link,
        );

        if (!mounted) return;
        context.go('/songs/${saved.id}');
        return;
      } else {
        saved = await repo.updateSong(
          id: widget.songId!,
          title: title,
          index: index,
          book: _book,
          link: link,
        );
      }

      _loaded = saved;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved')));
        setState(() {});
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

  Future<void> _deleteSong() async {
    final id = widget.songId;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete this song?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(songsRepositoryProvider);
      await repo.deleteSong(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleted')));
        context.go('/songs');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createOrEditPart({required AdminSongPartModel? part}) async {
    final songId = widget.songId ?? _loaded?.id;
    if (songId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Save the song first.')));
      return;
    }

    final currentMaxIndex =
        (_loaded?.parts
            .map((e) => e.index)
            .fold<int>(0, (a, b) => a > b ? a : b)) ??
        0;
    final defaultIndex = part?.index ?? (currentMaxIndex + 1);

    final indexController = TextEditingController(
      text: defaultIndex.toString(),
    );
    final nameController = TextEditingController(text: part?.name ?? '');
    final contentController = TextEditingController(text: part?.content ?? '');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(part == null ? 'Add part' : 'Edit part'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: indexController,
                  decoration: const InputDecoration(labelText: 'Index'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name (e.g., Verse 1, Chorus)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  minLines: 6,
                  maxLines: 12,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      indexController.dispose();
      nameController.dispose();
      contentController.dispose();
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = ref.read(songsRepositoryProvider);
      final index = int.tryParse(indexController.text.trim()) ?? defaultIndex;
      final name = nameController.text.trim();
      final content = contentController.text;

      if (part == null) {
        await repo.createSongPart(
          songId: songId,
          index: index,
          name: name,
          content: content,
        );
      } else {
        await repo.updateSongPart(
          id: part.id,
          index: index,
          name: name,
          content: content,
        );
      }

      await _loadIfNeeded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      indexController.dispose();
      nameController.dispose();
      contentController.dispose();
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deletePart(AdminSongPartModel part) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete this part?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(songsRepositoryProvider);
      await repo.deleteSongPart(part.id);
      await _loadIfNeeded();
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
    final isNew = widget.songId == null;
    final theme = Theme.of(context);

    final parts = List<AdminSongPartModel>.from(_loaded?.parts ?? const []);
    parts.sort((a, b) => a.index.compareTo(b.index));

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              isNew ? 'New Song' : 'Edit Song',
              style: theme.textTheme.headlineMedium,
            ),
            const Spacer(),
            if (!isNew) ...[
              OutlinedButton(
                onPressed: _loading ? null : _deleteSong,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
              const SizedBox(width: 8),
            ],
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: const Text('Save'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Song metadata', style: theme.textTheme.titleLarge),
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
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _book,
                          decoration: const InputDecoration(labelText: 'Book'),
                          items: const [
                            DropdownMenuItem(value: 'NKB', child: Text('NKB')),
                            DropdownMenuItem(
                              value: 'NNBT',
                              child: Text('NNBT'),
                            ),
                            DropdownMenuItem(value: 'KJ', child: Text('KJ')),
                            DropdownMenuItem(value: 'DSL', child: Text('DSL')),
                          ],
                          onChanged: _loading
                              ? null
                              : (v) {
                                  if (v == null) return;
                                  setState(() => _book = v);
                                },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _indexController,
                          decoration: const InputDecoration(labelText: 'Index'),
                          enabled: !_loading,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return 'Index is required';
                            final parsed = int.tryParse(value);
                            if (parsed == null || parsed < 1) {
                              return 'Index must be a positive number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _linkController,
                    decoration: const InputDecoration(labelText: 'Link'),
                    enabled: !_loading,
                  ),
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
                Row(
                  children: [
                    Text('Song parts', style: theme.textTheme.titleLarge),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _loading
                          ? null
                          : () => _createOrEditPart(part: null),
                      icon: const Icon(Icons.add),
                      label: const Text('Add part'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (parts.isEmpty)
                  const Text('No parts yet. Add verses/chorus here.'),
                ...parts.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          '${p.index}. ${p.name.isEmpty ? '(unnamed)' : p.name}',
                        ),
                        subtitle: Text(
                          p.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: _loading
                                  ? null
                                  : () => _createOrEditPart(part: p),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: _loading ? null : () => _deletePart(p),
                              icon: Icon(
                                Icons.delete_outline,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
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
