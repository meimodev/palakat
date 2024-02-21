import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/account/domain/user_address.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/presentation.dart';

class AddressFormController extends StateNotifier<AddressFormState> {
  final BuildContext context;
  final AccountService accountService;

  AddressFormController(this.context, this.accountService)
      : super(const AddressFormState());

  final addressLabelController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();

  String get addressLabel => addressLabelController.text;

  String get firstName => firstNameController.text;

  String get lastName => lastNameController.text;

  String get phone => phoneController.text;

  String get address => addressController.text;

  String get notes => notesController.text;

  void init(
    FormType formType, {
    String? serial,
    String? addressLabel,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    var isEdit = formType == FormType.edit && serial != null;

    state = state.copyWith(
      formType: formType,
      serial: serial,
      pinpointAddress: address,
      pinpointAddressLabel: addressLabel,
      latitude: latitude,
      longitude: longitude,
      isLoading: isEdit,
    );

    if (formType == FormType.edit && serial != null) {
      await getData(serial);
    }
  }

  Future<void> getData(String serial) async {
    var result = await accountService.getAddressBySerial(serial);

    await result.when(
      success: (data) async {
        Placemark address = (await MapsUtil.addressFromPinpoint(
                data.latitude ?? 0, data.longitude ?? 0))
            .first;

        addressLabelController.text = data.label;
        firstNameController.text = data.firstName ?? "";
        lastNameController.text = data.lastName ?? "";
        phoneController.text = data.phone;
        addressController.text = data.address ?? "";
        notesController.text = data.note ?? "";

        state = state.copyWith(
          isLoading: false,
          latitude: data.latitude,
          longitude: data.longitude,
          isPrimary: data.isPrimary,
          pinpointAddressLabel: MapsUtil.getAddressLabelFromPlacemark(address),
          pinpointAddress: MapsUtil.getAddressFromPlacemark(address),
        );
      },
      failure: (error, stackTrace) {
        state = state.copyWith(
          isLoading: false,
        );

        var message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }

  void handleChangePinpoint() async {
    var params = {
      RouteParamKey.formType: FormType.edit,
      RouteParamKey.addressLabel: state.pinpointAddressLabel,
      RouteParamKey.address: state.pinpointAddress,
      RouteParamKey.latitude: state.latitude,
      RouteParamKey.longitude: state.longitude,
    };

    var selected = await context.pushNamed<Map<String, dynamic>>(
      AppRoute.addressMap,
      extra: RouteParam(params: params),
    );

    if (selected != null) {
      state = state.copyWith(
        pinpointAddressLabel: selected[RouteParamKey.addressLabel],
        pinpointAddress: selected[RouteParamKey.address],
        latitude: selected[RouteParamKey.latitude],
        longitude: selected[RouteParamKey.longitude],
      );
    }
  }

  void clearError(String key) {
    if (state.errors.containsKey(key)) {
      var errors = state.errors;
      errors.removeWhere((k, _) => k == key);
      state = state.copyWith(
        errors: errors,
      );
    }
  }

  void clearAllError() {
    state = state.copyWith(errors: {});
  }

  void toggleIsPrimary(bool val) {
    state = state.copyWith(
      isPrimary: val,
    );
  }

  void onSubmit() async {
    clearAllError();
    state = state.copyWith(valid: const AsyncLoading());

    var result = state.formType == FormType.add
        ? await accountService.createAddress(
            address: address,
            firstName: firstName,
            lastName: lastName,
            label: addressLabel,
            isPrimary: state.isPrimary,
            phone: phone,
            longitude: state.longitude,
            latitude: state.latitude,
            note: notes,
          )
        : await accountService.updateAddress(
            serial: state.serial ?? "",
            address: address,
            firstName: firstName,
            lastName: lastName,
            label: addressLabel,
            isPrimary: state.isPrimary,
            phone: phone,
            longitude: state.longitude,
            latitude: state.latitude,
            note: notes,
          );

    result.when(
      success: (data) {
        state = state.copyWith(
          valid: const AsyncData(true),
        );

        final userAddress = UserAddress.fromJson(data.toJson());

        context.popUntilNamedWithResult(
          targetRouteName: AppRoute.addressList,
          result: userAddress,
        );

        Snackbar.success(
            message: state.formType == FormType.add
                ? LocaleKeys.prefix_successfullyAdd.tr(namedArgs: {
                    "value": LocaleKeys.text_address.tr(),
                  })
                : LocaleKeys.prefix_successfullyEdit.tr(namedArgs: {
                    "value": LocaleKeys.text_address.tr(),
                  }));
      },
      failure: (error, _) {
        state = state.copyWith(
          valid: const AsyncData(true),
        );
        var message = NetworkExceptions.getErrorMessage(error);
        var errors = NetworkExceptions.getErrors(error);

        if (errors.isNotEmpty) {
          state = state.copyWith(
            errors: errors,
          );
        } else {
          Snackbar.error(message: message);
        }
      },
    );
  }
}

final addressFormControllerProvider = StateNotifierProvider.family<
    AddressFormController, AddressFormState, BuildContext>(
  (ref, context) {
    return AddressFormController(
      context,
      ref.read(accountServiceProvider),
    );
  },
);
