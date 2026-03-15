import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/account/presentations/membership/membership_motion_widget.dart';
import 'package:palakat/features/account/presentations/membership/widgets/church_request_bottom_sheet.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/models/models.dart' as model;
import 'package:palakat_shared/core/extension/extension.dart';
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
    final l10n = context.l10n;
    final controller = ref.read(membershipControllerProvider.notifier);
    final state = ref.watch(membershipControllerProvider);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      loading: state.loading,
      persistBottomWidget: MembershipReveal(
        delay: const Duration(milliseconds: 180),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: BaseSize.h24,
            left: BaseSize.w12,
            right: BaseSize.w12,
            top: BaseSize.h6,
          ),
          child: ButtonWidget.primary(
            text: l10n.btn_submit,
            onTap: () async {
              final result = await controller.submit();
              if (context.mounted) {
                result.when(
                  onSuccess: (_) {
                    context.goNamed(AppRoute.home);
                  },
                  onFailure: (failure) {
                    showSnackBar(context, failure.message);
                  },
                );
              }
            },
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MembershipReveal(
            child: ScreenTitleWidget.primary(
              title: l10n.membership_title,
              leadIcon: AppIcons.back,
              leadIconColor: BaseColor.textPrimary,
              onPressedLeadIcon: context.pop,
            ),
          ),
          Gap.h16,
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MembershipAnimatedPresence(
                    visible:
                        state.errorMessage != null &&
                        state.errorMessage!.trim().isNotEmpty,
                    child: Column(
                      children: [
                        ErrorDisplayWidget(
                          message: state.errorMessage ?? '',
                          padding: EdgeInsets.zero,
                          onRetry: () async {
                            if (widget.membershipId != null) {
                              await controller.fetchMembership(
                                widget.membershipId!,
                              );
                            }
                            await controller.fetchMyChurchRequest();
                          },
                        ),
                        Gap.h16,
                      ],
                    ),
                  ),
                  MembershipReveal(
                    delay: const Duration(milliseconds: 40),
                    child: Material(
                      color: BaseColor.cardBackground1,
                      elevation: 1,
                      shadowColor: Colors.black.withValues(alpha: 0.05),
                      surfaceTintColor: BaseColor.primary[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(BaseSize.w16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            MembershipReveal(
                              delay: const Duration(milliseconds: 80),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final shouldStack =
                                      constraints.maxWidth < 280 ||
                                      MediaQuery.textScalerOf(
                                            context,
                                          ).scale(1) >
                                          1.1;

                                  final icon = Container(
                                    width: BaseSize.w40,
                                    height: BaseSize.w40,
                                    decoration: BoxDecoration(
                                      color: BaseColor.primary[50],
                                      borderRadius: BorderRadius.circular(
                                        BaseSize.radiusMd,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      AppIcons.church,
                                      size: BaseSize.w18,
                                      color: BaseColor.primary,
                                    ),
                                  );

                                  final title = Text(
                                    l10n.membership_churchMembership_title,
                                    style: BaseTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: BaseColor.textPrimary,
                                    ),
                                    maxLines: shouldStack ? 2 : 1,
                                    overflow: TextOverflow.ellipsis,
                                  );

                                  if (shouldStack) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [icon, Gap.h12, title],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      icon,
                                      Gap.w12,
                                      Expanded(child: title),
                                    ],
                                  );
                                },
                              ),
                            ),
                            Gap.h16,
                            MembershipReveal(
                              delay: const Duration(milliseconds: 110),
                              child: _buildChurchRequestInfo(state, context),
                            ),
                            Gap.h12,
                            MembershipReveal(
                              delay: const Duration(milliseconds: 140),
                              child: InputWidget<model.Church>.dropdown(
                                label: l10n.nav_church,
                                hint: l10n.nav_church,
                                currentInputValue: state.church,
                                errorText: state.errorChurch,
                                endIcon: Icon(AppIcons.chevronDown, size: 20),
                                onChanged: controller.onChangedChurch,
                                optionLabel: (model.Church option) =>
                                    option.name,
                                onPressedWithResult: () async =>
                                    await showDialogChurchPickerWidget(
                                      context: context,
                                    ),
                              ),
                            ),
                            Gap.h12,
                            MembershipReveal(
                              delay: const Duration(milliseconds: 170),
                              child: InputWidget<model.Column>.dropdown(
                                label: l10n.lbl_selectColumn,
                                hint: state.church == null
                                    ? l10n.lbl_selectChurchFirst
                                    : l10n.lbl_selectColumn,
                                currentInputValue: state.column,
                                errorText: state.errorColumn,
                                endIcon: Icon(AppIcons.chevronDown, size: 20),
                                onChanged: controller.onChangedColumn,
                                optionLabel: (model.Column? option) =>
                                    option?.name ?? '',
                                onPressedWithResult: state.church == null
                                    ? null
                                    : () async =>
                                          await showDialogColumnPickerWidget(
                                            context: context,
                                            churchId: state.church!.id,
                                          ),
                              ),
                            ),
                            Gap.h12,
                            MembershipReveal(
                              delay: const Duration(milliseconds: 200),
                              child: InputWidget<bool>.binaryOption(
                                currentInputValue: state.baptize,
                                options: const [true, false],
                                label: l10n.lbl_baptized,
                                onChanged: controller.onChangedBaptize,
                                optionLabel: (bool option) => option
                                    ? l10n.lbl_baptized
                                    : l10n.membership_notBaptized,
                                errorText: state.errorBaptize,
                              ),
                            ),
                            Gap.h12,
                            MembershipReveal(
                              delay: const Duration(milliseconds: 230),
                              child: InputWidget<bool>.binaryOption(
                                currentInputValue: state.sidi,
                                options: const [true, false],
                                label: l10n.lbl_sidi,
                                onChanged: controller.onChangedSidi,
                                optionLabel: (bool option) => option
                                    ? l10n.lbl_sidi
                                    : l10n.membership_notSidi,
                                errorText: state.errorSidi,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Gap.h16,
                ],
              ),
            ),
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
        message: context.l10n.membership_churchNotRegisteredInfo,
        actionText: context.l10n.churchRequest_title,
        onActionPressed: () {
          _showChurchRequestBottomSheet(context);
        },
      );
    }

    // Church request exists - show status-based info
    switch (churchRequest.status) {
      case RequestStatus.todo:
        final date = churchRequest.createdAt?.EddMMMyyyy ?? context.l10n.lbl_na;
        return InfoBoxWidget(
          message: context.l10n.membership_churchRequestAcceptedOn(
            churchRequest.churchName,
            date,
          ),
        );
      case RequestStatus.doing:
        return InfoBoxWidget(
          message: context.l10n.membership_churchRequestProcessing(
            churchRequest.churchName,
          ),
        );
      case RequestStatus.done:
        return InfoBoxWidget(
          message: context.l10n.membership_churchRequestCompleted(
            churchRequest.churchName,
          ),
        );
      case RequestStatus.rejected:
        final note = churchRequest.decisionNote?.trim();
        final msg = (note == null || note.isEmpty)
            ? context.l10n.status_rejected
            : '${context.l10n.status_rejected} (${context.l10n.lbl_note}: $note)';
        return InfoBoxWithActionWidget(
          message: msg,
          actionText: context.l10n.churchRequest_submitRequest,
          onActionPressed: () {
            _showChurchRequestBottomSheet(
              context,
              initialRequest: churchRequest,
            );
          },
        );
    }
  }

  void showSnackBar(BuildContext context, String msg) {
    if (msg.trim().isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _showChurchRequestBottomSheet(
    BuildContext context, {
    model.ChurchRequest? initialRequest,
  }) {
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
          child: ChurchRequestBottomSheet(initialRequest: initialRequest),
        ),
      ),
    );
  }
}
