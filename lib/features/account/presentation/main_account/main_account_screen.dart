import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  MainAccountController get controller => ref.read(
        mainAccountControllerProvider(context).notifier,
      );

  Widget versionText(String? version) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        LocaleKeys.prefix_version.tr(
          namedArgs: {
            "value": version ?? '',
          },
        ),
        style: TypographyTheme.textSRegular.toNeutral50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainAccountControllerProvider(context));

    return ScaffoldWidget(
      type: ScaffoldType.accountGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap.h56,
          Padding(
            padding: horizontalPadding,
            child: Text(
              LocaleKeys.text_account.tr(),
              style: TypographyTheme.heading2Bold.fontColor(BaseColor.primary4),
            ),
          ),
          Expanded(
            child: ListBuilderWidget<AccountMenuModel>(
              data: controller.menus,
              padding: EdgeInsets.symmetric(vertical: BaseSize.h20),
              separatorBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: BaseSize.w56,
                  ),
                  child: Divider(
                    color: BaseColor.neutral.shade20,
                    height: 0,
                    indent: 0,
                    thickness: 1,
                  ),
                );
              },
              itemBuilder: (context, index, item) {
                return AccountMenuTile(
                  icon: item.icon,
                  title: item.title,
                  routeName: item.route,
                  onTap: item.onTap,
                );
              },
              prewidgets: [
                if (controller.isLoggedIn &&
                    (controller.user?.mustVerifiedEmail ?? false))
                  Padding(
                    padding: horizontalPadding,
                    child: ButtonWidget.primary(
                      buttonSize: ButtonSize.small,
                      text: LocaleKeys.text_resendEmailVerification.tr(),
                      isLoading: state.isLoadingResend,
                      onTap: controller.handleResendEmail,
                    ),
                  ),
              ],
              postwidgets: [
                if (!controller.isLoggedIn)
                  Padding(
                    padding: horizontalPadding.add(
                      EdgeInsets.symmetric(
                        vertical: BaseSize.h12,
                      ),
                    ),
                    child: ButtonWidget.primary(
                      text: LocaleKeys.text_login.tr(),
                      onTap: () => context.pushNamed(AppRoute.login),
                    ),
                  )
              ],
            ),
          ),
          versionText(state.version),
          Gap.h16,
        ],
      ),
    );
  }
}
