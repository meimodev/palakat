import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/authentication/presentations/widgets/phone_input_formatter.dart';
import 'package:palakat/features/operations/presentations/members/member_create_controller.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/extension/extension.dart';

class MemberCreateScreen extends ConsumerWidget {
  const MemberCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(memberCreateControllerProvider);
    final controller = ref.read(memberCreateControllerProvider.notifier);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.titleSecondary(
            title: l10n.operationsItem_new_member_title,
            subTitle: state.scopeLabel,
            onBack: () => context.pop(),
          ),
          Gap.h16,
          if (state.errorMessage != null &&
              state.errorMessage!.trim().isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: BaseSize.h12),
              child: ErrorDisplayWidget(message: state.errorMessage!),
            ),
          InfoBoxWidget(message: l10n.operationsItem_new_member_desc),
          Gap.h16,
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: BaseSize.h16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard(
                    context,
                    icon: AppIcons.person,
                    title: l10n.section_basicInformation,
                    children: [
                      InputWidget.text(
                        label: l10n.lbl_name,
                        hint: l10n.hint_enterMemberName,
                        currentInputValue: state.name,
                        errorText: state.errorName,
                        onChanged: controller.setName,
                      ),
                      Gap.h12,
                      InputWidget.text(
                        label: '${l10n.lbl_phone} ${l10n.lbl_optional}',
                        hint: l10n.auth_phoneHint,
                        currentInputValue: state.phone,
                        errorText: state.errorPhone,
                        textInputType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          PhoneInputFormatter(),
                        ],
                        onChanged: controller.setPhone,
                      ),
                      Gap.h12,
                      InputWidget.text(
                        label: '${l10n.lbl_email} ${l10n.lbl_optional}',
                        hint: l10n.hint_enterEmailAddress,
                        currentInputValue: state.email,
                        errorText: state.errorEmail,
                        textInputType: TextInputType.emailAddress,
                        onChanged: controller.setEmail,
                      ),
                      Gap.h12,
                      InputWidget<DateTime>.dropdown(
                        label: l10n.lbl_dateOfBirth,
                        hint: l10n.lbl_dateOfBirth,
                        currentInputValue: state.dob,
                        errorText: state.errorDob,
                        endIcon: Icon(AppIcons.calendar, size: 20),
                        optionLabel: (DateTime option) => option.ddMmmmYyyy,
                        onChanged: controller.setDob,
                        onPressedWithResult: () async =>
                            await showDialogDatePickerWidget(
                              context: context,
                              initialDate: state.dob ?? DateTime(1990),
                              initialDatePickerMode: DatePickerMode.year,
                            ),
                      ),
                      Gap.h12,
                      InputWidget<Gender>.binaryOption(
                        label: l10n.lbl_gender,
                        currentInputValue: state.gender,
                        options: Gender.values,
                        errorText: state.errorGender,
                        onChanged: controller.setGender,
                        optionLabel: (Gender option) => switch (option) {
                          Gender.male => l10n.gender_male,
                          Gender.female => l10n.gender_female,
                        },
                      ),
                      Gap.h12,
                      InputWidget<MaritalStatus>.binaryOption(
                        label: l10n.lbl_maritalStatus,
                        currentInputValue: state.maritalStatus,
                        options: MaritalStatus.values,
                        errorText: state.errorMaritalStatus,
                        onChanged: controller.setMaritalStatus,
                        optionLabel: (MaritalStatus option) => switch (option) {
                          MaritalStatus.single => l10n.maritalStatus_single,
                          MaritalStatus.married => l10n.maritalStatus_married,
                        },
                      ),
                    ],
                  ),
                  Gap.h12,
                  _buildSectionCard(
                    context,
                    icon: AppIcons.church,
                    title: l10n.settings_membershipSettings,
                    children: [
                      _buildInfoRow(
                        icon: AppIcons.church,
                        label: l10n.lbl_churchName,
                        value: (state.churchName?.trim().isNotEmpty == true)
                            ? state.churchName!.trim()
                            : l10n.lbl_na,
                      ),
                      Gap.h12,
                      _buildInfoRow(
                        icon: AppIcons.grid,
                        label: l10n.lbl_columnName,
                        value: (state.columnName?.trim().isNotEmpty == true)
                            ? state.columnName!.trim()
                            : l10n.lbl_na,
                      ),
                      Gap.h12,
                      InputWidget<bool>.binaryOption(
                        currentInputValue: state.baptize,
                        options: const [true, false],
                        label: l10n.lbl_baptized,
                        onChanged: controller.setBaptize,
                        optionLabel: (bool option) => option
                            ? l10n.lbl_baptized
                            : l10n.membership_notBaptized,
                      ),
                      Gap.h12,
                      InputWidget<bool>.binaryOption(
                        currentInputValue: state.sidi,
                        options: const [true, false],
                        label: l10n.lbl_sidi,
                        onChanged: controller.setSidi,
                        optionLabel: (bool option) =>
                            option ? l10n.lbl_sidi : l10n.membership_notSidi,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Gap.h12,
          ButtonWidget.primary(
            text: l10n.btn_create,
            isLoading: state.isSubmitting,
            onTap: state.isSubmitting
                ? null
                : () async {
                    final ok = await controller.submit();
                    if (!context.mounted) return;
                    if (ok) {
                      _showSnackBar(context, l10n.msg_created);
                      context.pop(true);
                      return;
                    }
                    _showSnackBar(
                      context,
                      state.errorMessage ?? l10n.publish_fillAllRequiredFields,
                    );
                  },
          ),
          Gap.h16,
        ],
      ),
    );
  }

  static Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: BaseSize.w28,
          height: BaseSize.w28,
          decoration: BoxDecoration(
            color: BaseColor.primary[50],
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: BaseSize.w14, color: BaseColor.primary[700]),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: BaseTypography.bodySmall.copyWith(
                  color: BaseColor.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap.h4,
              Text(
                value,
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w32,
                  height: BaseSize.w32,
                  decoration: BoxDecoration(
                    color: BaseColor.blue[100],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: BaseSize.w16,
                    color: BaseColor.blue[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    title,
                    style: BaseTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
            ...children,
          ],
        ),
      ),
    );
  }

  static void _showSnackBar(BuildContext context, String msg) {
    if (msg.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
