import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/debounce.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/utils/maps_util.dart';
import 'package:halo_hermina/core/utils/permission_util.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:permission_handler/permission_handler.dart';

class AddressSearchController extends StateNotifier<AddressSearchState> {
  final BuildContext context;
  final AccountService accountService;
  AddressSearchController(this.context, this.accountService)
      : super(const AddressSearchState());

  final debounce = Debounce(const Duration(milliseconds: 500));
  final searchController = TextEditingController();

  bool get canClearSearch => searchController.text.isNullOrEmpty();

  void init(AddressSearchType type) async {
    state = state.copyWith(
      type: type,
    );
  }

  void clearSearch() {
    searchController.clear();
    debounce.dispose();
  }

  void onSearch(String val) {
    debounce.dispose();

    debounce.call(() async {
      state = state.copyWith(
        address: [],
      );

      if (val.isNotEmpty) {
        final res = await accountService.autocompleteAddress(
          input: val,
        );

        res.when(
          success: (data) {
            state = state.copyWith(
              address: data,
            );
          },
          failure: (error, stackTrace) {
            state = state.copyWith(address: []);

            final message = NetworkExceptions.getErrorMessage(error);

            Snackbar.error(message: message);
          },
        );
      }
    });
  }

  void currentLocationChoosed() async {
    final permissionGranted = await PermissionUtil.request(
      Permission.locationWhenInUse,
    );

    if (!permissionGranted) {
      return;
    }

    state = state.copyWith(
      onGeocodingAddress: true,
    );

    final position = await MapsUtil.currentPosition();

    final address = (await MapsUtil.addressFromPinpoint(
      position.latitude,
      position.longitude,
      language: accountService.getAccountSetting().language.languageKey,
    ))
        .first;

    final params = {
      RouteParamKey.addressLabel:
          MapsUtil.getAddressLabelFromPlacemark(address),
      RouteParamKey.address: MapsUtil.getAddressFromPlacemark(address),
      RouteParamKey.latitude: position.latitude,
      RouteParamKey.longitude: position.longitude,
    };

    if (context.mounted) {
      if (state.type == AddressSearchType.add) {
        context.pushNamed(
          AppRoute.addressMap,
          extra: RouteParam(
            params: {
              ...params,
              RouteParamKey.formType: FormType.add,
            },
          ),
        );
      } else {
        context.pop(params);
      }
    }

    state = state.copyWith(
      onGeocodingAddress: false,
    );
  }

  void addressChoosed(AutocompleteAddress address) async {
    state = state.copyWith(
      onGeocodingAddress: true,
    );

    geocoding.Location location = (await MapsUtil.pinpointFromAddress(
      address.fullAddress,
      language: accountService.getAccountSetting().language.languageKey,
    ))
        .first;

    if (context.mounted) {
      final params = {
        RouteParamKey.addressLabel: address.addressLabel,
        RouteParamKey.address: address.fullAddress,
        RouteParamKey.latitude: location.latitude,
        RouteParamKey.longitude: location.longitude,
      };

      if (state.type == AddressSearchType.add) {
        context.pushNamed(
          AppRoute.addressMap,
          extra: RouteParam(
            params: {
              ...params,
              RouteParamKey.formType: FormType.add,
            },
          ),
        );
      } else {
        context.pop(params);
      }
    }

    state = state.copyWith(
      onGeocodingAddress: false,
    );
  }

  @override
  void dispose() {
    debounce.dispose();
    super.dispose();
  }
}

final addressSearchControllerProvider = StateNotifierProvider.family<
    AddressSearchController, AddressSearchState, BuildContext>(
  (ref, context) {
    return AddressSearchController(
      context,
      ref.read(accountServiceProvider),
    );
  },
);
