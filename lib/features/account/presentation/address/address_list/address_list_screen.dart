import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class AddressListScreen extends ConsumerStatefulWidget {
  const AddressListScreen({
    super.key,
    this.operationType,
    this.address,
  });

  final AddressListType? operationType;
  final UserAddress? address;

  @override
  ConsumerState<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends ConsumerState<AddressListScreen> {
  AddressListController get controller =>
      ref.read(addressListControllerProvider(context).notifier);

  @override
  void initState() {
    super.initState();
    if (widget.operationType != null) {
      safeRebuild(() => controller.setOperationType(widget.operationType!));
    }
  }

  Widget _emptyWidget() {
    return Padding(
      padding: horizontalPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.images.location.image(
            width: BaseSize.customHeight(100),
            height: BaseSize.customHeight(100),
          ),
          Gap.h16,
          Text(
            LocaleKeys.text_noAddressListedYet.tr(),
            style: TypographyTheme.textLBold.toNeutral80,
          ),
          Gap.h12,
          Text(
            "${LocaleKeys.text_addYourAddressNow.tr()} ${LocaleKeys.text_youCanRegisterMoreThanOneAddress.tr()}",
            style: TypographyTheme.textSRegular.toNeutral60,
            textAlign: TextAlign.center,
          ),
          Gap.h20,
          ButtonWidget.primary(
            text: LocaleKeys.text_addNewAddress.tr(),
            icon: Assets.icons.line.plus.svg(
              colorFilter: BaseColor.white.filterSrcIn,
            ),
            onTap: () => controller.handleAddNew(),
          ),
          Gap.h56,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressListControllerProvider(context));

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: state.type == AddressListType.basic
            ? LocaleKeys.prefix_list.tr(namedArgs: {
                "value": LocaleKeys.text_address.tr(),
              })
            : LocaleKeys.prefix_select.tr(namedArgs: {
                "value": LocaleKeys.text_address.tr(),
              }),
      ),
      child: Column(
        children: [
          Expanded(
            child: !state.isLoading && state.userAddresses.isEmpty
                ? _emptyWidget()
                : ListBuilderWidget<UserAddress>(
                    isLoading: state.isLoading,
                    padding: horizontalPadding.add(
                      EdgeInsets.symmetric(vertical: BaseSize.h20),
                    ),
                    onRefresh: () async {
                      await controller.getAddresses(isRefresh: true);
                    },
                    data: state.userAddresses,
                    separatorBuilder: (context, index) => Gap.h16,
                    postwidgets: [
                      Gap.h16,
                      ButtonWidget.text(
                        icon: Assets.icons.line.plus.svg(
                          colorFilter: BaseColor.primary3.filterSrcIn,
                        ),
                        text: LocaleKeys.text_addNewAddress.tr(),
                        onTap: () => controller.handleAddNew(),
                      )
                    ],
                    itemBuilder: (context, index, item) {
                      return AddressCardWidget(
                        label: item.label,
                        name: item.name,
                        phone: item.phone,
                        address: item.address,
                        isSelected: state.type == AddressListType.selection
                            ? item.serial == state.selectedAddress
                            : false,
                        isPrimary: item.isPrimary,
                        onDelete: () => controller.handleOnDelete(item.serial),
                        onEdit: () => controller.handleOnEdit(item.serial),
                        onTap: () => state.type == AddressListType.selection
                            ? controller.handleOnTap(
                                item.serial,
                                item.name,
                                item.address,
                              )
                            : controller.handleOnEdit(item.serial),
                        // TODO: Self checkin
                        outOfRange: false,
                      );
                    },
                  ),
          ),
          if (state.type == AddressListType.selection) ...[
            Gap.h12,
            BottomActionWrapper(
              actionButton: ButtonWidget.primary(
                text: LocaleKeys.text_select.tr(),
                onTap: controller.handleOnPopScreen,
              ),
            )
          ]
        ],
      ),
    );
  }
}
