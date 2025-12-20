import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/authentication/presentations/widgets/phone_input_formatter.dart';
import 'package:palakat_shared/core/models/church_request.dart';
import 'package:palakat_shared/extensions.dart';
import 'package:palakat_shared/repositories.dart';
import 'package:palakat_shared/services.dart';

class ChurchRequestBottomSheet extends ConsumerStatefulWidget {
  const ChurchRequestBottomSheet({super.key, this.initialRequest});

  final ChurchRequest? initialRequest;

  @override
  ConsumerState<ChurchRequestBottomSheet> createState() =>
      _ChurchRequestBottomSheetState();
}

class _ChurchRequestBottomSheetState
    extends ConsumerState<ChurchRequestBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _churchNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  // Validation error messages
  String? _churchNameError;
  String? _addressError;
  String? _contactPersonError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRequest;
    if (initial != null) {
      _churchNameController.text = initial.churchName;
      _addressController.text = initial.churchAddress;
      _contactPersonController.text = initial.contactPerson;
      _phoneController.text = initial.contactPhone;
    }
  }

  @override
  void dispose() {
    _churchNameController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BaseSize.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: BaseSize.h12),
            width: BaseSize.w40,
            height: BaseSize.h4,
            decoration: BoxDecoration(
              color: BaseColor.neutral[300],
              borderRadius: BorderRadius.circular(BaseSize.radiusSm),
            ),
          ),
          Gap.h16,
          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.churchRequest_title,
                    style: BaseTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: FaIcon(AppIcons.close),
                  color: BaseColor.neutral[600],
                ),
              ],
            ),
          ),
          Gap.h8,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
            child: Text(
              l10n.churchRequest_description,
              style: BaseTypography.bodyMedium.copyWith(
                color: BaseColor.neutral[600],
              ),
            ),
          ),
          Gap.h16,
          // Error message display
          if (_errorMessage != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
              child: Container(
                padding: EdgeInsets.all(BaseSize.w12),
                decoration: BoxDecoration(
                  color: BaseColor.red.shade50,
                  border: Border.all(color: BaseColor.red.shade200, width: 1),
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FaIcon(
                      AppIcons.error,
                      size: BaseSize.w20,
                      color: BaseColor.red.shade700,
                    ),
                    Gap.w8,
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _errorMessage = null),
                      child: FaIcon(
                        AppIcons.close,
                        size: BaseSize.w16,
                        color: BaseColor.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gap.h12,
          ],
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Requester Information Section
                    _buildRequesterInfoSection(),
                    Gap.h20,
                    // Church Information Section
                    Text(
                      l10n.churchRequest_churchInformation,
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BaseColor.black,
                      ),
                    ),
                    Gap.h12,
                    InputWidget.text(
                      controller: _churchNameController,
                      label: l10n.lbl_churchName,
                      hint: l10n.hint_enterChurchName,
                      errorText: _churchNameError,
                      onChanged: (_) {
                        if (_churchNameError != null) {
                          setState(() => _churchNameError = null);
                        }
                      },
                      validators: _validateChurchName,
                    ),
                    Gap.h12,
                    InputWidget.text(
                      controller: _addressController,
                      label: l10n.lbl_churchAddress,
                      hint: l10n.hint_enterChurchAddress,
                      maxLines: 2,
                      errorText: _addressError,
                      onChanged: (_) {
                        if (_addressError != null) {
                          setState(() => _addressError = null);
                        }
                      },
                      validators: _validateAddress,
                    ),
                    Gap.h12,
                    InputWidget.text(
                      controller: _contactPersonController,
                      label: l10n.lbl_contactPerson,
                      hint: l10n.churchRequest_hintEnterContactPersonName,
                      errorText: _contactPersonError,
                      onChanged: (_) {
                        if (_contactPersonError != null) {
                          setState(() => _contactPersonError = null);
                        }
                      },
                      validators: _validateContactPerson,
                    ),
                    Gap.h12,
                    InputWidget.text(
                      controller: _phoneController,
                      label: l10n.lbl_phone,
                      hint: l10n.churchRequest_hintPhoneExample,
                      textInputType: TextInputType.phone,
                      errorText: _phoneError,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        PhoneInputFormatter(),
                      ],
                      onChanged: (_) {
                        if (_phoneError != null) {
                          setState(() => _phoneError = null);
                        }
                      },
                      validators: _validatePhone,
                    ),
                    Gap.h24,
                  ],
                ),
              ),
            ),
          ),
          // Submit button
          Padding(
            padding: EdgeInsets.all(BaseSize.w16),
            child: ButtonWidget.primary(
              text: _isSubmitting
                  ? l10n.churchRequest_submitting
                  : l10n.churchRequest_submitRequest,
              onTap: _isSubmitting ? null : _handleSubmit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequesterInfoSection() {
    final l10n = context.l10n;
    final localStorage = ref.watch(localStorageServiceProvider);
    final account = localStorage.currentAuth?.account;

    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: BaseColor.blue.shade50,
        border: Border.all(color: BaseColor.blue.shade200, width: 1),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              FaIcon(
                AppIcons.person,
                size: BaseSize.w20,
                color: BaseColor.blue.shade700,
              ),
              Gap.w8,
              Text(
                l10n.churchRequest_requesterInformation,
                style: BaseTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BaseColor.blue.shade700,
                ),
              ),
            ],
          ),
          Gap.h8,
          _buildInfoRow(l10n.lbl_name, account?.name ?? l10n.lbl_na),
          Gap.h4,
          _buildInfoRow(l10n.lbl_phone, account?.phone ?? l10n.lbl_na),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: BaseSize.w80,
          child: Text(
            '$label:',
            style: BaseTypography.bodySmall.copyWith(
              color: BaseColor.neutral[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: BaseTypography.bodySmall.copyWith(
              color: BaseColor.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String? _validateChurchName(String value) {
    final l10n = context.l10n;
    if (value.isEmpty) {
      return l10n.err_requiredField;
    }
    if (value.length < 3) {
      return l10n.validation_minLength(3);
    }
    if (value.length > 100) {
      return l10n.validation_maxLength(100);
    }
    return null;
  }

  String? _validateAddress(String value) {
    final l10n = context.l10n;
    if (value.isEmpty) {
      return l10n.err_requiredField;
    }
    if (value.length < 10) {
      return l10n.churchRequest_validation_completeAddress;
    }
    if (value.length > 200) {
      return l10n.validation_maxLength(200);
    }
    return null;
  }

  String? _validateContactPerson(String value) {
    final l10n = context.l10n;
    if (value.isEmpty) {
      return l10n.err_requiredField;
    }
    if (value.length < 3) {
      return l10n.validation_minLength(3);
    }
    if (value.length > 100) {
      return l10n.validation_maxLength(100);
    }
    return null;
  }

  String? _validatePhone(String value) {
    final l10n = context.l10n;
    if (value.isEmpty) {
      return l10n.err_requiredField;
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return l10n.churchRequest_validation_phoneMinDigits(10);
    }
    if (digitsOnly.length > 13) {
      return l10n.churchRequest_validation_phoneMaxDigits(13);
    }
    if (!digitsOnly.startsWith('0')) {
      return l10n.churchRequest_validation_phoneMustStartWithZero;
    }
    return null;
  }

  bool _validateForm() {
    final churchNameError = _validateChurchName(
      _churchNameController.text.trim(),
    );
    final addressError = _validateAddress(_addressController.text.trim());
    final contactPersonError = _validateContactPerson(
      _contactPersonController.text.trim(),
    );
    final phoneError = _validatePhone(_phoneController.text.trim());

    setState(() {
      _churchNameError = churchNameError;
      _addressError = addressError;
      _contactPersonError = contactPersonError;
      _phoneError = phoneError;
      _errorMessage = null;
    });

    return churchNameError == null &&
        addressError == null &&
        contactPersonError == null &&
        phoneError == null;
  }

  Future<void> _handleSubmit() async {
    // Clear previous errors
    setState(() {
      _errorMessage = null;
      _churchNameError = null;
      _addressError = null;
      _contactPersonError = null;
      _phoneError = null;
    });

    // Validate form
    if (!_validateForm()) {
      setState(() {
        _errorMessage = context.l10n.churchRequest_fixErrorsBeforeSubmitting;
      });
      return;
    }

    // Check if form key validates (additional check)
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage =
            context.l10n.churchRequest_fillAllRequiredFieldsCorrectly;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final churchRequestRepo = ref.read(churchRequestRepositoryProvider);

      final data = {
        'churchName': _churchNameController.text.trim(),
        'churchAddress': _addressController.text.trim(),
        'contactPerson': _contactPersonController.text.trim(),
        'contactPhone': _phoneController.text.trim().replaceAll("-", ""),
      };

      final result = await churchRequestRepo.createChurchRequest(data: data);

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      result.when(
        onSuccess: (_) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  FaIcon(AppIcons.success, color: BaseColor.white),
                  Gap.w8,
                  Expanded(
                    child: Text(
                      context.l10n.churchRequest_submittedSuccessfully,
                    ),
                  ),
                ],
              ),
              backgroundColor: BaseColor.success,
              duration: const Duration(seconds: 3),
            ),
          );

          // Close the bottom sheet
          Navigator.of(context).pop();

          // Navigate to home screen
          context.goNamed(AppRoute.home);
        },
        onFailure: (failure) {
          setState(() {
            _errorMessage = failure.message;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  FaIcon(AppIcons.error, color: BaseColor.white),
                  Gap.w8,
                  Expanded(child: Text(failure.message)),
                ],
              ),
              backgroundColor: BaseColor.error,
              duration: const Duration(seconds: 4),
            ),
          );
        },
      );
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _errorMessage = context.l10n.err_somethingWentWrong;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              FaIcon(AppIcons.error, color: BaseColor.white),
              Gap.w8,
              Expanded(
                child: Text(
                  context.l10n.churchRequest_errorWithDetail(e.toString()),
                ),
              ),
            ],
          ),
          backgroundColor: BaseColor.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _errorMessage = context.l10n.err_somethingWentWrong;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              FaIcon(AppIcons.error, color: BaseColor.white),
              Gap.w8,
              Expanded(child: Text(context.l10n.err_somethingWentWrong)),
            ],
          ),
          backgroundColor: BaseColor.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
