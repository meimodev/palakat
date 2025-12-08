import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/account/presentations/membership/widgets/church_request_bottom_sheet.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/models/models.dart' as model;
import 'package:palakat_shared/extensions.dart';

class MembershipScreen extends ConsumerStatefulWidget {
  final int? membershipId;

  const MembershipScreen({super.key, this.membershipId});

  @override
  ConsumerState<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends ConsumerState<MembershipScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch membership data if membershipId is provided
    if (widget.membershipId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(membershipControllerProvider.notifier)
            .fetchMembership(widget.membershipId!);
      });
    }

    // Fetch church request status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(membershipControllerProvider.notifier).fetchMyChurchRequest();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(membershipControllerProvider.notifier);
    final state = ref.watch(membershipControllerProvider);

    return ScaffoldWidget(
      loading: state.loading,
      persistBottomWidget: Padding(
        padding: EdgeInsets.only(
          bottom: BaseSize.h24,
          left: BaseSize.w12,
          right: BaseSize.w12,
          top: BaseSize.h6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.primary(
            title: "Membership",
            leadIcon: AppIcons.back,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h16,
          Material(
            color: BaseColor.cardBackground1,
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            surfaceTintColor: BaseColor.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                          AppIcons.church,
                          size: BaseSize.w16,
                          color: BaseColor.blue[700],
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: Text(
                          "Church Membership",
                          style: BaseTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BaseColor.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap.h16,
                  _buildChurchRequestInfo(state, context),
                  Gap.h12,
                  InputWidget<model.Church>.dropdown(
                    label: "identify your church",
                    hint: "Church",
                    currentInputValue: state.church,
                    errorText: state.errorChurch,
                    endIcon: Icon(AppIcons.chevronDown, size: 20),
                    onChanged: controller.onChangedChurch,
                    optionLabel: (model.Church option) => option.name,
                    onPressedWithResult: () async =>
                        await showDialogChurchPickerWidget(context: context),
                  ),
                  Gap.h12,
                  InputWidget<model.Column>.dropdown(
                    label: "identify your column",
                    hint: state.church == null
                        ? "Select church first"
                        : "Column",
                    currentInputValue: state.column,
                    errorText: state.errorColumn,
                    endIcon: Icon(AppIcons.chevronDown, size: 20),
                    onChanged: controller.onChangedColumn,
                    optionLabel: (model.Column? option) => option?.name ?? '',
                    onPressedWithResult: state.church == null
                        ? null
                        : () async => await showDialogColumnPickerWidget(
                            context: context,
                            churchId: state.church!.id,
                          ),
                  ),
                  Gap.h12,
                  InputWidget<bool>.binaryOption(
                    currentInputValue: state.baptize,
                    options: const [true, false],
                    label: "Baptize status",
                    onChanged: controller.onChangedBaptize,
                    optionLabel: (bool option) =>
                        option ? "BAPTIZE" : "NOT BAPTIZE",
                    errorText: state.errorBaptize,
                  ),
                  Gap.h12,
                  InputWidget<bool>.binaryOption(
                    currentInputValue: state.sidi,
                    options: const [true, false],
                    label: "Sidi status",
                    onChanged: controller.onChangedSidi,
                    optionLabel: (bool option) => option ? "SIDI" : "NOT SIDI",
                    errorText: state.errorSidi,
                  ),
                ],
              ),
            ),
          ),
          Gap.h16,
          ButtonWidget.primary(
            text: "Submit",
            onTap: () async {
              final result = await controller.submit();
              if (context.mounted) {
                result.when(
                  onSuccess: (_) {
                    // Navigate to home on success
                    context.goNamed(AppRoute.home);
                  },
                  onFailure: (failure) {
                    showSnackBar(context, failure.message);
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChurchRequestInfo(MembershipState state, BuildContext context) {
    // Show loading if we haven't checked yet
    if (!state.hasCheckedChurchRequest) {
      return const SizedBox.shrink();
    }

    final churchRequest = state.churchRequest;

    // No church request exists - show the default info box
    if (churchRequest == null) {
      return InfoBoxWithActionWidget(
        message:
            "If your church is not registered in our system, you won't be able to find it in the list below.",
        actionText: "Request Church Registration",
        onActionPressed: () {
          context.pop(); // Close membership screen
          _showChurchRequestBottomSheet(context);
        },
      );
    }

    // Church request exists - show status-based info
    switch (churchRequest.status) {
      case RequestStatus.todo:
        return InfoBoxWidget(
          message:
              "Your church registration request for '${churchRequest.churchName}' is been accepted on ${churchRequest.createdAt?.EddMMMyyyy}, We'll notify you once it's processed.",
        );
      case RequestStatus.doing:
        return InfoBoxWidget(
          message:
              "YAY! Your church registration request for '${churchRequest.churchName}' is being processed.",
        );
      case RequestStatus.done:
        return InfoBoxWidget(
          message:
              "Thanks to you, '${churchRequest.churchName}' now can be selected from the list below. Enjoy  ",
        );
    }
  }

  void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showChurchRequestBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: const ChurchRequestBottomSheet(),
        ),
      ),
    );
  }
}
