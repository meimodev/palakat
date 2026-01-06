import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../application/songs_controller.dart';

class SongEditorScreen extends ConsumerStatefulWidget {
  const SongEditorScreen({super.key, this.songId});

  final String? songId;

  @override
  ConsumerState<SongEditorScreen> createState() => _SongEditorScreenState();
}

class _SongEditorScreenState extends ConsumerState<SongEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  final _bookIdController = TextEditingController();
  final _bookNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _subTitleController = TextEditingController();
  final _authorController = TextEditingController();
  final _baseNoteController = TextEditingController();
  final _publisherController = TextEditingController();
  final _urlImageController = TextEditingController();
  final _urlVideoController = TextEditingController();

  List<SongPartType> _composition = const <SongPartType>[];
  List<SongPart> _parts = const <SongPart>[];

  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _idController.dispose();
    _bookIdController.dispose();
    _bookNameController.dispose();
    _titleController.dispose();
    _subTitleController.dispose();
    _authorController.dispose();
    _baseNoteController.dispose();
    _publisherController.dispose();
    _urlImageController.dispose();
    _urlVideoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _syncDefinitionFromComposition();

    setState(() => _loading = true);
    try {
      final controller = ref.read(songsControllerProvider.notifier);
      final id = _idController.text.trim();

      final song = Song(
        id: id,
        bookId: _bookIdController.text.trim(),
        bookName: _bookNameController.text.trim(),
        title: _titleController.text.trim(),
        subTitle: _subTitleController.text.trim(),
        author: _authorController.text.trim(),
        baseNote: _baseNoteController.text.trim(),
        publisher: _publisherController.text.trim(),
        composition: _composition,
        definition: [..._parts],
        urlImage: _urlImageController.text.trim(),
        urlVideo: _urlVideoController.text.trim(),
      );

      await controller.upsertSong(song);

      if (!mounted) return;
      if (widget.songId == null) {
        context.go('/songs/$id');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved locally')));
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
    if (id == null || id.trim().isEmpty) return;

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
      final controller = ref.read(songsControllerProvider.notifier);
      await controller.deleteSong(id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Deleted')));
      context.go('/songs');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _swapPart(int a, int b) {
    setState(() {
      final nextComposition = [..._composition];
      final tmpType = nextComposition[a];
      nextComposition[a] = nextComposition[b];
      nextComposition[b] = tmpType;
      _composition = nextComposition;
      _syncDefinitionFromComposition();
    });
  }

  void _removeAt(int index) {
    setState(() {
      final nextComposition = [..._composition];
      if (index >= 0 && index < nextComposition.length) {
        nextComposition.removeAt(index);
      }
      _composition = nextComposition;
      _syncDefinitionFromComposition();
    });
  }

  void _syncDefinitionFromComposition() {
    final uniqueTypes = <SongPartType>[];
    final seen = <SongPartType>{};
    for (final t in _composition) {
      if (seen.add(t)) uniqueTypes.add(t);
    }

    final byType = <SongPartType, SongPart>{};
    for (final p in _parts) {
      byType.putIfAbsent(p.type, () => p);
    }

    _parts = [
      for (final t in uniqueTypes) byType[t] ?? SongPart(type: t, content: ''),
    ];
  }

  Future<void> _addCompositionItem() async {
    SongPartType type = SongPartType.verse;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add part type'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: DropdownButtonFormField<SongPartType>(
              value: type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: SongPartType.values
                  .map(
                    (t) => DropdownMenuItem<SongPartType>(
                      value: t,
                      child: Text(t.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                type = value;
              },
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

    if (confirmed != true) return;

    setState(() {
      _composition = [..._composition, type];
      _syncDefinitionFromComposition();
    });
  }

  Future<void> _editPartContent(int index) async {
    if (index < 0 || index >= _parts.length) return;
    final part = _parts[index];
    final contentController = TextEditingController(text: part.content);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${part.type.name}'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: TextFormField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              minLines: 6,
              maxLines: 12,
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
      contentController.dispose();
      return;
    }

    final next = part.copyWith(content: contentController.text);
    contentController.dispose();

    setState(() {
      final list = [..._parts];
      list[index] = next;
      _parts = list;
    });
  }

  void _hydrateFromSong(Song s) {
    _idController.text = s.id;
    _bookIdController.text = s.bookId;
    _bookNameController.text = s.bookName;
    _titleController.text = s.title;
    _subTitleController.text = s.subTitle;
    _authorController.text = s.author;
    _baseNoteController.text = s.baseNote;
    _publisherController.text = s.publisher;
    _urlImageController.text = s.urlImage;
    _urlVideoController.text = s.urlVideo;

    final composition = [...s.composition];
    final definition = [...s.definition];
    if (composition.isEmpty) {
      composition.addAll(definition.map((e) => e.type));
    }

    _composition = composition;
    _parts = definition;
    _syncDefinitionFromComposition();
  }

  @override
  void didUpdateWidget(covariant SongEditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      _initialized = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final songsState = ref.watch(songsControllerProvider);
    final controller = ref.read(songsControllerProvider.notifier);

    final asyncDb = songsState.songDb;
    final isNew = widget.songId == null;

    if (!_initialized && asyncDb.hasValue) {
      final songId = widget.songId;
      if (songId != null) {
        final song = controller.findSongById(songId);
        if (song != null) {
          _hydrateFromSong(song);
          _initialized = true;
        }
      } else {
        _idController.text = '';
        _composition = const <SongPartType>[];
        _parts = const <SongPart>[];
        _initialized = true;
      }
    }

    final title = isNew ? 'New Song' : 'Edit Song';
    final canEdit = asyncDb.hasValue;

    if (!canEdit) {
      return Center(
        child: asyncDb.isLoading
            ? const CircularProgressIndicator()
            : Text(asyncDb.error.toString()),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          SurfaceCard(
            title: 'Song',
            subtitle:
                'Edits are saved locally and uploaded when you publish songs.json.',
            trailing: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _loading ? null : _save,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Save'),
                ),
                if (!isNew)
                  FilledButton.tonalIcon(
                    onPressed: _loading ? null : _deleteSong,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'ID (e.g. KJ-1)',
                    ),
                    enabled: isNew,
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'ID is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _bookIdController,
                          decoration: const InputDecoration(
                            labelText: 'Book ID (e.g. kj)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _bookNameController,
                          decoration: const InputDecoration(
                            labelText: 'Book Name',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Title is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _subTitleController,
                    decoration: const InputDecoration(labelText: 'Sub Title'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _authorController,
                          decoration: const InputDecoration(
                            labelText: 'Author',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _publisherController,
                          decoration: const InputDecoration(
                            labelText: 'Publisher',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _baseNoteController,
                    decoration: const InputDecoration(labelText: 'Base Note'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _urlImageController,
                          decoration: const InputDecoration(
                            labelText: 'urlImage',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _urlVideoController,
                          decoration: const InputDecoration(
                            labelText: 'urlVideo',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Composition',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _loading ? null : _addCompositionItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_composition.isEmpty)
                    Text(
                      'No composition yet.',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else
                    ...List.generate(_composition.length, (i) {
                      final t = _composition[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(width: 56, child: Text('${i + 1}.')),
                            Expanded(
                              child: DropdownButtonFormField<SongPartType>(
                                value: t,
                                decoration: const InputDecoration(
                                  labelText: 'Type',
                                ),
                                items: SongPartType.values
                                    .map(
                                      (v) => DropdownMenuItem<SongPartType>(
                                        value: v,
                                        child: Text(v.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _loading
                                    ? null
                                    : (value) {
                                        if (value == null) return;
                                        setState(() {
                                          final nextComposition = [
                                            ..._composition,
                                          ];
                                          nextComposition[i] = value;
                                          _composition = nextComposition;
                                          _syncDefinitionFromComposition();
                                        });
                                      },
                              ),
                            ),
                            IconButton(
                              onPressed: _loading || i == 0
                                  ? null
                                  : () => _swapPart(i, i - 1),
                              icon: const Icon(Icons.arrow_upward),
                            ),
                            IconButton(
                              onPressed:
                                  _loading || i == _composition.length - 1
                                  ? null
                                  : () => _swapPart(i, i + 1),
                              icon: const Icon(Icons.arrow_downward),
                            ),
                            IconButton(
                              onPressed: _loading ? null : () => _removeAt(i),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 20),
                  Text(
                    'Definition',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_parts.isEmpty)
                    Text(
                      'No definition yet.',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else
                    ...List.generate(_parts.length, (i) {
                      final p = _parts[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.type.name),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.content,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _loading
                                  ? null
                                  : () => _editPartContent(i),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/songs'),
            child: const Text('Back to list'),
          ),
        ],
      ),
    );
  }
}
