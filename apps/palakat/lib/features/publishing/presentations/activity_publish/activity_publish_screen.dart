import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_admin/core/extension/extension.dart';

class ActivityPublishScreen extends ConsumerWidget {
  const ActivityPublishScreen({
    super.key,
    required this.type,
  });

  final ActivityType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = activityPublishControllerProvider(type);
    // final controller = ref.read(provider.notifier);
    final state = ref.watch(provider);

    return ScaffoldWidget(
      loading: state.loading ?? false,
      persistBottomWidget: Padding(
        padding: EdgeInsets.only(
          bottom: BaseSize.h24,
          left: BaseSize.w12,
          right: BaseSize.w12,
        ),
      ),
      child: Column(
        children: [
          ScreenTitleWidget.primary(
            title: state.type.name.toCamelCase,
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h24,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // children: _buildInputList(state.type, state, controller, context),
            ),
          ),
        ],
      ),
    );
  }

  // List<Widget> _buildInputList(ActivityType type, ActivityPublishState state,
  //     ActivityPublishController controller, BuildContext context) {
  //   List<Widget> specificInputs = [
  //     InputWidget.text(
  //       hint: "Location",
  //       label: "Can be Host name, Location name, Column Name, etc",
  //       currentInputValue: state.location,
  //       // validators: controller.validateLocation,
  //       errorText: state.errorLocation,
  //       onChanged: controller.onChangedLocation,
  //     ),
  //     Gap.h12,
  //     InputWidget.dropdown(
  //       hint: "Pinpoint Location",
  //       label: "Pin point location to make other easier to find",
  //       endIcon: Assets.icons.line.mapOutline,
  //       currentInputValue: state.pinpointLocation,
  //       // validators: controller.validatePinpointLocation,
  //       errorText: state.errorPinpointLocation,
  //       onChanged: controller.onChangedPinpointLocation,
  //       onPressedWithResult: () async {
  //         final Location? res = await context.pushNamed<Location?>(
  //           AppRoute.publishingMap,
  //           extra: const RouteParam(
  //             params: {
  //               RouteParamKey.mapOperationType: MapOperationType.pinPoint,
  //             },
  //           ),
  //         );
  //         return res?.toString();
  //       },
  //     ),
  //     Gap.h12,
  //     Text(
  //       "Select Date & Time",
  //       overflow: TextOverflow.ellipsis,
  //       style: BaseTypography.bodyMedium.toSecondary,
  //     ),
  //     Gap.h4,
  //     Row(
  //       children: [
  //         Expanded(
  //           flex: 1,
  //           child: InputWidget.dropdown(
  //             hint: "Date",
  //             label: '',
  //             endIcon: Assets.icons.line.calendarOutline,
  //             onChanged: controller.onChangedDate,
  //             currentInputValue: state.date,
  //             // validators: controller.validateDate,
  //             errorText: state.errorDate,
  //             onPressedWithResult: () async {
  //               final res = await showDialogDatePickerWidget(
  //                 context: context,
  //                 firstDate: DateTime.now(),
  //                 initialDate: DateTime.now(),
  //                 initialDatePickerMode: DatePickerMode.day,
  //                 lastDate: DateTime(DateTime.now().year + 5),
  //               );
  //               return res?.EEEEddMMMyyyy;
  //             },
  //           ),
  //         ),
  //         Gap.w8,
  //         Expanded(
  //           child: InputWidget.dropdown(
  //             label: '',
  //             hint: "Time",
  //             currentInputValue: state.time,
  //             endIcon: Assets.icons.line.timeOutline,
  //             onChanged: controller.onChangedTime,
  //             // validators: controller.validateTime,
  //             errorText: state.errorTime,
  //             onPressedWithResult: () async {
  //               final res = await showDialogTimePickerWidget(context: context);
  //               return res?.HHmm;
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //     Gap.h12,
  //     Text(
  //       "Select Which time the reminder will be sent",
  //       overflow: TextOverflow.ellipsis,
  //       style: BaseTypography.bodyMedium.toSecondary,
  //     ),
  //     Gap.h4,
  //     InputWidget.dropdown(
  //       label: '',
  //       hint: 'Select Reminder',
  //       currentInputValue: state.reminder,
  //       onChanged: controller.onChangedReminder,
  //       errorText: state.errorReminder,
  //       onPressedWithResult: () async {
  //         final res = await showDialogReminderPickerWidget(context: context);
  //         return res?.name;
  //       },
  //     ),
  //     Gap.h12,
  //     InputWidget.text(
  //       label: 'Other things attendee need to know',
  //       hint: 'Note',
  //       errorText: state.errorNote,
  //       onChanged: controller.onChangeNote,
  //     )
  //     // Gap.h12,
  //     // InputWidget.text(
  //     //   hint: "Location",
  //     //   label: "Can be Host name, Location name, Column Name, etc",
  //     // ),
  //   ];
  //
  //   if (type == ActivityType.announcement) {
  //     specificInputs = [
  //       InputWidget.text(
  //         hint: "Description",
  //         label: "Brief reason about the announcement",
  //         currentInputValue: state.description,
  //         errorText: state.errorTitle,
  //         onChanged: controller.onChangedDescription,
  //         // validators: controller.validateTitle,
  //       ),
  //       Gap.h12,
  //       InputWidget.dropdown(
  //         label: "File that related to the announcement",
  //         hint: "Upload File, Image, Pdf",
  //         currentInputValue: state.file,
  //         endIcon: Assets.icons.line.download,
  //         onChanged: controller.onChangedFile,
  //         // validators: controller.validateFile,
  //         errorText: state.errorFile,
  //         onPressedWithResult: () async {
  //           final res = await FilePickerUtil.pickFile();
  //           return res?.path;
  //         },
  //       ),
  //     ];
  //   }
  //   return [
  //     InputWidget.dropdown(
  //       hint: "Select BIPRA",
  //       label: "Where the service mainly will notify",
  //       currentInputValue: state.bipra,
  //       errorText: state.errorBipra,
  //       // validators: controller.validateBipra,
  //       onChanged: controller.onChangedBipra,
  //       onPressedWithResult: () async {
  //         final res = await showDialogBipraPickerWidget(context: context);
  //         return res?.name;
  //       },
  //     ),
  //     Gap.h12,
  //     InputWidget.text(
  //       hint: "Title",
  //       label: "Brief explanation of the service",
  //       errorText: state.errorTitle,
  //       onChanged: controller.onChangedTitle,
  //       currentInputValue: state.title,
  //       // validators: controller.validateTitle,
  //     ),
  //     Gap.h12,
  //     ...specificInputs,
  //     Gap.h12,
  //     const Divider(
  //       thickness: 1,
  //       color: BaseColor.primary3,
  //     ),
  //     Gap.h6,
  //     OutputWidget.startIcon(
  //       label: "Penerbit",
  //       title: "Jhon Manembo",
  //       startIcon: Assets.icons.line.globeOutline,
  //     ),
  //     OutputWidget.startIcon(
  //       title: "GMIM Mahanaim, Wawalintouan",
  //       startIcon: Assets.icons.line.homeOutline,
  //     ),
  //     OutputWidget.startIcon(
  //       title: "Rabu, 32 January 2028",
  //       startIcon: Assets.icons.line.calendarOutline,
  //     ),
  //     Gap.h24,
  //     ButtonWidget.primary(
  //       text: "Submit",
  //       onTap: () async {
  //         final success = await controller.submit();
  //         if (context.mounted) {
  //           if (!success) {
  //             showSnackBar(context, "Please Fill All the field");
  //             controller.publish();
  //             Navigator.pop(context);
  //             return;
  //           }
  //         }
  //       },
  //     ),
  //   ];
  // }

  void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }
}
