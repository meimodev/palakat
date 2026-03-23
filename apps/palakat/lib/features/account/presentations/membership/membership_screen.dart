import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
            bottom: 24.0,
            left: 12.0,
            right: 12.0,
            top: 6.0,
          ),
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
              side: BorderSide(color: AppColors.ghostBorder(0.08)),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(
                  SanctuaryLayout.radiusLarge,
                ),
                boxShadow: SanctuaryDepth.ambient(opacity: 0.04, blur: 24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      border: Border.all(color: AppColors.ghostBorder(0.06)),
                      borderRadius: BorderRadius.circular(
                        SanctuaryLayout.radius,
                      ),
                      boxShadow: SanctuaryDepth.ambient(
                        opacity: 0.02,
                        blur: 10,
                      ),
                    ),
                    child: Text(
                      l10n.membership_churchMembership_title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Gap.h12,
                  ButtonWidget.primary(
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
                ],
              ),
            ),
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
              leadIconColor: AppColors.onSurface,
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
                  MembershipReveal(
                    delay: const Duration(milliseconds: 20),
                    child: _buildHeroPanel(context, state),
                  ),
                  Gap.h16,
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        border: Border.all(color: AppColors.ghostBorder(0.08)),
                        borderRadius: BorderRadius.circular(
                          SanctuaryLayout.radiusLarge,
                        ),
                        boxShadow: SanctuaryDepth.ambient(
                          opacity: 0.035,
                          blur: 28,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
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
                                    width: 44.0,
                                    height: 44.0,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLow,
                                      border: Border.all(
                                        color: AppColors.ghostBorder(0.06),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        SanctuaryLayout.radius,
                                      ),
                                      boxShadow: SanctuaryDepth.ambient(
                                        opacity: 0.02,
                                        blur: 10,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.church_rounded,
                                      size: 20.0,
                                      color: AppColors.primary,
                                    ),
                                  );

                                  final title = Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.membership_churchMembership_title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurface,
                                            ),
                                        maxLines: shouldStack ? 2 : 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Gap.h4,
                                      Text(
                                        l10n.membership_title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
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

  Widget _buildHeroPanel(BuildContext context, MembershipState state) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
        side: BorderSide(color: AppColors.ghostBorder(0.08)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border.all(color: AppColors.ghostBorder(0.06)),
                borderRadius: BorderRadius.circular(
                  SanctuaryLayout.radiusLarge,
                ),
                boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                color: AppColors.primary,
              ),
            ),
            Gap.h16,
            Text(
              l10n.membership_title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap.h8,
            Text(
              l10n.membership_churchMembership_title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Gap.h20,
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildSummaryChip(
                  context,
                  icon: Icons.apartment_outlined,
                  label: l10n.nav_church,
                  value: state.church?.name ?? l10n.lbl_notSpecified,
                ),
                _buildSummaryChip(
                  context,
                  icon: Icons.account_tree_outlined,
                  label: l10n.lbl_selectColumn,
                  value: state.column?.name ?? l10n.lbl_notSpecified,
                ),
                _buildSummaryChip(
                  context,
                  icon: Icons.pending_outlined,
                  label: l10n.section_status,
                  value: _membershipStatusLabel(context, state),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.ghostBorder(0.06)),
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border.all(color: AppColors.ghostBorder(0.06)),
              borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
              boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          Gap.w10,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Gap.h2,
                Text(
                  value,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _membershipStatusLabel(BuildContext context, MembershipState state) {
    final l10n = context.l10n;

    if (state.churchRequest != null) {
      switch (state.churchRequest!.status) {
        case RequestStatus.todo:
          return l10n.status_pending;
        case RequestStatus.doing:
          return l10n.jobStatus_processing;
        case RequestStatus.done:
          return l10n.status_completed;
        case RequestStatus.rejected:
          return l10n.status_rejected;
      }
    }

    if (state.membership != null) {
      return l10n.status_completed;
    }

    return l10n.lbl_notSpecified;
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

    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 16),
          ),
          child: Row(
            children: [
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.18),
                  ),
                  borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.error,
                  size: 14.0,
                  color: AppColors.error,
                ),
              ),
              Gap.w12,
              Expanded(
                child: Text(
                  msg,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
