import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  final FormType formType;
  final String? addressSerial;
  final String? addressLabel;
  final String? address;
  final double? latitude;
  final double? longitude;
  const AddressFormScreen({
    super.key,
    required this.formType,
    this.addressSerial,
    this.addressLabel,
    this.address,
    this.latitude,
    this.longitude,
  });

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  AddressFormController get controller =>
      ref.read(addressFormControllerProvider(context).notifier);

  @override
  void initState() {
    safeRebuild(
      () {
        controller.init(
          widget.formType,
          serial: widget.addressSerial,
          address: widget.address,
          addressLabel: widget.addressLabel,
          latitude: widget.latitude,
          longitude: widget.longitude,
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressFormControllerProvider(context));

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: state.formType == FormType.add
            ? LocaleKeys.text_addressDetail.tr()
            : LocaleKeys.prefix_edit.tr(namedArgs: {
                "value": LocaleKeys.text_address.tr(),
              }),
      ),
      child: LoadingWrapper(
        value: state.isLoading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: horizontalPadding,
                children: [
                  Gap.h24,
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            LocaleKeys.text_pinLocation.tr(),
                            style: TypographyTheme.textLRegular.toNeutral60,
                          ),
                          GestureDetector(
                            onTap: controller.handleChangePinpoint,
                            child: Text(
                              LocaleKeys.text_change.tr(),
                              style: TypographyTheme.textMSemiBold.toPrimary,
                            ),
                          ),
                        ],
                      ),
                      Gap.h12,
                      CardWidget(
                        content: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Assets.icons.fill.mapPin.svg(
                                colorFilter: BaseColor.red.shade400.filterSrcIn,
                              ),
                              Gap.w8,
                              Flexible(
                                child: Text(
                                  state.pinpointAddress ?? "",
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      TypographyTheme.textMRegular.toNeutral60,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Gap.h28,
                  InputFormWidget(
                    controller: controller.addressLabelController,
                    hintText: LocaleKeys.text_addressLabel.tr(),
                    hasIconState: false,
                    label: LocaleKeys.text_addressLabel.tr(),
                    keyboardType: TextInputType.text,
                    hasBorderState: false,
                    onChanged: (_) => controller.clearError("label"),
                    error: state.errors['label'],
                  ),
                  Gap.h28,
                  InputFormWidget(
                    controller: controller.firstNameController,
                    hintText: LocaleKeys.text_firstName.tr(),
                    hasIconState: false,
                    label: LocaleKeys.text_firstName.tr(),
                    keyboardType: TextInputType.text,
                    hasBorderState: false,
                    onChanged: (_) => controller.clearError("firstName"),
                    error: state.errors['firstName'],
                  ),
                  Gap.h28,
                  InputFormWidget(
                    controller: controller.lastNameController,
                    hintText: LocaleKeys.text_lastName.tr(),
                    hasIconState: false,
                    label: LocaleKeys.text_lastName.tr(),
                    keyboardType: TextInputType.text,
                    hasBorderState: false,
                    onChanged: (_) => controller.clearError("lastName"),
                    error: state.errors['lastName'],
                  ),
                  Gap.h28,
                  InputFormWidget(
                    isInputNumber: true,
                    label: LocaleKeys.text_phoneNumber.tr(),
                    controller: controller.phoneController,
                    hintText: LocaleKeys.text_phoneNumber.tr(),
                    hasIconState: false,
                    keyboardType: TextInputType.number,
                    hasBorderState: false,
                    onChanged: (_) => controller.clearError("phone"),
                    error: state.errors['phone'],
                  ),
                  Gap.h28,
                  InputFormWidget(
                    isInputNumber: true,
                    label: LocaleKeys.text_address.tr(),
                    controller: controller.addressController,
                    hintText: LocaleKeys.text_address.tr(),
                    hasIconState: false,
                    keyboardType: TextInputType.text,
                    hasBorderState: false,
                    maxLines: 3,
                    onChanged: (_) => controller.clearError("address"),
                    error: state.errors['address'],
                  ),
                  Gap.h28,
                  InputFormWidget(
                    controller: controller.notesController,
                    hintText: LocaleKeys.text_notesOptional.tr(),
                    hasIconState: false,
                    keyboardType: TextInputType.text,
                    maxLines: 3,
                    hasBorderState: false,
                    onChanged: (_) => controller.clearError("note"),
                    error: state.errors['note'],
                  ),
                  Gap.h28,
                  SwitchWidget.primary(
                    label: LocaleKeys.text_setAsPrimaryAddress.tr(),
                    value: state.isPrimary,
                    size: SwitchSize.small,
                    onChanged: (value) {
                      controller.toggleIsPrimary(value);
                    },
                  ),
                  Gap.h48
                ],
              ),
            ),
            SizedBox(
              child: Container(
                padding: horizontalPadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(1),
                      offset: const Offset(-1, -2),
                      blurRadius: 9,
                      spreadRadius: -10,
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: BaseSize.h28,
                    top: BaseSize.h16,
                  ),
                  child: ButtonWidget.primary(
                    color: BaseColor.primary3,
                    overlayColor: BaseColor.white.withOpacity(.5),
                    isShrink: true,
                    isLoading: state.valid.isLoading,
                    text: LocaleKeys.prefix_save.tr(namedArgs: {
                      "value": LocaleKeys.text_address.tr(),
                    }),
                    onTap: () => controller.onSubmit(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
