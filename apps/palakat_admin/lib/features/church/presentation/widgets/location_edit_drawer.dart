import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/validation.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/features/church/church.dart';

class LocationEditDrawer extends ConsumerStatefulWidget {
  final Church church;
  final Future<void> Function(Church) onSave;
  final VoidCallback onClose;

  const LocationEditDrawer({
    super.key,
    required this.church,
    required this.onSave,
    required this.onClose,
  });

  @override
  ConsumerState<LocationEditDrawer> createState() =>
      _ChurchLocationEditDrawerState();
}

class _ChurchLocationEditDrawerState extends ConsumerState<LocationEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  bool _saving = false;
  String? _errorMessage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: widget.church.location?.name,
    );
    _latitudeController = TextEditingController(
      text: widget.church.location?.latitude.toString(),
    );
    _longitudeController = TextEditingController(
      text: widget.church.location?.longitude.toString(),
    );
    _fetchLatestLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestLocation() async {
    final locationId = widget.church.locationId;
    if (locationId == null) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final latest = await ref
          .read(churchControllerProvider.notifier)
          .fetchLocationDetail(locationId);
      if (!mounted) return;
      _addressController.text = latest.name;
      _latitudeController.text = latest.latitude.toString();
      _longitudeController.text = latest.longitude.toString();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load location details';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final parsedLat = double.tryParse(_latitudeController.text.trim());
    final parsedLng = double.tryParse(_longitudeController.text.trim());

    final updatedLocation = widget.church.location?.copyWith(
      name: _addressController.text.trim(),
      latitude: parsedLat ?? widget.church.location!.latitude,
      longitude: parsedLng ?? widget.church.location!.longitude,
    );

    final updatedChurch = widget.church.copyWith(location: updatedLocation);

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      await widget.onSave(updatedChurch);
      if (!mounted) return;
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to save changes';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SideDrawer(
      title: 'Edit Location',
      subtitle: 'Update address and coordinates for your church',
      onClose: widget.onClose,
      isLoading: _saving || _loading,
      loadingMessage: _loading
          ? 'Loading location details...'
          : 'Saving changes...',
      errorMessage: _errorMessage,
      onRetry: _loading ? _fetchLatestLocation : null,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoSection(
              title: 'Location Details',
              titleSpacing: 16,
              children: [
                LabeledField(
                  label: 'Address',
                  child: TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Enter church address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    validator: (value) =>
                        ChurchValidators.address().asFormFieldValidator(value),
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    LabeledField(
                      label: 'Latitude',
                      child: TextFormField(
                        controller: _latitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. -6.1754',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        validator: (value) => ChurchValidators.latitude()
                            .asFormFieldValidator(value),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LabeledField(
                      label: 'Longitude',
                      child: TextFormField(
                        controller: _longitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. 106.8272',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        validator: (value) => ChurchValidators.longitude()
                            .asFormFieldValidator(value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
