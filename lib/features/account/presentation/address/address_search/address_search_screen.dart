import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class AddressSearchScreen extends ConsumerStatefulWidget {
  final AddressSearchType type;
  const AddressSearchScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<AddressSearchScreen> createState() =>
      _AddressSearchScreenState();
}

class _AddressSearchScreenState extends ConsumerState<AddressSearchScreen> {
  AddressSearchController get controller =>
      ref.read(addressSearchControllerProvider(context).notifier);

  @override
  void initState() {
    safeRebuild(() => controller.init(widget.type));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressSearchControllerProvider(context));

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: state.type == AddressSearchType.add
            ? LocaleKeys.prefix_addNew.tr(namedArgs: {
                "value": LocaleKeys.text_address.tr(),
              })
            : LocaleKeys.prefix_search.tr(namedArgs: {
                "value": LocaleKeys.text_address.tr(),
              }),
      ),
      child: LoadingWrapper(
        value: state.onGeocodingAddress,
        child: Column(
          children: [
            Gap.h16,
            Padding(
              padding: horizontalPadding,
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearch,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w12,
                    vertical: BaseSize.h8,
                  ),
                  prefixIcon: IconButton(
                    onPressed: null,
                    icon: Assets.icons.line.search.svg(
                      width: 20.0,
                      height: 20.0,
                      colorFilter: BaseColor.neutral.shade40.filterSrcIn,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.clearSearch();
                    },
                    icon: Assets.icons.line.times.svg(
                      width: 24.0,
                      height: 24.0,
                      colorFilter: BaseColor.neutral.shade40.filterSrcIn,
                    ),
                  ),
                  hintText: LocaleKeys.prefix_search.tr(namedArgs: {
                    "value": LocaleKeys.text_streetOrBuildingOrHouse.tr(),
                  }),
                  hintStyle: TextStyle(color: BaseColor.neutral.shade40),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                    borderSide: BorderSide(
                      color: BaseColor.neutral.shade30,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                    borderSide: const BorderSide(
                      color: BaseColor.primary3,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Gap.h8,
            Flexible(
              child: ListBuilderWidget<AutocompleteAddress>(
                data: state.address,
                prewidgets: [
                  RippleTouch(
                    onTap: controller.currentLocationChoosed,
                    child: Padding(
                      padding: horizontalPadding.add(
                        EdgeInsets.symmetric(vertical: BaseSize.h16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Assets.icons.fill.gps.svg(
                            colorFilter: BaseColor.primary3.filterSrcIn,
                          ),
                          Gap.w12,
                          Text(
                            LocaleKeys.text_useCurrentLocation.tr(),
                            style: TypographyTheme.textLSemiBold.toPrimary,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
                itemBuilder: (context, index, item) {
                  return RippleTouch(
                    onTap: () => controller.addressChoosed(item),
                    child: Padding(
                      padding: horizontalPadding.add(
                        EdgeInsets.symmetric(vertical: BaseSize.h12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Assets.icons.line.mapPin.svg(
                            colorFilter: BaseColor.neutral.shade80.filterSrcIn,
                          ),
                          Gap.w12,
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.addressLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      TypographyTheme.textMSemiBold.toNeutral80,
                                ),
                                Gap.h8,
                                Text(
                                  item.address,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      TypographyTheme.textMRegular.toNeutral60,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
