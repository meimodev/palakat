import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class AddressMapScreen extends ConsumerStatefulWidget {
  final FormType type;
  final String addressLabel;
  final String address;
  final double latitude;
  final double longitude;
  const AddressMapScreen({
    super.key,
    required this.type,
    required this.addressLabel,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  ConsumerState<AddressMapScreen> createState() => _AddressMapScreenState();
}

class _AddressMapScreenState extends ConsumerState<AddressMapScreen> {
  AddressMapController get controller =>
      ref.read(addressMapControllerProvider(context).notifier);

  @override
  void initState() {
    safeRebuild(
      () => controller.init(
        widget.type,
        widget.addressLabel,
        widget.address,
        widget.latitude,
        widget.longitude,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressMapControllerProvider(context));

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: LocaleKeys.text_pinLocation.tr(),
      ),
      child: Column(
        children: [
          Flexible(
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-6.2088, 106.8456), // Jakarta
                    zoom: 15,
                  ),
                  onCameraMove: controller.onCameraMove,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: controller.onMapCreated,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                ),
                Center(
                  child: Assets.images.mapPin.image(),
                )
              ],
            ),
          ),
          Container(
            padding: horizontalPadding.add(
              EdgeInsets.only(top: BaseSize.h12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.prefix_search.tr(namedArgs: {
                        "value": LocaleKeys.text_address.tr(),
                      }),
                      style: TypographyTheme.textLSemiBold.toNeutral80,
                    ),
                    ButtonWidget.textIcon(
                      onTap: () => controller.handleOnSearch(),
                      icon: Assets.icons.line.search.svg(
                        width: BaseSize.w24,
                        height: BaseSize.w24,
                      ),
                    ),
                  ],
                ),
                Gap.h20,
                CardWidget(
                  content: [
                    if (state.isLoading) ...[
                      ShimmerWidget(
                        height: BaseSize.h24,
                      ),
                      Gap.h12,
                      ShimmerWidget(
                        height: BaseSize.h28,
                      ),
                    ],
                    if (!state.isLoading)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Assets.icons.fill.mapPin.svg(
                            colorFilter: BaseColor.red.shade400.filterSrcIn,
                          ),
                          Gap.w8,
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.addressLabel ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      TypographyTheme.textMSemiBold.toNeutral60,
                                ),
                                Gap.h8,
                                Text(
                                  state.address ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      TypographyTheme.textMRegular.toNeutral60,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          Gap.h32,
          BottomActionWrapper(
            actionButton: ButtonWidget.primary(
              onTap: () => controller.handleOnSelect(),
              text: LocaleKeys.prefix_select.tr(
                namedArgs: {"value": LocaleKeys.text_location.tr()},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
