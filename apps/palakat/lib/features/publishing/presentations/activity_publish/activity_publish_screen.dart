import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/operations_controller.dart';
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

    return ScaffoldWidget(
      loading: state.loading,
      persistBottomWidget: _buildSubmitButton(state, controller),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenTitleWidget.titleSecondary(
              title: '${l10n.btn_create} ${state.type.displayName}',
            ),
            Gap.h16,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActivityTypeIndicator(),
                  Gap.h12,
                  _buildPublisherSection(state),
                  Gap.h16,
                  _buildBasicInfoSection(state, controller, context),
                  Gap.h16,
                  if (widget.type != ActivityType.announcement) ...[
                    _buildLocationSection(state, controller, context),
                    Gap.h16,
                    _buildScheduleSection(state, controller, context),
                    Gap.h16,
                    // Financial Record section for service/event types
                    // Requirements: 1.1, 1.2, 1.3, 1.4, 1.5
                    _buildFinancialRecordSection(state, controller, context),
                    Gap.h16,
                  ],
                  if (widget.type == ActivityType.announcement)
                    _buildAnnouncementSection(state, controller, context),
                  Gap.h24,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTypeIndicator() {
    final typeConfig = _getTypeConfig();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w12,
        vertical: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: typeConfig.backgroundColor,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: typeConfig.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeConfig.icon,
            size: BaseSize.w18,
            color: typeConfig.iconColor,
          ),
          Gap.w8,
          Text(
            typeConfig.label,
            style: BaseTypography.titleMedium.copyWith(
              color: typeConfig.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _TypeConfig _getTypeConfig() {
    switch (widget.type) {
      case ActivityType.service:
        return _TypeConfig(
          icon: AppIcons.church,
          label: widget.type.displayName,
          backgroundColor: BaseColor.primary[50]!,
          borderColor: BaseColor.primary[200]!,
          iconColor: BaseColor.primary[700]!,
          textColor: BaseColor.primary[700]!,
        );
      case ActivityType.event:
        return _TypeConfig(
          icon: AppIcons.event,
          label: widget.type.displayName,
          backgroundColor: BaseColor.blue[50]!,
          borderColor: BaseColor.blue[200]!,
          iconColor: BaseColor.blue[700]!,
          textColor: BaseColor.blue[700]!,
        );
      case ActivityType.announcement:
        return _TypeConfig(
          icon: AppIcons.announcement,
          label: widget.type.displayName,
          backgroundColor: BaseColor.yellow[50]!,
          borderColor: BaseColor.yellow[200]!,
          iconColor: BaseColor.yellow[700]!,
          textColor: BaseColor.yellow[700]!,
        );
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    String? subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.white,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: BaseColor.neutral[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          Container(
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: BaseColor.neutral[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(BaseSize.radiusMd),
                topRight: Radius.circular(BaseSize.radiusMd),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(BaseSize.w6),
                  decoration: BoxDecoration(
                    color: BaseColor.primary[50],
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    size: BaseSize.w16,
                    color: BaseColor.primary[600],
                  ),
                ),
                Gap.w8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: BaseTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BaseColor.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        Gap.h4,
                        Text(
                          subtitle,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.neutral[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Section content
          Padding(
            padding: EdgeInsets.all(BaseSize.w12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    return _buildSectionCard(
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
      color: BaseColor.primary[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: BaseColor.primary[200] ?? BaseColor.neutral40),
      ),
      child: SwitchListTile(
        value: hasColumn ? state.publishToColumnOnly : false,
        onChanged: hasColumn ? controller.onChangedPublishToColumnOnly : null,
        title: Text(
          context.l10n.publish_publishToColumnOnly_title,
          style: BaseTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: BaseColor.black,
          ),
        ),
        subtitle: Text(
          hasColumn
              ? '${context.l10n.publish_publishToColumnOnly_subtitle} (${columnName!})'
              : context.l10n.publish_publishToColumnOnly_subtitleNoColumn,
          style: BaseTypography.bodySmall.toSecondary,
        ),
        activeColor: BaseColor.primary[700],
        contentPadding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h8,
        ),
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
          '${context.l10n.publish_targetAudienceBipra}$columnContext ${context.l10n.lbl_optional}',
          style: BaseTypography.titleMedium.copyWith(
            color: BaseColor.neutral[800],
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
            if (res != null) {
              controller.onSelectedBipra(res);
            }
          },
          child: Container(
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: hasBipra ? BaseColor.teal[50] : BaseColor.white,
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              border: Border.all(
                color: hasError
                    ? BaseColor.error.withValues(alpha: 0.5)
                    : hasBipra
                    ? BaseColor.teal[200]!
                    : BaseColor.neutral[300]!,
              ),
            ),
            child: hasBipra
                ? _buildSelectedBipraInfo(state.selectedBipra!, controller)
                : _buildEmptyBipraPlaceholder(),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: BaseSize.customHeight(3)),
            child: Text(
              state.errorBipra!,
              textAlign: TextAlign.center,
              style: BaseTypography.bodySmall.copyWith(color: BaseColor.error),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyBipraPlaceholder() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(BaseSize.w8),
          decoration: BoxDecoration(
            color: BaseColor.neutral[100],
            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          ),
          child: FaIcon(
            AppIcons.group,
            size: BaseSize.w20,
            color: BaseColor.neutral[500],
          ),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.lbl_general,
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.neutral[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap.h4,
              Text(
                context.l10n.publish_targetGroup,
                style: BaseTypography.bodySmall.copyWith(
                  color: BaseColor.neutral[500],
                ),
              ),
            ],
          ),
        ),
        FaIcon(
          AppIcons.forward,
          size: BaseSize.w20,
          color: BaseColor.neutral[400],
        ),
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
          width: BaseSize.w40,
          height: BaseSize.w40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [BaseColor.teal[400]!, BaseColor.teal[600]!],
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            bipra.abv,
            style: BaseTypography.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bipra.name,
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.teal[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap.h4,
              Row(
                children: [
                  FaIcon(
                    AppIcons.group,
                    size: BaseSize.w12,
                    color: BaseColor.teal[600],
                  ),
                  Gap.w4,
                  Text(
                    context.l10n.publish_targetGroup,
                    style: BaseTypography.bodySmall.copyWith(
                      color: BaseColor.teal[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: context.l10n.btn_clear,
              child: GestureDetector(
                onTap: () => controller.onSelectedBipra(null),
                child: FaIcon(
                  AppIcons.clear,
                  size: BaseSize.w18,
                  color: BaseColor.teal[600],
                ),
              ),
            ),
            Gap.w12,
            FaIcon(
              AppIcons.edit,
              size: BaseSize.w18,
              color: BaseColor.teal[600],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    return _buildSectionCard(
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
          style: BaseTypography.titleMedium.copyWith(
            color: BaseColor.neutral[800],
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
            if (res != null) {
              controller.onSelectedMapLocation(res);
            }
          },
          child: Container(
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: hasLocation ? BaseColor.primary[50] : BaseColor.white,
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              border: Border.all(
                color: hasError
                    ? BaseColor.error.withValues(alpha: 0.5)
                    : hasLocation
                    ? BaseColor.primary[200]!
                    : BaseColor.neutral[300]!,
              ),
            ),
            child: hasLocation
                ? _buildSelectedLocationInfo(state.selectedMapLocation!)
                : _buildEmptyLocationPlaceholder(),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: BaseSize.customHeight(3)),
            child: Text(
              state.errorPinpointLocation!,
              textAlign: TextAlign.center,
              style: BaseTypography.bodySmall.copyWith(color: BaseColor.error),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyLocationPlaceholder() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(BaseSize.w8),
          decoration: BoxDecoration(
            color: BaseColor.neutral[100],
            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          ),
          child: FaIcon(
            AppIcons.mapOutlined,
            size: BaseSize.w20,
            color: BaseColor.neutral[500],
          ),
        ),
        Gap.w12,
        Expanded(
          child: Text(
            context.l10n.publish_tapToSelectLocationOptional,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.neutral[500],
            ),
          ),
        ),
        FaIcon(
          AppIcons.forward,
          size: BaseSize.w20,
          color: BaseColor.neutral[400],
        ),
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
          padding: EdgeInsets.all(BaseSize.w8),
          decoration: BoxDecoration(
            color: BaseColor.primary[100],
            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          ),
          child: FaIcon(
            AppIcons.locationOn,
            size: BaseSize.w20,
            color: BaseColor.primary[600],
          ),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.publish_locationSelected,
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.primary[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap.h4,
              Row(
                children: [
                  FaIcon(
                    AppIcons.myLocation,
                    size: BaseSize.w14,
                    color: BaseColor.neutral[600],
                  ),
                  Gap.w4,
                  Expanded(
                    child: Text(
                      hasCoordinates
                          ? '${location.latitude!.toStringAsFixed(5)}, ${location.longitude!.toStringAsFixed(5)}'
                          : context.l10n.lbl_na,
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.neutral[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        FaIcon(
          AppIcons.edit,
          size: BaseSize.w18,
          color: BaseColor.primary[600],
        ),
      ],
    );
  }

  Widget _buildScheduleSection(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    return _buildSectionCard(
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
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BaseColor.blue[50]!, BaseColor.primary[50]!],
        ),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: BaseColor.blue[100]!),
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
            if (res != null) {
              controller.onSelectedDate(res);
            }
          },
          child: Container(
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: BaseColor.white,
              borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              border: Border.all(
                color: hasError
                    ? BaseColor.error.withValues(alpha: 0.5)
                    : hasDate
                    ? BaseColor.blue[300]!
                    : BaseColor.neutral[200]!,
                width: hasDate ? 1.5 : 1,
              ),
              boxShadow: hasDate
                  ? [
                      BoxShadow(
                        color: BaseColor.blue[100]!.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Container(
                  width: BaseSize.w36,
                  height: BaseSize.w36,
                  decoration: BoxDecoration(
                    color: hasDate
                        ? BaseColor.blue[100]
                        : BaseColor.neutral[100],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.calendarToday,
                    size: BaseSize.w18,
                    color: hasDate
                        ? BaseColor.blue[600]
                        : BaseColor.neutral[500],
                  ),
                ),
                Gap.h8,
                Text(
                  hasDate
                      ? _formatDateShort(context, state.selectedDate!)
                      : context.l10n.lbl_date,
                  style: BaseTypography.bodyMedium.copyWith(
                    color: hasDate
                        ? BaseColor.blue[700]
                        : BaseColor.neutral[500],
                    fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (hasDate) ...[
                  Gap.h4,
                  Text(
                    _formatDayOfWeek(context, state.selectedDate!),
                    style: BaseTypography.bodySmall.copyWith(
                      color: BaseColor.blue[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: BaseSize.customHeight(3)),
            child: Text(
              state.errorDate!,
              textAlign: TextAlign.center,
              style: BaseTypography.bodySmall.copyWith(color: BaseColor.error),
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
            if (res != null) {
              controller.onSelectedTime(res);
            }
          },
          child: Container(
            padding: EdgeInsets.all(BaseSize.w12),
            decoration: BoxDecoration(
              color: BaseColor.white,
              borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              border: Border.all(
                color: hasError
                    ? BaseColor.error.withValues(alpha: 0.5)
                    : hasTime
                    ? BaseColor.primary[300]!
                    : BaseColor.neutral[200]!,
                width: hasTime ? 1.5 : 1,
              ),
              boxShadow: hasTime
                  ? [
                      BoxShadow(
                        color: BaseColor.primary[100]!.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Container(
                  width: BaseSize.w36,
                  height: BaseSize.w36,
                  decoration: BoxDecoration(
                    color: hasTime
                        ? BaseColor.primary[100]
                        : BaseColor.neutral[100],
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.accessTime,
                    size: BaseSize.w18,
                    color: hasTime
                        ? BaseColor.primary[600]
                        : BaseColor.neutral[500],
                  ),
                ),
                Gap.h8,
                Text(
                  hasTime
                      ? _formatTime(context, state.selectedTime!)
                      : context.l10n.lbl_time,
                  style: BaseTypography.bodyMedium.copyWith(
                    color: hasTime
                        ? BaseColor.primary[700]
                        : BaseColor.neutral[500],
                    fontWeight: hasTime ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (hasTime) ...[
                  Gap.h4,
                  Text(
                    _getTimePeriod(context, state.selectedTime!),
                    style: BaseTypography.bodySmall.copyWith(
                      color: BaseColor.primary[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: BaseSize.customHeight(3)),
            child: Text(
              state.errorTime!,
              textAlign: TextAlign.center,
              style: BaseTypography.bodySmall.copyWith(color: BaseColor.error),
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
    final hasError =
        state.errorReminder != null && state.errorReminder!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.lbl_reminder,
          style: BaseTypography.titleMedium.copyWith(
            color: BaseColor.neutral[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap.h6,
        Container(
          decoration: BoxDecoration(
            color: BaseColor.yellow[50],
            borderRadius: BorderRadius.circular(BaseSize.radiusMd),
            border: Border.all(
              color: hasError
                  ? BaseColor.error.withValues(alpha: 0.5)
                  : BaseColor.yellow[200]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w12,
                  vertical: BaseSize.h8,
                ),
                decoration: BoxDecoration(
                  color: BaseColor.yellow[100],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(BaseSize.radiusMd),
                    topRight: Radius.circular(BaseSize.radiusMd),
                  ),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      AppIcons.notificationsActive,
                      size: BaseSize.w16,
                      color: BaseColor.yellow[800],
                    ),
                    Gap.w6,
                    Text(
                      context.l10n.publish_reminderSubtitle,
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.yellow[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Reminder options
              Padding(
                padding: EdgeInsets.all(BaseSize.w8),
                child: Wrap(
                  spacing: BaseSize.w8,
                  runSpacing: BaseSize.h8,
                  children: Reminder.values.map((reminder) {
                    final isSelected = state.selectedReminder == reminder;
                    return GestureDetector(
                      onTap: () => controller.onSelectedReminder(reminder),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: BaseSize.w12,
                          vertical: BaseSize.h8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? BaseColor.yellow[600]
                              : BaseColor.white,
                          borderRadius: BorderRadius.circular(
                            BaseSize.radiusSm,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? BaseColor.yellow[700]!
                                : BaseColor.yellow[300]!,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: BaseColor.yellow[300]!.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              isSelected
                                  ? AppIcons.checkCircle
                                  : AppIcons.accessTime,
                              size: BaseSize.w14,
                              color: isSelected
                                  ? Colors.white
                                  : BaseColor.yellow[700],
                            ),
                            Gap.w6,
                            Text(
                              _getReminderLabel(context, reminder),
                              style: BaseTypography.bodySmall.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : BaseColor.yellow[800],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: BaseSize.customHeight(3)),
            child: Text(
              state.errorReminder!,
              textAlign: TextAlign.center,
              style: BaseTypography.bodySmall.copyWith(color: BaseColor.error),
            ),
          ),
      ],
    );
  }

  Widget _buildAnnouncementSection(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    return _buildSectionCard(
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
          style: BaseTypography.titleMedium.copyWith(
            color: BaseColor.neutral[800],
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
          allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
          onChanged: (picked) {
            if (picked == null) {
              controller.clearSelectedFile();
              return;
            }
            controller.onSelectedFile(
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

  /// Builds the file picker button when no file is selected.
  Widget _buildFilePickerButton(ActivityPublishController controller) {
    return GestureDetector(
      onTap: () => _handleFilePick(controller),
      child: Container(
        padding: EdgeInsets.all(BaseSize.w16),
        decoration: BoxDecoration(
          color: BaseColor.neutral[50],
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          border: Border.all(
            color: BaseColor.neutral[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(BaseSize.w8),
              decoration: BoxDecoration(
                color: BaseColor.primary[100],
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: FaIcon(
                AppIcons.uploadFile,
                size: BaseSize.w20,
                color: BaseColor.primary[600],
              ),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.publish_uploadFile,
                    style: BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.primary[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    context.l10n.publish_supportedFileTypes,
                    style: BaseTypography.bodySmall.copyWith(
                      color: BaseColor.neutral[500],
                    ),
                  ),
                ],
              ),
            ),
            FaIcon(
              AppIcons.addCircle,
              size: BaseSize.w20,
              color: BaseColor.primary[600],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the selected file card showing file name with remove option.
  Widget _buildSelectedFileCard(
    ActivityPublishState state,
    ActivityPublishController controller,
  ) {
    final fileName = state.file ?? '';
    final fileExtension = fileName.split('.').last.toLowerCase();
    final fileIcon = _getFileIcon(fileExtension);
    final fileColor = _getFileColor(fileExtension);

    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: fileColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: fileColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(BaseSize.w10),
            decoration: BoxDecoration(
              color: fileColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(BaseSize.radiusSm),
            ),
            child: Icon(fileIcon, size: BaseSize.w24, color: fileColor),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: BaseTypography.bodyMedium.copyWith(
                    color: BaseColor.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Gap.h4,
                Text(
                  fileExtension.toUpperCase(),
                  style: BaseTypography.bodySmall.copyWith(color: fileColor),
                ),
              ],
            ),
          ),
          Gap.w8,
          // Change file button
          GestureDetector(
            onTap: () => _handleFilePick(controller),
            child: Container(
              padding: EdgeInsets.all(BaseSize.w8),
              decoration: BoxDecoration(
                color: BaseColor.neutral[100],
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: FaIcon(
                AppIcons.edit,
                size: BaseSize.w18,
                color: BaseColor.neutral[600],
              ),
            ),
          ),
          Gap.w8,
          // Remove file button
          GestureDetector(
            onTap: () => controller.clearSelectedFile(),
            child: Container(
              padding: EdgeInsets.all(BaseSize.w8),
              decoration: BoxDecoration(
                color: BaseColor.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: FaIcon(
                AppIcons.close,
                size: BaseSize.w18,
                color: BaseColor.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles file picking using FilePicker.
  /// Requirements: 5.21
  Future<void> _handleFilePick(ActivityPublishController controller) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      controller.onSelectedFile(
        fileName: file.name,
        filePath: file.path,
        fileBytes: file.bytes,
        fileSizeBytes: file.size,
      );
    }
  }

  /// Returns the appropriate icon for a file extension.
  IconData _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return AppIcons.pictureAsPdf;
      case 'doc':
      case 'docx':
        return AppIcons.document;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return AppIcons.image;
      default:
        return AppIcons.insertDriveFile;
    }
  }

  /// Returns the appropriate color for a file extension.
  Color _getFileColor(String extension) {
    switch (extension) {
      case 'pdf':
        return BaseColor.error;
      case 'doc':
      case 'docx':
        return BaseColor.blue[600]!;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return BaseColor.primary[600]!;
      default:
        return BaseColor.neutral[600]!;
    }
  }

  Widget _buildPublisherSection(ActivityPublishState state) {
    return Container(
      padding: EdgeInsets.all(BaseSize.w12),
      decoration: BoxDecoration(
        color: BaseColor.neutral[50],
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        border: Border.all(color: BaseColor.neutral[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: BaseSize.w40,
                height: BaseSize.w40,
                decoration: BoxDecoration(
                  color: BaseColor.primary[100],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.person,
                  color: BaseColor.primary[600],
                  size: BaseSize.w20,
                ),
              ),
              Gap.w12,
              // Author name and church
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.authorName ?? context.l10n.loading_please_wait,
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.textPrimary,
                      ),
                    ),
                    Gap.h4,
                    Row(
                      children: [
                        FaIcon(
                          AppIcons.church,
                          size: BaseSize.w12,
                          color: BaseColor.neutral[500],
                        ),
                        Gap.w4,
                        Flexible(
                          child: Text(
                            state.churchName ?? '',
                            style: BaseTypography.bodySmall.copyWith(
                              color: BaseColor.neutral[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Date
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w8,
                  vertical: BaseSize.h4,
                ),
                decoration: BoxDecoration(
                  color: BaseColor.neutral[100],
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                ),
                child: Text(
                  state.currentDate ?? '',
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.neutral[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          // Positions
          if (state.authorPositions.isNotEmpty) ...[
            Gap.h8,
            Wrap(
              spacing: BaseSize.w6,
              runSpacing: BaseSize.h4,
              children: state.authorPositions.map((position) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w8,
                    vertical: BaseSize.h4,
                  ),
                  decoration: BoxDecoration(
                    color: BaseColor.blue[50],
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                    border: Border.all(color: BaseColor.blue[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        AppIcons.badgeOutlined,
                        size: BaseSize.w12,
                        color: BaseColor.blue[700],
                      ),
                      Gap.w4,
                      Text(
                        position,
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.blue[700],
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
    );
  }

  Widget _buildSubmitButton(
    ActivityPublishState state,
    ActivityPublishController controller,
  ) {
    // Requirements: 5.7, 5.8, 5.9 - Enable/disable submit button based on validation
    final isEnabled = state.isFormValid && !state.loading;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + BaseSize.h12,
        left: BaseSize.w12,
        right: BaseSize.w12,
        top: BaseSize.h12,
      ),
      decoration: BoxDecoration(
        color: BaseColor.white,
        boxShadow: [
          BoxShadow(
            color: BaseColor.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
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
    return _buildSectionCard(
      title: context.l10n.section_financialRecord,
      icon: AppIcons.accountBalanceWalletOutlined,
      subtitle: context.l10n.publish_financialRecordSubtitle,
      children: [
        if (state.attachedFinance == null)
          _buildAddFinanceButton(controller, context)
        else
          FinanceSummaryCard(
            financeData: state.attachedFinance!,
            onRemove: () => _handleRemoveFinance(controller, context),
            onEdit: () => _handleEditFinance(state, controller, context),
          ),
      ],
    );
  }

  /// Builds the "Add Financial Record" button.
  /// Requirements: 1.2
  Widget _buildAddFinanceButton(
    ActivityPublishController controller,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => _handleAddFinance(controller, context),
      child: Container(
        padding: EdgeInsets.all(BaseSize.w16),
        decoration: BoxDecoration(
          color: BaseColor.neutral[50],
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          border: Border.all(
            color: BaseColor.neutral[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(BaseSize.w8),
              decoration: BoxDecoration(
                color: BaseColor.primary[100],
                borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              ),
              child: FaIcon(
                AppIcons.add,
                size: BaseSize.w20,
                color: BaseColor.primary[600],
              ),
            ),
            Gap.w12,
            Text(
              context.l10n.publish_addFinancialRecord,
              style: BaseTypography.bodyMedium.copyWith(
                color: BaseColor.primary[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
      controller.onAttachedFinance(financeData);
    }
  }

  /// Handles editing an attached finance record.
  /// Requirements: 1.1, 1.2, 1.3
  Future<void> _handleEditFinance(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) async {
    final currentFinance = state.attachedFinance;
    if (currentFinance == null) return;

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
      controller.onAttachedFinance(financeData);
    }
  }

  /// Shows confirmation dialog before removing attached financial record.
  /// Requirements: 3.1, 3.2, 3.3, 3.4
  Future<void> _handleRemoveFinance(
    ActivityPublishController controller,
    BuildContext context,
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
            style: TextButton.styleFrom(foregroundColor: BaseColor.error),
            child: Text(context.l10n.btn_remove),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.removeAttachedFinance();
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
