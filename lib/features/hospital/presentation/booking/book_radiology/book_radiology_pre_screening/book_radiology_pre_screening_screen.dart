import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

final List<BookPreScreeningModel> _questionnaires = [
  BookPreScreeningModel(
    question: 'Do you feel a sore throat',
    correctAnswer: false,
    answer: null,
  ),
  BookPreScreeningModel(
    question: 'Do you feel cough',
    correctAnswer: false,
    answer: null,
  ),
  BookPreScreeningModel(
    question: 'Do you feel short of breath or difficulty breathing?',
    correctAnswer: false,
    answer: null,
  ),
  BookPreScreeningModel(
    question: 'Do you feel fatigue',
    correctAnswer: false,
    answer: null,
  ),
];

class BookRadiologyPreScreening extends ConsumerWidget {
  const BookRadiologyPreScreening({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookRadiologyPreScreeningProvider);
    final controller = ref.watch(bookRadiologyPreScreeningProvider.notifier);

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_preScreening.tr(),
      ),
      child: BookPreScreeningScreenWidget(
        questionnaires: _questionnaires,
        onChangedQuestionnaireValue: (int index, bool value) {
          _questionnaires[index].answer = value;
          bool eligible =
              _questionnaires.indexWhere((element) => element.answer == null) ==
                  -1;
          controller.changeEligibility(eligible);
        },
        disableSubmitButton: !state.isEligible,
        onTapSubmit: () => context.pushNamed(AppRoute.bookPreScreeningRejected),
      ),
    );
  }
}
