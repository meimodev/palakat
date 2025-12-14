import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/church/church.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

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
      text: widget.church.location?.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.church.location?.longitude?.toString() ?? '',
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
      _latitudeController.text = latest.latitude?.toString() ?? '';
      _longitudeController.text = latest.longitude?.toString() ?? '';
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = context.l10n.error_loadingData;
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
        _errorMessage = context.l10n.msg_saveFailed;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SideDrawer(
      title: l10n.drawer_editLocation_title,
      subtitle: l10n.drawer_editLocation_subtitle,
      onClose: widget.onClose,
      isLoading: _saving || _loading,
      loadingMessage: _loading ? l10n.loading_data : l10n.loading_saving,
      errorMessage: _errorMessage,
      onRetry: _loading ? _fetchLatestLocation : null,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoSection(
              title: l10n.section_locationDetails,
              titleSpacing: 16,
              children: [
                LabeledField(
                  label: l10n.lbl_address,
                  child: TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: l10n.hint_enterChurchAddress,
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
                      label: l10n.lbl_latitude,
                      child: TextFormField(
                        controller: _latitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.hint_latitudeExample,
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
                      label: l10n.lbl_longitude,
                      child: TextFormField(
                        controller: _longitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.hint_longitudeExample,
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
            child: Text(l10n.btn_saveChanges),
          ),
        ],
      ),
    );
  }
}
