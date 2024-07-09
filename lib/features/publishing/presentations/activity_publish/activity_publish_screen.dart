import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/utils/utils.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';

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
      presistBottomWidget: Padding(
        padding: EdgeInsets.only(
          bottom: BaseSize.h24,
          left: BaseSize.w12,
          right: BaseSize.w12,
        ),
      ),
      child: Column(
        children: [
          ScreenTitleWidget.primary(
            title: state.type.name.camelToSentence,
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h24,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildInputList(state.type, context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInputList(ActivityType type, BuildContext context) {
    List<Widget> outputList = [
      InputWidget.text(
        hint: "Location",
        label: "Can be Host name, Location name, Column Name, etc",
      ),
      Gap.h12,
      InputWidget.dropdown(
        hint: "Pinpoint Location",
        label: "Pin point location to make other easier to find",
        endIcon: Assets.icons.line.mapOutline,
        onChanged: print,
        onPressedWithResult: () async {
          final Location? res = await context.pushNamed<Location?>(
            AppRoute.publishingMap,
            extra: const RouteParam(
              params: {
                RouteParamKey.mapOperationType: MapOperationType.pinPoint,
              },
            ),
          );
          return res?.toString();
        },
      ),
      Gap.h12,
      Text(
        "Select Date & Time",
        overflow: TextOverflow.ellipsis,
        style: BaseTypography.bodyMedium.toSecondary,
      ),
      Gap.h4,
      Row(
        children: [
          Expanded(
            flex: 1,
            child: InputWidget.dropdown(
              hint: "Date",
              label: '',
              endIcon: Assets.icons.line.calendarOutline,
              onChanged: print,
              onPressedWithResult: () async {
                final res = await showDialogDatePickerWidget(
                  context: context,
                  firstDate: DateTime.now(),
                  initialDate: DateTime.now(),
                  initialDatePickerMode: DatePickerMode.day,
                  lastDate: DateTime(DateTime.now().year + 5),
                );
                return res?.EEEEddMMMyyyy;
              },
            ),
          ),
          Gap.w8,
          Expanded(
            child: InputWidget.dropdown(
              label: '',
              hint: "Time",
              endIcon: Assets.icons.line.timeOutline,
              onChanged: print,
              onPressedWithResult: () async {
                final res = await showDialogTimePickerWidget(context: context);
                return res?.HHmm;
              },
            ),
          ),
        ],
      ),
      // Gap.h12,
      // InputWidget.text(
      //   hint: "Location",
      //   label: "Can be Host name, Location name, Column Name, etc",
      // ),
    ];

    if (type == ActivityType.announcement) {
      outputList = [
        InputWidget.dropdown(
          label: "File that related to the announcement",
          hint: "Upload File, Image, Pdf",
          endIcon: Assets.icons.line.download,
          onChanged: print,
          onPressedWithResult: () async {
            final res = await FilePickerUtil.pickFile();
            return res?.path;
          },
        ),
      ];
    }
    return [
      InputWidget.dropdown(
        hint: "Select BIPRA",
        label: "Where the service mainly will notify",
        errorText:"Must be selected",
        onPressedWithResult: () async {
          final res = await showDialogBipraPickerWidget(context: context);
          return res?.name;
        },
        onChanged: print,
      ),
      Gap.h12,
      InputWidget.text(
        hint: "Title",
        label: "Brief explanation of the service",
      ),
      Gap.h12,
      ...outputList,
      Gap.h12,
      const Divider(
        thickness: 1,
        color: BaseColor.primary3,
      ),
      Gap.h6,
      OutputWidget.startIcon(
        label: "Penerbit",
        title: "Jhon Manembo",
        startIcon: Assets.icons.line.globeOutline,
      ),
      OutputWidget.startIcon(
        title: "GMIM Mahanaim, Wawalintouan",
        startIcon: Assets.icons.line.homeOutline,
      ),
      OutputWidget.startIcon(
        title: "Rabu, 32 January 2028",
        startIcon: Assets.icons.line.calendarOutline,
      ),
      Gap.h24,
      ButtonWidget.primary(
        text: "Submit",
        onTap: (){},
      ),
    ];
  }
}
