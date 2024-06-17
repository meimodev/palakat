import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';

class ActivityPublishScreen extends ConsumerWidget {
  const ActivityPublishScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(activityPublishControllerProvider.notifier);
    final state = ref.watch(activityPublishControllerProvider);

    return ScaffoldWidget(
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
              children: _buildInputList(state.type),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInputList(ActivityType type) {
    List<Widget> outputList = [
      InputWidget.text(
        hint: "Location",
        label: "Can be Host name, Location name, Column Name, etc",
      ),
      Gap.h12,
      InputWidget.dropdown(
        hint: "Pinpoint Location",
        label: "Pin point location to make other easier to find",
        onPressedWithResult: () async {
          //show single selection
          return "Result";
        },
        onChanged: print,
      ),
      Gap.h12,
      Row(
        children: [
          Expanded(
            child: InputWidget.dropdown(
              hint: "Date",
              label: "Select date and time",
              // controller: TextEditingController(),
              onPressedWithResult: () async {
                return "Result";
              },
              onChanged: print,
            ),
          ),
          Expanded(
            child: InputWidget.dropdown(
              hint: "Time",
              // controller: TextEditingController(),
              onPressedWithResult: () async {
                return "Result";
              },
              label: '',
              onChanged: print,
            ),
          ),
        ],
      ),
      Gap.h12,
      InputWidget.text(
        hint: "Location",
        label: "Can be Host name, Location name, Column Name, etc",
      ),
    ];

    if (type == ActivityType.announcement) {
      outputList = [
        InputWidget.dropdown(
          hint: "Select BIPRA",
          label: "Where the service mainly will notify",
          // controller: TextEditingController(),
          onPressedWithResult: () async {
            //show single selection
            return "Result";
          },
          onChanged: print,
        ),
        Gap.h12,
        InputWidget.text(
          hint: "Title",
          label: "Brief explanation of the service",
        ),
      ];
    }
    return [
      InputWidget.dropdown(
        hint: "Select BIPRA",
        label: "Where the service mainly will notify",
        // controller: TextEditingController(),
        onPressedWithResult: () async {
          //show single selection
          return "Result";
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
    ];
  }
}
