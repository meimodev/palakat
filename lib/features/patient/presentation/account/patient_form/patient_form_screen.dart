import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientFormScreen extends ConsumerStatefulWidget {
  const PatientFormScreen({
    super.key,
  });

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  PatientFormController get controller =>
      ref.read(patientFormControllerProvider.notifier);

  @override
  void initState() {
    safeRebuild(
      () {
        controller.init(context);
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientFormControllerProvider);

    var title = state.patientType == PatientType.withNoMrn
        ? LocaleKeys.text_registration.tr()
        : LocaleKeys.prefix_addNew.tr(namedArgs: {
            "value": LocaleKeys.text_patient.tr(),
          });

    return ScaffoldWidget(
      resizeToAvoidBottomInset: true,
      appBar: AppBarWidget(
        title: title,
      ),
      child: LoadingWrapper(
          value: state.isFetchingInitialData,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: BaseSize.h16),
            child: state.patientType == PatientType.withNoMrn
                ? const PatientFormWidget()
                : const PatientMedicalRecordFormWidget(),
          )),
    );
  }
}
