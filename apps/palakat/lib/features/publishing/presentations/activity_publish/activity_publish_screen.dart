import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/operations_controller.dart';
import 'package:palakat/features/operations/presentations/operations_motion_widget.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/widgets/input/file_picker_field.dart'
    as shared;

class ActivityPublishScreen extends ConsumerStatefulWidget {
  const ActivityPublishScreen({super.key, required this.type});

  final ActivityType type;

  @override
  ConsumerState<ActivityPublishScreen> createState() =>
      _ActivityPublishScreenState();
}

class _ActivityPublishScreenState extends ConsumerState<ActivityPublishScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref
          .read(activityPublishControllerProvider(widget.type).notifier)
          .fetchAuthorInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = activityPublishControllerProvider(widget.type);
    final controller = ref.read(provider.notifier);
    final state = ref.watch(provider);
    final l10n = context.l10n;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      canPop: !isKeyboardVisible,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ScaffoldWidget(
        loading: state.loading,
        persistBottomWidget: OperationsReveal(
          delay: const Duration(milliseconds: 180),
          child: _buildSubmitButton(state, controller),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OperationsReveal(
                child: ScreenTitleWidget.titleSecondary(
                  title: '${l10n.btn_create} ${state.type.displayName}',
                ),
              ),
              Gap.h16,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OperationsReveal(
                      delay: const Duration(milliseconds: 40),
                      child: _buildActivityTypeIndicator(state),
                    ),
                    Gap.h12,
                    OperationsReveal(
                      delay: const Duration(milliseconds: 60),
                      child: _buildPublisherSection(state),
                    ),
                    Gap.h16,
                    OperationsReveal(
                      delay: const Duration(milliseconds: 80),
                      child: _buildBasicInfoSection(state, controller, context),
                    ),
                    Gap.h16,
                    if (widget.type != ActivityType.announcement) ...[
                      OperationsReveal(
                        delay: const Duration(milliseconds: 100),
                        child: _buildLocationSection(
                          state,
                          controller,
                          context,
                        ),
                      ),
                      Gap.h16,
                      OperationsReveal(
                        delay: const Duration(milliseconds: 120),
                        child: _buildScheduleSection(
                          state,
                          controller,
                          context,
                        ),
                      ),
                      Gap.h16,
                      OperationsReveal(
                        delay: const Duration(milliseconds: 140),
                        child: _buildFinancialRecordSection(
                          state,
                          controller,
                          context,
                        ),
                      ),
                      Gap.h16,
                    ],
                    if (widget.type == ActivityType.announcement)
                      OperationsReveal(
                        delay: const Duration(milliseconds: 100),
                        child: _buildAnnouncementSection(
                          state,
                          controller,
                          context,
                        ),
                      ),
                    Gap.h24,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTypeIndicator(ActivityPublishState state) {
    final typeConfig = _getTypeConfig();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: typeConfig.backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: typeConfig.borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(typeConfig.icon, size: 18.0, color: typeConfig.iconColor),
              Gap.w8,
              Text(
                typeConfig.label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: typeConfig.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Text(
            state.currentDate ?? '',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  _TypeConfig _getTypeConfig() {
    switch (widget.type) {
      case ActivityType.service:
        return _TypeConfig(
          icon: AppIcons.church,
          label: widget.type.displayName,
          backgroundColor: AppColors.primary.shade100,
          borderColor: AppColors.primary.shade200,
          iconColor: AppColors.primary.shade700,
          textColor: AppColors.primary.shade700,
        );
      case ActivityType.event:
        return _TypeConfig(
          icon: AppIcons.event,
          label: widget.type.displayName,
          backgroundColor: AppColors.primary.shade100,
          borderColor: AppColors.primary.shade200,
          iconColor: AppColors.primary.shade700,
          textColor: AppColors.primary.shade700,
        );
      case ActivityType.announcement:
        return _TypeConfig(
          icon: AppIcons.announcement,
          label: widget.type.displayName,
          backgroundColor: AppColors.warning.shade100,
          borderColor: AppColors.warning.shade200,
          iconColor: AppColors.warning.shade700,
          textColor: AppColors.warning.shade700,
        );
    }
  }

  Widget _buildBasicInfoSection(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    return FormSectionWidget(
      title: context.l10n.section_basicInformation,
      icon: AppIcons.info,
      subtitle: context.l10n.publish_basicInfoSubtitle,
      children: [
        InputWidget<String>.text(
          hint: context.l10n.publish_hintEnterActivityTitle,
          label: context.l10n.lbl_title,
          currentInputValue: state.title,
          errorText: state.errorTitle,
          onChanged: controller.onChangedTitle,
        ),
        Gap.h12,
        _buildBipraPicker(state, controller, context),
        Gap.h12,
        _buildPublishToColumnOnlyToggle(state, controller, context),
      ],
    );
  }

  Widget _buildPublishToColumnOnlyToggle(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    final hasColumn =
        state.authorColumn != null && state.authorColumn!.isNotEmpty;
    final columnName = state.authorColumn;
    return Material(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: SwitchListTile(
        value: hasColumn ? state.publishToColumnOnly : false,
        onChanged: hasColumn ? controller.onChangedPublishToColumnOnly : null,
        title: Text(
          context.l10n.publish_publishToColumnOnly_title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        subtitle: Text(
          hasColumn
              ? '${context.l10n.publish_publishToColumnOnly_subtitle} (${columnName!})'
              : context.l10n.publish_publishToColumnOnly_subtitleNoColumn,
          style: Theme.of(context).textTheme.bodyMedium!.toSecondary,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }

  Widget _buildBipraPicker(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    final hasBipra = state.selectedBipra != null;
    final hasError = state.errorBipra != null && state.errorBipra!.isNotEmpty;
    final shouldShowColumnContext =
        state.publishToColumnOnly &&
        state.authorColumn != null &&
        state.authorColumn!.isNotEmpty;
    final columnContext = shouldShowColumnContext
        ? ' (${state.authorColumn!})'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${context.l10n.publish_targetAudienceBipra}$columnContext ',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap.h6,
        GestureDetector(
          onTap: () async {
            final res = await showDialogBipraPickerWidget(
              context: context,
              title: context.l10n.publish_selectTargetGroup,
              columnName: shouldShowColumnContext ? state.authorColumn : null,
            );
            if (!mounted) return;
            if (res != null) {
              ref
                  .read(activityPublishControllerProvider(widget.type).notifier)
                  .onSelectedBipra(res);
            }
          },
          child: Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: hasBipra
                  ? AppColors.secondaryContainer
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: hasError
                    ? AppColors.error.withValues(alpha: 0.5)
                    : hasBipra
                    ? AppColors.onSecondaryContainer.withValues(alpha: 0.16)
                    : AppColors.outlineVariant,
              ),
            ),
            child: hasBipra
                ? _buildSelectedBipraInfo(state.selectedBipra!, controller)
                : _buildEmptyBipraPlaceholder(),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Text(
              state.errorBipra!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyBipraPlaceholder() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: FaIcon(
            AppIcons.group,
            size: 20.0,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Gap.w12,
        Expanded(
          child: Text(
            context.l10n.lbl_general,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FaIcon(AppIcons.forward, size: 20.0, color: AppColors.onSurfaceVariant),
      ],
    );
  }

  Widget _buildSelectedBipraInfo(
    Bipra bipra,
    ActivityPublishController controller,
  ) {
    return Row(
      children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.onSecondaryContainer.withValues(alpha: 0.86),
                AppColors.onSecondaryContainer,
              ],
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            bipra.abv,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: AppColors.surfaceContainerLowest,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Gap.w12,
        Expanded(
          child: Text(
            bipra.name,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: () => controller.onSelectedBipra(null),
          icon: FaIcon(
            AppIcons.clear,
            size: 18.0,
            color: AppColors.onSecondaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    return FormSectionWidget(
      title: context.l10n.card_location_title,
      icon: AppIcons.locationOnOutlined,
      // subtitle: context.l10n.publish_locationSubtitle,
      children: [
        InputWidget<String>.text(
          hint: context.l10n.publish_hintLocationExample,
          label: context.l10n.publish_lblLocationName,
          currentInputValue: state.location,
          errorText: state.errorLocation,
          onChanged: controller.onChangedLocation,
        ),
        Gap.h12,
        _buildMapLocationPicker(state, controller, context),
      ],
    );
  }

  Widget _buildMapLocationPicker(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    final hasLocation = state.selectedMapLocation != null;
    final hasError =
        state.errorPinpointLocation != null &&
        state.errorPinpointLocation!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.publish_pinOnMapOptional,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap.h6,
        GestureDetector(
          onTap: () async {
            final Location? res = await context.pushNamed<Location?>(
              AppRoute.publishingMap,
              extra: RouteParam(
                params: {
                  RouteParamKey.mapOperationType: MapOperationType.pinPoint,
                  if (state.selectedMapLocation != null)
                    RouteParamKey.location: state.selectedMapLocation!.toJson(),
                },
              ),
            );
            if (!mounted) return;
            if (res != null) {
              ref
                  .read(activityPublishControllerProvider(widget.type).notifier)
                  .onSelectedMapLocation(res);
            }
          },
          child: Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: hasLocation
                  ? AppColors.primary.shade50
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: hasError
                    ? AppColors.error.withValues(alpha: 0.5)
                    : hasLocation
                    ? AppColors.primary.shade200
                    : AppColors.outlineVariant,
              ),
            ),
            child: hasLocation
                ? _buildSelectedLocationInfo(state.selectedMapLocation!)
                : _buildEmptyLocationPlaceholder(),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Text(
              state.errorPinpointLocation!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyLocationPlaceholder() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: FaIcon(
            AppIcons.mapOutlined,
            size: 20.0,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Gap.w12,
        Expanded(
          child: Text(
            context.l10n.publish_tapToSelectLocationOptional,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        FaIcon(AppIcons.forward, size: 20.0, color: AppColors.neutral),
      ],
    );
  }

  Widget _buildSelectedLocationInfo(Location location) {
    final hasCoordinates =
        location.latitude != null && location.longitude != null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.primary.shade100,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: FaIcon(
            AppIcons.locationOn,
            size: 20.0,
            color: AppColors.primary.shade700,
          ),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.publish_locationSelected,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.primary.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap.h4,
              Row(
                children: [
                  FaIcon(
                    AppIcons.myLocation,
                    size: 14.0,
                    color: AppColors.onSurfaceVariant,
                  ),
                  Gap.w4,
                  Expanded(
                    child: Text(
                      hasCoordinates
                          ? '${location.latitude!.toStringAsFixed(5)}, ${location.longitude!.toStringAsFixed(5)}'
                          : context.l10n.lbl_na,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        FaIcon(AppIcons.edit, size: 18.0, color: AppColors.primary),
      ],
    );
  }

  Widget _buildScheduleSection(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    return FormSectionWidget(
      title: context.l10n.section_schedule,
      icon: AppIcons.scheduleOutlined,
      // subtitle: context.l10n.publish_scheduleSubtitle,
      children: [
        _buildDateTimePickers(state, controller, context),
        Gap.h12,
        _buildReminderPicker(state, controller, context),
        Gap.h12,
        InputWidget<String>.text(
          label: '${context.l10n.lbl_note} ${context.l10n.lbl_optional}',
          hint: context.l10n.publish_hintAdditionalNotes,
          currentInputValue: state.note,
          errorText: state.errorNote,
          onChanged: controller.onChangedNote,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDateTimePickers(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildDatePicker(state, controller, context)),
          Gap.w12,
          Expanded(child: _buildTimePicker(state, controller, context)),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    final hasDate = state.selectedDate != null;
    final hasError = state.errorDate != null && state.errorDate!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () async {
            final res = await showDialogDatePickerWidget(
              context: context,
              firstDate: DateTime.now(),
              initialDate: state.selectedDate ?? DateTime.now(),
              initialDatePickerMode: DatePickerMode.day,
              lastDate: DateTime(DateTime.now().year + 5),
            );
            if (!mounted) return;
            if (res != null) {
              ref
                  .read(activityPublishControllerProvider(widget.type).notifier)
                  .onSelectedDate(res);
            }
          },
          child: Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: hasError
                    ? AppColors.error.withValues(alpha: 0.5)
                    : hasDate
                    ? AppColors.primary
                    : AppColors.neutral,
                width: hasDate ? 1.5 : 1,
              ),
              boxShadow: hasDate
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: hasDate ? AppColors.primary : AppColors.neutral,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.calendarToday,
                    size: 18.0,
                    color: hasDate ? AppColors.primary : AppColors.neutral,
                  ),
                ),
                Gap.h8,
                Text(
                  hasDate
                      ? _formatDateShort(context, state.selectedDate!)
                      : context.l10n.lbl_date,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: hasDate ? AppColors.primary : AppColors.neutral,
                    fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (hasDate) ...[
                  Gap.h4,
                  Text(
                    _formatDayOfWeek(context, state.selectedDate!),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Text(
              state.errorDate!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildTimePicker(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    final hasTime = state.selectedTime != null;
    final hasError = state.errorTime != null && state.errorTime!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () async {
            final res = await showDialogTimePickerWidget(
              context: context,
              initialTime: state.selectedTime,
            );
            if (!mounted) return;
            if (res != null) {
              ref
                  .read(activityPublishControllerProvider(widget.type).notifier)
                  .onSelectedTime(res);
            }
          },
          child: Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: hasError
                    ? AppColors.error.withValues(alpha: 0.5)
                    : hasTime
                    ? AppColors.primary
                    : AppColors.neutral,
                width: hasTime ? 1.5 : 1,
              ),
              boxShadow: hasTime
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: hasTime ? AppColors.primary : AppColors.neutral,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.accessTime,
                    size: 18.0,
                    color: hasTime ? AppColors.primary : AppColors.neutral,
                  ),
                ),
                Gap.h8,
                Text(
                  hasTime
                      ? _formatTime(context, state.selectedTime!)
                      : context.l10n.lbl_time,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: hasTime ? AppColors.primary : AppColors.neutral,
                    fontWeight: hasTime ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (hasTime) ...[
                  Gap.h4,
                  Text(
                    _getTimePeriod(context, state.selectedTime!),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Text(
              state.errorTime!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  String _formatDateShort(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return intl.DateFormat.MMMd(locale).format(date);
  }

  String _formatDayOfWeek(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return intl.DateFormat.EEEE(locale).format(date);
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  String _getTimePeriod(BuildContext context, TimeOfDay time) {
    final l10n = context.l10n;
    if (time.hour < 12) return l10n.timePeriod_morning;
    if (time.hour < 17) return l10n.timePeriod_afternoon;
    return l10n.timePeriod_evening;
  }

  String _getReminderLabel(BuildContext context, Reminder reminder) {
    final l10n = context.l10n;
    switch (reminder) {
      case Reminder.tenMinutes:
        return l10n.reminder_tenMinutes;
      case Reminder.thirtyMinutes:
        return l10n.reminder_thirtyMinutes;
      case Reminder.oneHour:
        return l10n.reminder_oneHour;
      case Reminder.twoHour:
        return l10n.reminder_twoHour;
    }
  }

  Widget _buildReminderPicker(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    final l10n = context.l10n;
    final options = <Reminder?>[null, ...Reminder.values];

    return InputWidget<Reminder?>.dropdown(
      label: '${l10n.lbl_reminder} ${l10n.lbl_optional}',
      hint: l10n.lbl_na,
      currentInputValue: state.selectedReminder,
      options: options,
      errorText: state.errorReminder,
      optionLabel: (r) =>
          r == null ? l10n.lbl_na : _getReminderLabel(context, r),
      onChanged: controller.onSelectedReminder,
      onPressedWithResult: () async {
        return await _showEnumBottomSheet<Reminder?>(
          context,
          title: l10n.lbl_reminder,
          options: options,
          current: state.selectedReminder,
          optionLabel: (r) =>
              r == null ? l10n.lbl_na : _getReminderLabel(context, r),
        );
      },
    );
  }

  static Future<T?> _showEnumBottomSheet<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required T current,
    required String Function(T) optionLabel,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...options.map(
                (o) => ListTile(
                  title: Text(optionLabel(o)),
                  trailing: o == current ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(context).pop<T>(o),
                ),
              ),
              SizedBox(height: 12.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementSection(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    return FormSectionWidget(
      title: context.l10n.section_announcementDetails,
      icon: AppIcons.article,
      subtitle: context.l10n.publish_announcementDetailsSubtitle,
      children: [
        InputWidget<String>.text(
          hint: context.l10n.publish_hintAnnouncement,
          label: context.l10n.lbl_description,
          currentInputValue: state.description,
          errorText: state.errorDescription,
          onChanged: controller.onChangedDescription,
          maxLines: 4,
        ),
        Gap.h12,
        _buildFileUploadField(state, controller),
      ],
    );
  }

  /// Builds the file upload field for announcements.
  /// Requirements: 5.21 - Opens file picker dialog when tapped
  Widget _buildFileUploadField(
    ActivityPublishState state,
    ActivityPublishController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${context.l10n.tbl_file} ${context.l10n.lbl_optional}',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap.h6,
        shared.FilePickerField(
          enabled: !state.loading,
          value: (state.file != null && state.file!.isNotEmpty)
              ? shared.FilePickerValue(
                  name: state.file!,
                  path: state.filePath,
                  bytes: state.fileBytes,
                  sizeBytes: state.fileSizeBytes,
                )
              : null,
          pickButtonLabel: context.l10n.publish_uploadFile,
          helperText: context.l10n.publish_supportedFileTypes,
          showImagePreview: false,
          showPickButtonWhenValueSelected: false,
          allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
          onChanged: (picked) {
            if (!mounted) {
              return;
            }
            final currentController = ref.read(
              activityPublishControllerProvider(widget.type).notifier,
            );
            if (picked == null) {
              currentController.clearSelectedFile();
              return;
            }
            currentController.onSelectedFile(
              fileName: picked.name,
              filePath: picked.path,
              fileBytes: picked.bytes,
              fileSizeBytes: picked.sizeBytes,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPublisherSection(ActivityPublishState state) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.neutral, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.person,
                    color: AppColors.onPrimary,
                    size: 20.0,
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.authorName ?? context.l10n.loading_please_wait,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                      ),
                      Gap.h4,
                      Row(
                        children: [
                          FaIcon(
                            AppIcons.church,
                            size: 12.0,
                            color: AppColors.onSurfaceVariant,
                          ),
                          Gap.w4,
                          Flexible(
                            child: Text(
                              state.churchName ?? '',
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: AppColors.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Positions
            if (state.authorPositions.isNotEmpty) ...[
              Gap.h8,
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: state.authorPositions.map((position) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.shade100,
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(color: AppColors.primary.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          AppIcons.badgeOutlined,
                          size: 12.0,
                          color: AppColors.primary.shade700,
                        ),
                        Gap.w4,
                        Text(
                          position,
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                color: AppColors.primary.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    ActivityPublishState state,
    ActivityPublishController controller,
  ) {
    // Requirements: 5.7, 5.8, 5.9 - Enable/disable submit button based on validation
    final isEnabled = state.isFormValid && !state.loading;

    return Material(
      color: AppColors.surfaceContainerLowest,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 12.0,
          left: 12.0,
          right: 12.0,
          top: 12.0,
        ),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.neutral, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: ButtonWidget.primary(
            text: '${context.l10n.btn_create} ${widget.type.displayName}',
            isLoading: state.loading,
            isEnabled: isEnabled,
            onTap: isEnabled ? () => _handleSubmit(controller) : null,
          ),
        ),
      ),
    );
  }

  /// Handles form submission.
  /// Requirements: 5.7, 5.8, 5.9 - Display error messages for empty fields
  Future<void> _handleSubmit(ActivityPublishController controller) async {
    final success = await controller.submit();
    if (!mounted) return;

    if (success) {
      // Invalidate operations controller to refresh supervised activities list
      ref.invalidate(operationsControllerProvider);
      context.pop();
      _showSnackBar(context.l10n.msg_created);
    } else {
      final state = ref.read(activityPublishControllerProvider(widget.type));
      // Show specific error message or generic validation message
      _showSnackBar(
        state.errorMessage ?? context.l10n.publish_fillAllRequiredFields,
      );
    }
  }

  void _showSnackBar(String message) {
    if (message.trim().isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  /// Builds the Financial Record section for service/event types.
  /// Shows "Add Financial Record" button when no finance attached,
  /// or FinanceSummaryCard when finance is attached.
  /// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5
  Widget _buildFinancialRecordSection(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    return FormSectionWidget(
      title: context.l10n.section_financialRecord,
      icon: AppIcons.accountBalanceWalletOutlined,
      subtitle: context.l10n.publish_financialRecordSubtitle,
      children: [
        if (state.attachedFinances.isNotEmpty)
          ...List.generate(state.attachedFinances.length, (index) {
            final finance = state.attachedFinances[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == state.attachedFinances.length - 1 ? 0 : 12.0,
              ),
              child: FinanceSummaryCard(
                financeData: finance,
                onRemove: () =>
                    _handleRemoveFinance(controller, context, index),
                onEdit: () =>
                    _handleEditFinance(state, controller, context, index),
              ),
            );
          }),
        if (state.attachedFinances.isNotEmpty) Gap.h12,
        _buildAddFinanceButton(controller, context),
      ],
    );
  }

  /// Builds the "Add Financial Record" button.
  /// Requirements: 1.2
  Widget _buildAddFinanceButton(
    ActivityPublishController controller,
    BuildContext context,
  ) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.neutral, width: 1),
      ),
      child: InkWell(
        onTap: () => _handleAddFinance(controller, context),
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: FaIcon(
                  AppIcons.add,
                  size: 20.0,
                  color: AppColors.onPrimary,
                ),
              ),
              Gap.w12,
              Text(
                context.l10n.publish_addFinancialRecord,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles the "Add Financial Record" button tap.
  /// Shows the Finance Type Picker dialog and navigates to Finance Create Screen.
  /// Requirements: 1.2, 1.3
  Future<void> _handleAddFinance(
    ActivityPublishController controller,
    BuildContext context,
  ) async {
    // Step 1: Show Finance Type Picker dialog
    final financeType = await showFinanceTypePickerDialog(context: context);
    if (financeType == null || !mounted) return;

    // Step 2: Navigate to Finance Create Screen in embedded mode
    if (!mounted) return;
    final financeData = await Navigator.of(this.context).push<FinanceData>(
      MaterialPageRoute(
        builder: (ctx) =>
            FinanceCreateScreen(financeType: financeType, isStandalone: false),
      ),
    );

    // Step 3: Handle returned finance data
    if (financeData != null && mounted) {
      ref
          .read(activityPublishControllerProvider(widget.type).notifier)
          .addAttachedFinance(financeData);
    }
  }

  /// Handles editing an attached finance record.
  /// Requirements: 1.1, 1.2, 1.3
  Future<void> _handleEditFinance(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
    int index,
  ) async {
    if (index < 0 || index >= state.attachedFinances.length) return;
    final currentFinance = state.attachedFinances[index];

    // Navigate to Finance Create Screen with current finance data for pre-population
    // Requirements: 1.1, 1.2, 1.3 - Pass existing finance data as initialData
    final financeData = await Navigator.of(context).push<FinanceData>(
      MaterialPageRoute(
        builder: (context) => FinanceCreateScreen(
          financeType: currentFinance.type,
          isStandalone: false,
          initialData: currentFinance,
        ),
      ),
    );

    // Update with new finance data if returned
    if (financeData != null && mounted) {
      ref
          .read(activityPublishControllerProvider(widget.type).notifier)
          .updateAttachedFinance(index, financeData);
    }
  }

  /// Shows confirmation dialog before removing attached financial record.
  /// Requirements: 3.1, 3.2, 3.3, 3.4
  Future<void> _handleRemoveFinance(
    ActivityPublishController controller,
    BuildContext context,
    int index,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.publish_removeFinancialRecordTitle),
        content: Text(context.l10n.publish_removeFinancialRecordContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.btn_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(context.l10n.btn_remove),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref
          .read(activityPublishControllerProvider(widget.type).notifier)
          .removeAttachedFinanceAt(index);
    }
  }
}

class _TypeConfig {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  _TypeConfig({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}
