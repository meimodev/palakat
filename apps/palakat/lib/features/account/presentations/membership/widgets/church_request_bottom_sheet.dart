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

    return Material(
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SanctuaryLayout.radiusLarge),
        ),
        side: BorderSide(color: AppColors.ghostBorder(0.08)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SanctuaryLayout.radiusLarge),
          ),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.045, blur: 28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.0),
              width: 44.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: AppColors.ghostBorder(0.18),
                borderRadius: BorderRadius.circular(SanctuaryLayout.pillRadius),
                boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 4),
              ),
            ),
            Gap.h16,
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      border: Border.all(color: AppColors.ghostBorder(0.06)),
                      borderRadius: BorderRadius.circular(
                        SanctuaryLayout.radiusLarge,
                      ),
                      boxShadow: SanctuaryDepth.ambient(
                        opacity: 0.02,
                        blur: 12,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.church_rounded,
                      color: AppColors.primary,
                      size: 22.0,
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        l10n.churchRequest_title,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Gap.w12,
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      border: Border.all(color: AppColors.ghostBorder(0.06)),
                      borderRadius: BorderRadius.circular(
                        SanctuaryLayout.radius,
                      ),
                      boxShadow: SanctuaryDepth.ambient(
                        opacity: 0.02,
                        blur: 10,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: FaIcon(
                        AppIcons.close,
                        size: 16.0,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gap.h8,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  border: Border.all(color: AppColors.ghostBorder(0.06)),
                  borderRadius: BorderRadius.circular(
                    SanctuaryLayout.radiusLarge,
                  ),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 14),
                ),
                child: Text(
                  l10n.churchRequest_description,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            Gap.h16,
            // Error message display
            if (_errorMessage != null && _errorMessage!.trim().isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: ErrorDisplayWidget(
                  message: _errorMessage!,
                  padding: EdgeInsets.zero,
                ),
              ),
              Gap.h12,
            ],
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border.all(color: AppColors.ghostBorder(0.08)),
                    borderRadius: BorderRadius.circular(
                      SanctuaryLayout.radiusLarge,
                    ),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 22),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Requester Information Section
                        _buildRequesterInfoSection(),
                        Gap.h20,
                        // Church Information Section
                        _buildSectionHeader(
                          icon: Icons.location_city_rounded,
                          title: l10n.churchRequest_churchInformation,
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
            ),
            // Submit button
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Material(
                color: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    SanctuaryLayout.radiusLarge,
                  ),
                  side: BorderSide(color: AppColors.ghostBorder(0.08)),
                ),
                child: Container(
                  padding: EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(
                      SanctuaryLayout.radiusLarge,
                    ),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.04, blur: 22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          border: Border.all(
                            color: AppColors.ghostBorder(0.06),
                          ),
                          borderRadius: BorderRadius.circular(
                            SanctuaryLayout.radius,
                          ),
                          boxShadow: SanctuaryDepth.ambient(
                            opacity: 0.02,
                            blur: 10,
                          ),
                        ),
                        child: Text(
                          l10n.churchRequest_title,
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Gap.h12,
                      ButtonWidget.primary(
                        text: _isSubmitting
                            ? l10n.churchRequest_submitting
                            : l10n.churchRequest_submitRequest,
                        onTap: _isSubmitting ? null : _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border.all(color: AppColors.ghostBorder(0.06)),
            borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20.0, color: AppColors.primary),
        ),
        Gap.w12,
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequesterInfoSection() {
    final l10n = context.l10n;
    final localStorage = ref.watch(localStorageServiceProvider);
    final account = localStorage.currentAuth?.account;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
        side: BorderSide(color: AppColors.ghostBorder(0.08)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 16),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final shouldStack =
                    constraints.maxWidth < 260 ||
                    MediaQuery.textScalerOf(context).scale(1) > 1.1;

                final icon = Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    border: Border.all(color: AppColors.ghostBorder(0.06)),
                    borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person_rounded,
                    size: 20.0,
                    color: AppColors.primary,
                  ),
                );

                final title = Text(
                  l10n.churchRequest_requesterInformation,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  maxLines: shouldStack ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                );

                if (shouldStack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [icon, Gap.h12, title],
                  );
                }

                return Row(
                  children: [
                    icon,
                    Gap.w12,
                    Expanded(child: title),
                  ],
                );
              },
            ),
            Gap.h12,
            _buildInfoRow(l10n.lbl_name, account?.name ?? l10n.lbl_na),
            Gap.h8,
            _buildInfoRow(l10n.lbl_phone, account?.phone ?? l10n.lbl_na),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack =
            constraints.maxWidth < 240 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.1;

        final labelWidget = Text(
          '$label:',
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        );

        final valueWidget = Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        );

        if (shouldStack) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border.all(color: AppColors.ghostBorder(0.06)),
              borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelWidget, Gap.h4, valueWidget],
            ),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            border: Border.all(color: AppColors.ghostBorder(0.06)),
            borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 84.0, child: labelWidget),
              Gap.w6,
              Expanded(child: valueWidget),
            ],
          ),
        );
      },
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
          _showStatusSnackBar(
            context,
            message: context.l10n.churchRequest_submittedSuccessfully,
            isSuccess: true,
          );

          Navigator.of(context).pop();

          context.goNamed(AppRoute.home);
        },
        onFailure: (failure) {
          setState(() {
            _errorMessage = failure.message;
          });

          _showStatusSnackBar(context, message: failure.message);
        },
      );
    } on Exception catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _errorMessage = context.l10n.err_somethingWentWrong;
      });

      _showStatusSnackBar(
        context,
        message: context.l10n.churchRequest_errorWithDetail(e.toString()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _errorMessage = context.l10n.err_somethingWentWrong;
      });

      _showStatusSnackBar(
        context,
        message: context.l10n.err_somethingWentWrong,
      );
    }
  }

  void _showStatusSnackBar(
    BuildContext context, {
    required String message,
    bool isSuccess = false,
  }) {
    final theme = Theme.of(context);
    final accentColor = isSuccess ? AppColors.success : AppColors.error;
    final accentIcon = isSuccess ? AppIcons.success : AppIcons.error;
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        duration: Duration(seconds: isSuccess ? 3 : 4),
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
            border: Border.all(color: accentColor.withValues(alpha: 0.18)),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 16),
          ),
          child: Row(
            children: [
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                ),
                alignment: Alignment.center,
                child: FaIcon(accentIcon, size: 14.0, color: accentColor),
              ),
              Gap.w12,
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
