import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  List<Widget> _buildList(
    List<LanguageKey> languages,
    LanguageKey currentLanguage,
    Function(LanguageKey newValue) onSetlanguage,
  ) {
    return languages
        .map(
          (e) => LanguageRadioTileWidget<LanguageKey>(
            value: e,
            groupValue: currentLanguage,
            onTap: (newValue) => onSetlanguage(newValue),
            label: e.label.tr(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(languageControllerProvider(context).notifier);
    final state = ref.watch(languageControllerProvider(context));

    return ScaffoldWidget(
        appBar: AppBarWidget(
          title: LocaleKeys.text_language.tr(),
        ),
        child: LoadingWrapper(
          value: state.isLoading,
          child: Padding(
            padding: horizontalPadding.add(
              EdgeInsets.symmetric(vertical: BaseSize.h20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildList(
                      controller.languageSetting,
                      state.language,
                      controller.setLanguage,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ButtonWidget.outlined(
                        text: LocaleKeys.text_cancel.tr(),
                        isShrink: true,
                        onTap: () => context.pop(),
                      ),
                    ),
                    Gap.w16,
                    Expanded(
                      child: ButtonWidget.primary(
                        text: LocaleKeys.text_submit.tr(),
                        isShrink: true,
                        onTap: () => controller.saveLanguage(),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
