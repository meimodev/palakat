import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

import 'widgets/widgets.dart';

class MainNotificationScreen extends ConsumerStatefulWidget {
  const MainNotificationScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MainNotificationScreenState();
}

class _MainNotificationScreenState
    extends ConsumerState<MainNotificationScreen> {
  MainNotificationController get controller =>
      ref.watch(mainNotificationControllerProvider.notifier);

  @override
  void initState() {
    safeRebuild(() => controller.init());
    super.initState();
  }

  Widget _emptyNotification() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Assets.icons.fill.notification.svg(
          width: BaseSize.customWidth(80),
          height: BaseSize.customWidth(80),
          colorFilter: BaseColor.warning.filterSrcIn,
        ),
        Gap.h20,
        Padding(
          padding: horizontalPadding,
          child: Text(
            LocaleKeys.text_weWillNotifyYouWhenSomethingArrives.tr(),
            style: TypographyTheme.textLRegular.toNeutral60,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainNotificationControllerProvider);

    return ScaffoldWidget(
      type: ScaffoldType.authGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap.customGapHeight(60),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w24),
            child: Text(
              LocaleKeys.text_notification.tr(),
              style: TypographyTheme.heading3Bold.toPrimary,
            ),
          ),
          Gap.h32,
          Expanded(
            child: state.notifications.isEmpty && !state.isLoading
                ? _emptyNotification()
                : ListBuilderWidget(
                    data: state.notifications,
                    isLoading: state.isLoading,
                    isLoadingBottom: state.hasMore,
                    onEdgeBottom: controller.handleGetMore,
                    onRefresh: () async => await controller.handleRefresh(),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index, notification) {
                      return ListItemNotificationCardWidget(
                        title: notification.title,
                        subTitle: notification.body,
                        isRead: notification.readAt != null,
                        time: notification.createdAt,
                        onTap: () => controller.handleRead(notification.serial),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
