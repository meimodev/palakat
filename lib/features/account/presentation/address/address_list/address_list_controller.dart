import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class AddressListController extends StateNotifier<AddressListState> {
  final BuildContext context;
  final AccountService accountService;

  AddressListController(this.context, this.accountService)
      : super(const AddressListState()) {
    getAddresses();
  }

  void handleAddNew() async {
    final result = await context.pushNamed(
      AppRoute.addressSearch,
      extra: const RouteParam(
        params: {
          RouteParamKey.addressSearchType: AddressSearchType.add,
        },
      ),
    );

    if (result != null) {
      addNewAddress(result as UserAddress);
    }
  }

  void addNewAddress(UserAddress userAddress) {
    state = state.copyWith(userAddresses: [
      ...state.userAddresses,
      userAddress,
    ]);
  }

  void handleOnEdit(String serial) {
    context.pushNamed(
      AppRoute.addressForm,
      extra: RouteParam(
        params: {
          RouteParamKey.formType: FormType.edit,
          RouteParamKey.serial: serial,
        },
      ),
    );
  }

  void handleOnDelete(String serial) async {
    showGeneralDialogWidget(
      context,
      image: Assets.images.questionMark.image(
        width: BaseSize.customWidth(90),
        height: BaseSize.customWidth(90),
      ),
      title: LocaleKeys.prefix_delete.tr(namedArgs: {
        "value": LocaleKeys.text_address.tr(),
      }),
      subtitle: LocaleKeys.text_doYouWantToDeleteThisAddress.tr(),
      primaryButtonTitle: LocaleKeys.text_cancel.tr(),
      secondaryButtonTitle: LocaleKeys.text_yes.tr(),
      onSecondaryAction: () async {
        context.pop();

        state = state.copyWith(isLoading: true);

        var result = await accountService.deleteAddress(serial: serial);

        result.when(
          success: (_) {
            getAddresses();

            Snackbar.success(
              message: LocaleKeys.prefix_successfullyDelete.tr(namedArgs: {
                "value": LocaleKeys.text_address.tr(),
              }),
            );

            return true;
          },
          failure: (error, _) {
            state = state.copyWith(
              isLoading: false,
            );
            var message = NetworkExceptions.getErrorMessage(error);
            Snackbar.error(message: message);

            return false;
          },
        );
      },
      action: () {
        context.pop();
      },
    );
  }

  void handleOnSelect() {
    var params = {
      RouteParamKey.name: state.selectedName,
      RouteParamKey.address: state.selectedAddressDesc,
    };

    if (state.type == AddressListType.selection) {
      context.pop(params);
    } else {
      context.pushNamed(
        AppRoute.selfCheckInPickUpMethod,
        extra: RouteParam(
          params: {...params},
        ),
      );
    }
  }

  void handleOnTap(String serial, String name, String? address) {
    state = state.copyWith(
      selectedAddress: serial,
      selectedName: name,
      selectedAddressDesc: address,
    );
  }

  Future getAddresses({bool isRefresh = false}) async {
    if (!isRefresh) state = state.copyWith(isLoading: true);

    var result = await accountService.getAddresses();

    result.when(
      success: (data) {
        state = state.copyWith(
          isLoading: false,
          userAddresses: data
              .map(
                (e) => UserAddress.fromJson(e.toJson()),
              )
              .toList(),
        );

        return true;
      },
      failure: (error, _) {
        state = state.copyWith(
          isLoading: false,
        );
        var message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);

        return false;
      },
    );
  }

  void setOperationType(AddressListType operationType) {
    state = state.copyWith(type: operationType);
  }

  void handleOnPopScreen() {
    if (state.type == AddressListType.selection) {
      if (state.selectedAddress == null) {
        Snackbar.error(message: LocaleKeys.text_chooseYourAddress.tr());
        return;
      }
      final UserAddress userAddress = state.userAddresses.firstWhere(
        (e) => e.serial == state.selectedAddress,
      );

      context.pop(userAddress);
    }
  }
}

final addressListControllerProvider = StateNotifierProvider.family<
    AddressListController, AddressListState, BuildContext>(
  (ref, context) {
    return AddressListController(
      context,
      ref.read(accountServiceProvider),
    );
  },
);
