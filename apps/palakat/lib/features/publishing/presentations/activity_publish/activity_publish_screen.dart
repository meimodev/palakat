import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

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

    return ScaffoldWidget(
      loading: state.loading,
      persistBottomWidget: _buildSubmitButton(state, controller),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(state),
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

  Widget _buildHeader(ActivityPublishState state) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + BaseSize.h8,
        left: BaseSize.w4,
        right: BaseSize.w12,
        bottom: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: BaseColor.white,
        boxShadow: [
          BoxShadow(
            color: BaseColor.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: context.pop,
            icon: Assets.icons.line.chevronBackOutline.svg(
              width: BaseSize.w24,
              height: BaseSize.h24,
              colorFilter: const ColorFilter.mode(
                BaseColor.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create ${state.type.displayName}',
                  style: BaseTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BaseColor.textPrimary,
                  ),
                ),
                Gap.h4,
                Text(
                  'Fill in the details below',
                  style: BaseTypography.bodyMedium.copyWith(
                    color: BaseColor.neutral[600],
                  ),
                ),
              ],
            ),
          ),
        ],
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
          icon: Icons.church_outlined,
          label: 'Church Service',
          backgroundColor: BaseColor.primary[50]!,
          borderColor: BaseColor.primary[200]!,
          iconColor: BaseColor.primary[700]!,
          textColor: BaseColor.primary[700]!,
        );
      case ActivityType.event:
        return _TypeConfig(
          icon: Icons.event_outlined,
          label: 'Church Event',
          backgroundColor: BaseColor.blue[50]!,
          borderColor: BaseColor.blue[200]!,
          iconColor: BaseColor.blue[700]!,
          textColor: BaseColor.blue[700]!,
        );
      case ActivityType.announcement:
        return _TypeConfig(
          icon: Icons.campaign_outlined,
          label: 'Announcement',
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
      title: 'Basic Information',
      icon: Icons.info_outline,
      subtitle: 'Title and target audience',
      children: [
        InputWidget<String>.text(
          hint: 'Enter activity title',
          label: 'Title',
          currentInputValue: state.title,
          errorText: state.errorTitle,
          onChanged: controller.onChangedTitle,
        ),
        Gap.h12,
        _buildBipraPicker(state, controller, context),
      ],
    );
  }

  Widget _buildBipraPicker(
    ActivityPublishState state,
    ActivityPublishController controller,
    BuildContext context,
  ) {
    final hasBipra = state.selectedBipra != null;
    final hasError = state.errorBipra != null && state.errorBipra!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Target Audience (BIPRA)',
          style: BaseTypography.titleMedium.copyWith(
            color: BaseColor.neutral[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        Gap.h6,
        GestureDetector(
          onTap: () async {
            final res = await showDialogBipraPickerWidget(context: context);
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
                ? _buildSelectedBipraInfo(state.selectedBipra!)
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
          child: Icon(
            Icons.group_outlined,
            size: BaseSize.w20,
            color: BaseColor.neutral[500],
          ),
        ),
        Gap.w12,
        Expanded(
          child: Text(
            'Select target group',
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.neutral[500],
            ),
          ),
        ),
        Icon(
          Icons.chevron_right,
          size: BaseSize.w20,
          color: BaseColor.neutral[400],
        ),
      ],
    );
  }

  Widget _buildSelectedBipraInfo(Bipra bipra) {
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
                  Icon(
                    Icons.group_outlined,
                    size: BaseSize.w12,
                    color: BaseColor.teal[600],
                  ),
                  Gap.w4,
                  Text(
                    'Target Group',
                    style: BaseTypography.bodySmall.copyWith(
                      color: BaseColor.teal[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Icon(
          Icons.edit_outlined,
          size: BaseSize.w18,
          color: BaseColor.teal[600],
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
      title: 'Location',
      icon: Icons.location_on_outlined,
      subtitle: 'Where will this take place?',
      children: [
        InputWidget<String>.text(
          hint: 'e.g., Church Hall, Host Name',
          label: 'Location Name',
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
          'Pin on Map',
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
          child: Icon(
            Icons.map_outlined,
            size: BaseSize.w20,
            color: BaseColor.neutral[500],
          ),
        ),
        Gap.w12,
        Expanded(
          child: Text(
            'Tap to select location on map',
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.neutral[500],
            ),
          ),
        ),
        Icon(
          Icons.chevron_right,
          size: BaseSize.w20,
          color: BaseColor.neutral[400],
        ),
      ],
    );
  }

  Widget _buildSelectedLocationInfo(Location location) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(BaseSize.w8),
          decoration: BoxDecoration(
            color: BaseColor.primary[100],
            borderRadius: BorderRadius.circular(BaseSize.radiusSm),
          ),
          child: Icon(
            Icons.location_on,
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
                'Location Selected',
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.primary[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Gap.h4,
              Row(
                children: [
                  Icon(
                    Icons.my_location,
                    size: BaseSize.w14,
                    color: BaseColor.neutral[600],
                  ),
                  Gap.w4,
                  Expanded(
                    child: Text(
                      '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
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
        Icon(
          Icons.edit_outlined,
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
      title: 'Schedule',
      icon: Icons.schedule_outlined,
      subtitle: 'When will this happen?',
      children: [
        _buildDateTimePickers(state, controller, context),
        Gap.h12,
        _buildReminderPicker(state, controller, context),
        Gap.h12,
        InputWidget<String>.text(
          label: 'Additional Notes (Optional)',
          hint: 'Any other details attendees should know',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available,
                size: BaseSize.w16,
                color: BaseColor.blue[700],
              ),
              Gap.w6,
              Text(
                'Event Schedule',
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Gap.h12,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDatePicker(state, controller, context)),
              Gap.w12,
              Expanded(child: _buildTimePicker(state, controller, context)),
            ],
          ),
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
                  child: Icon(
                    Icons.calendar_today,
                    size: BaseSize.w18,
                    color: hasDate
                        ? BaseColor.blue[600]
                        : BaseColor.neutral[500],
                  ),
                ),
                Gap.h8,
                Text(
                  hasDate ? _formatDateShort(state.selectedDate!) : 'Date',
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
                    _formatDayOfWeek(state.selectedDate!),
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
                  child: Icon(
                    Icons.access_time,
                    size: BaseSize.w18,
                    color: hasTime
                        ? BaseColor.primary[600]
                        : BaseColor.neutral[500],
                  ),
                ),
                Gap.h8,
                Text(
                  hasTime ? _formatTime(state.selectedTime!) : 'Time',
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
                    _getTimePeriod(state.selectedTime!),
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

  String _formatDateShort(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatDayOfWeek(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getTimePeriod(TimeOfDay time) {
    if (time.hour < 12) return 'Morning';
    if (time.hour < 17) return 'Afternoon';
    return 'Evening';
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
          'Reminder',
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
                    Icon(
                      Icons.notifications_active,
                      size: BaseSize.w16,
                      color: BaseColor.yellow[800],
                    ),
                    Gap.w6,
                    Text(
                      'When to notify attendees',
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
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.access_time,
                              size: BaseSize.w14,
                              color: isSelected
                                  ? Colors.white
                                  : BaseColor.yellow[700],
                            ),
                            Gap.w6,
                            Text(
                              reminder.name,
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
      title: 'Announcement Details',
      icon: Icons.article_outlined,
      subtitle: 'Content and attachments',
      children: [
        InputWidget<String>.text(
          hint: 'Write your announcement here...',
          label: 'Description',
          currentInputValue: state.description,
          errorText: state.errorDescription,
          onChanged: controller.onChangedDescription,
          maxLines: 4,
        ),
        Gap.h12,
        InputWidget<String>.dropdown(
          label: 'Attachment (Optional)',
          hint: 'Upload image, PDF, or document',
          currentInputValue: state.file,
          endIcon: Assets.icons.line.download,
          errorText: state.errorFile,
          onChanged: controller.onChangedFile,
          optionLabel: (value) => value,
          onPressedWithResult: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
            );
            if (result != null && result.files.isNotEmpty) {
              return result.files.first.name;
            }
            return null;
          },
        ),
      ],
    );
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
                child: Icon(
                  Icons.person,
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
                      state.authorName ?? 'Loading...',
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.textPrimary,
                      ),
                    ),
                    Gap.h4,
                    Row(
                      children: [
                        Icon(
                          Icons.church_outlined,
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
                      Icon(
                        Icons.badge_outlined,
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
          text: 'Create ${widget.type.displayName}',
          isLoading: state.loading,
          onTap: () => _handleSubmit(controller),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(ActivityPublishController controller) async {
    final success = await controller.submit();
    if (!mounted) return;

    if (success) {
      context.pop();
      _showSnackBar('Activity created successfully!');
    } else {
      final state = ref.read(activityPublishControllerProvider(widget.type));
      _showSnackBar(state.errorMessage ?? 'Please fill all required fields');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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
