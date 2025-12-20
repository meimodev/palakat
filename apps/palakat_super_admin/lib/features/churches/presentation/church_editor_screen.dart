import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/core/models/column.dart' as cm;
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../data/churches_repository.dart';

class ChurchEditorScreen extends ConsumerStatefulWidget {
  const ChurchEditorScreen({super.key, this.churchId});

  final int? churchId;

  @override
  ConsumerState<ChurchEditorScreen> createState() => _ChurchEditorScreenState();
}

class _ChurchEditorScreenState extends ConsumerState<ChurchEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _documentAccountNumberController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _locationNameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _loading = false;
  Church? _loaded;

  @override
  void initState() {
    super.initState();
    _loadIfNeeded();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _documentAccountNumberController.dispose();
    _descriptionController.dispose();
    _locationNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _loadIfNeeded() async {
    final id = widget.churchId;
    if (id == null) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(churchesRepositoryProvider);
      final church = await repo.fetchChurch(id);
      _loaded = church;

      _nameController.text = church.name;
      _phoneController.text = church.phoneNumber ?? '';
      _emailController.text = church.email ?? '';
      _documentAccountNumberController.text =
          church.documentAccountNumber ?? '';
      _descriptionController.text = church.description ?? '';

      _locationNameController.text = church.location?.name ?? '';
      _latitudeController.text = church.location?.latitude?.toString() ?? '';
      _longitudeController.text = church.location?.longitude?.toString() ?? '';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double? _parseOptionalDouble(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  String? _validateOptionalDouble(String? input) {
    final trimmed = (input ?? '').trim();
    if (trimmed.isEmpty) return null;
    if (double.tryParse(trimmed) == null) return 'Must be a number';
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(churchesRepositoryProvider);

      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final doc = _documentAccountNumberController.text.trim();
      final description = _descriptionController.text.trim();

      final locName = _locationNameController.text.trim();
      final latitude = _parseOptionalDouble(_latitudeController.text);
      final longitude = _parseOptionalDouble(_longitudeController.text);

      if (widget.churchId == null) {
        final created = await repo.createChurch(
          name: name,
          phoneNumber: phone.isEmpty ? null : phone,
          email: email.isEmpty ? null : email,
          description: description.isEmpty ? null : description,
          documentAccountNumber: doc.isEmpty ? null : doc,
          locationName: locName,
          latitude: latitude,
          longitude: longitude,
        );

        _loaded = created;
        if (!mounted) return;
        context.go('/churches/${created.id}');
        return;
      }

      final current = _loaded;
      if (current == null) {
        throw StateError('Church not loaded');
      }

      Object? optionalStringDelta(String currentValue, String newValue) {
        final trimmed = newValue.trim();
        if (trimmed == currentValue) return ChurchesRepository.notProvided;
        return trimmed.isEmpty ? null : trimmed;
      }

      Object? optionalDoubleDelta(double? currentValue, String newValue) {
        final trimmed = newValue.trim();
        if (trimmed.isEmpty) {
          if (currentValue == null) return ChurchesRepository.notProvided;
          return null;
        }
        final parsed = double.tryParse(trimmed);
        if (parsed == null) return ChurchesRepository.notProvided;
        if (currentValue != null && parsed == currentValue) {
          return ChurchesRepository.notProvided;
        }
        return parsed;
      }

      final update = await repo.updateChurch(
        id: widget.churchId!,
        name: name == current.name ? null : name,
        phoneNumber: optionalStringDelta(current.phoneNumber ?? '', phone),
        email: optionalStringDelta(current.email ?? '', email),
        description: optionalStringDelta(
          current.description ?? '',
          description,
        ),
        documentAccountNumber: optionalStringDelta(
          current.documentAccountNumber ?? '',
          doc,
        ),
        locationName: (locName == (current.location?.name ?? ''))
            ? null
            : locName,
        latitude: optionalDoubleDelta(
          current.location?.latitude,
          _latitudeController.text,
        ),
        longitude: optionalDoubleDelta(
          current.location?.longitude,
          _longitudeController.text,
        ),
      );

      _loaded = update;

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

  Future<void> _deleteChurch() async {
    final id = widget.churchId;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete this church?'),
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
      final repo = ref.read(churchesRepositoryProvider);
      await repo.deleteChurch(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleted')));
        context.go('/churches');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return '-';
    return DateFormatter.formatMedium(date, Localizations.localeOf(context));
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.churchId == null;
    final theme = Theme.of(context);

    final columns = List<cm.Column>.from(_loaded?.columns ?? const []);
    columns.sort((a, b) => a.name.compareTo(b.name));

    final positions = List<MemberPosition>.from(
      _loaded?.membershipPositions ?? const [],
    );
    positions.sort((a, b) => a.name.compareTo(b.name));

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              isNew ? 'New Church' : 'Edit Church',
              style: theme.textTheme.headlineMedium,
            ),
            const Spacer(),
            if (!isNew) ...[
              OutlinedButton(
                onPressed: _loading ? null : _deleteChurch,
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
                  Text('Church profile', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    enabled: !_loading,
                    validator: (v) => Validators.required(
                      'Name is required',
                    ).asFormFieldValidator(v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone number (optional)',
                          ),
                          enabled: !_loading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email (optional)',
                          ),
                          enabled: !_loading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _documentAccountNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Document account number (optional)',
                    ),
                    enabled: !_loading,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                    enabled: !_loading,
                    minLines: 2,
                    maxLines: 4,
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
                Text('Location', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationNameController,
                  decoration: const InputDecoration(labelText: 'Location name'),
                  enabled: !_loading,
                  validator: (v) => Validators.required(
                    'Location name is required',
                  ).asFormFieldValidator(v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude (optional)',
                        ),
                        enabled: !_loading,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        validator: _validateOptionalDouble,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude (optional)',
                        ),
                        enabled: !_loading,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        validator: _validateOptionalDouble,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (!isNew) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Columns (read-only)',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  AppTable<cm.Column>(
                    loading: _loading && _loaded == null,
                    data: columns,
                    columns: [
                      AppTableColumn<cm.Column>(
                        title: 'Name',
                        flex: 3,
                        cellBuilder: (context, row) => Text(row.name),
                      ),
                      AppTableColumn<cm.Column>(
                        title: 'Created',
                        flex: 2,
                        cellBuilder: (context, row) =>
                            Text(_formatDate(context, row.createdAt)),
                      ),
                    ],
                  ),
                ],
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
                  Text(
                    'Membership Positions (read-only)',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  AppTable<MemberPosition>(
                    loading: _loading && _loaded == null,
                    data: positions,
                    columns: [
                      AppTableColumn<MemberPosition>(
                        title: 'Name',
                        flex: 3,
                        cellBuilder: (context, row) => Text(row.name),
                      ),
                      AppTableColumn<MemberPosition>(
                        title: 'Created',
                        flex: 2,
                        cellBuilder: (context, row) =>
                            Text(_formatDate(context, row.createdAt)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
