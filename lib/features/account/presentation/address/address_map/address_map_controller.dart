import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class AddressMapController extends StateNotifier<AddressMapState> {
  final BuildContext context;
  final AccountService accountService;
  final debouncer = Debounce(const Duration(milliseconds: 100));
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  AddressMapController(
    this.context,
    this.accountService,
  ) : super(const AddressMapState());

  void init(
    FormType type,
    String addressLabel,
    String address,
    double latitude,
    double longitude,
  ) {
    state = state.copyWith(
      type: type,
      addressLabel: addressLabel,
      address: address,
      latitude: latitude,
      longitude: longitude,
      isLoading: false,
    );
  }

  void onMapCreated(GoogleMapController map) async {
    mapController.complete(map);

    MapsUtil.zoomToMarker(
      mapController,
      state.latitude ?? 0,
      state.longitude ?? 0,
    );
  }

  void handleOnSelect() {
    var params = {
      RouteParamKey.addressLabel: state.addressLabel,
      RouteParamKey.address: state.address,
      RouteParamKey.latitude: state.latitude,
      RouteParamKey.longitude: state.longitude,
    };

    if (state.type == FormType.edit) {
      context.pop(params);
    } else {
      context.pushNamed(
        AppRoute.addressForm,
        extra: RouteParam(
          params: {
            ...params,
            RouteParamKey.formType: FormType.add,
          },
        ),
      );
    }
  }

  void handleOnSearch() async {
    var selected = await context.pushNamed<Map<String, dynamic>>(
      AppRoute.addressSearch,
      extra: const RouteParam(params: {
        RouteParamKey.addressSearchType: AddressSearchType.search,
      }),
    );

    if (selected != null) {
      MapsUtil.zoomToMarker(
        mapController,
        selected[RouteParamKey.latitude],
        selected[RouteParamKey.longitude],
      );

      state = state.copyWith(
        address: selected[RouteParamKey.address],
        addressLabel: selected[RouteParamKey.addressLabel],
        latitude: selected[RouteParamKey.latitude],
        longitude: selected[RouteParamKey.longitude],
      );
    }
  }

  void onCameraMove(CameraPosition position) {
    debouncer.dispose();

    if (mapController.isCompleted) {
      debouncer.call(
        () async {
          if (mapController.isCompleted) {
            state = state.copyWith(
              isLoading: true,
            );

            var address = (await MapsUtil.addressFromPinpoint(
              position.target.latitude,
              position.target.longitude,
            ))
                .first;

            state = state.copyWith(
              isLoading: false,
              addressLabel: MapsUtil.getAddressLabelFromPlacemark(address),
              address: MapsUtil.getAddressFromPlacemark(address),
              latitude: position.target.latitude,
              longitude: position.target.longitude,
            );
          }
        },
      );
    }
  }

  @override
  void dispose() {
    debouncer.dispose();
    super.dispose();
  }
}

final addressMapControllerProvider = StateNotifierProvider.family<
    AddressMapController, AddressMapState, BuildContext>(
  (ref, context) {
    return AddressMapController(
      context,
      ref.read(accountServiceProvider),
    );
  },
);
