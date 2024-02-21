import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/presentation.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(helpControllerProvider.notifier);
    final state = ref.watch(helpControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: LocaleKeys.text_help.tr(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: BaseSize.h20),
        child: Column(
          children: [
            SizedBox(
              height: BaseSize.h36,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final tag = controller.tags[index];
                  return ChipsWidget(
                    onTap: () => controller.setSelectedTag(tag),
                    title: tag,
                    isSelected: tag == state.selectedTag,
                  );
                },
                separatorBuilder: (context, index) {
                  return Gap.w8;
                },
                itemCount: controller.tags.length,
                padding: horizontalPadding,
              ),
            ),
            Gap.h12,
            Expanded(
              child: SingleChildScrollView(
                padding: horizontalPadding.add(EdgeInsets.symmetric(
                  vertical: BaseSize.h8,
                )),
                physics: const BouncingScrollPhysics(),
                child: HelpAccordionWidget(data: controller.questions),
              ),
            ),
            Padding(
              padding: horizontalPadding,
              child: Row(
                children: [
                  Expanded(
                    child: ButtonWidget.primary(
                      icon: Assets.icons.fill.mail.svg(
                        colorFilter: BaseColor.white.filterSrcIn,
                      ),
                      text: LocaleKeys.text_email.tr(),
                      isShrink: true,
                      onTap: () {},
                    ),
                  ),
                  Gap.w16,
                  Expanded(
                    child: ButtonWidget.primary(
                      icon: Assets.icons.fill.phone.svg(
                        colorFilter: BaseColor.white.filterSrcIn,
                      ),
                      text: LocaleKeys.text_phone.tr(),
                      isShrink: true,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
