import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    final state = Activity(
      serial: id,
      title: "Region 6-9, Youth & Teens Weekly Service",
      type: ActivityType.values[Random().nextInt(ActivityType.values.length)],
      bipra: Bipra.values[Random().nextInt(Bipra.values.length)],
      publishDate: DateTime.now(),
      activityDate: DateTime.now(), accountSerial: '', churchSerial: '',
    );

    return ScaffoldWidget(
      child: Column(
        children: [
          ScreenTitleWidget.primary(
            title: state.type.name.camelToSentence,
            subTitle: state.title,
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h24,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
            child: Column(
              children: _buildOutputList(state),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOutputList(Activity state) {
    List<Widget> outputList = [
      OutputWidget.startIcon(
        label: "Tanggal",
        title: "23 Januari 2026",
        startIcon: Assets.icons.line.calendarOutline,
      ),
      Gap.h12,
      OutputWidget.startIcon(
        label: "Jam",
        title: "18:00",
        startIcon: Assets.icons.line.timeOutline,
      ),
      Gap.h12,
      OutputWidget.endIcon(
        label: "Lokasi",
        title: "Kel. Jhon Manembo, Kolom 3, Samping Alfamart",
        startIcon: Assets.icons.line.mapOutline,
        endIcon: Assets.icons.line.navigateCircleOutline,
        onPressedEndIcon: () {
          print("End icon Location");
        },
      ),
      // Gap.h12,
      // OutputWidget.endIcon(
      //   label: "Pengingat",
      //   title:
      //       "30 Menit Sebelum, 1 Jam Sebelum, 2 Jam Sebelum, 1 Hari Sebelum, 2 Hari Sebelum, 1 minggu Sebelum",
      //   endIcon: Assets.icons.line.notificationCircleOutline,
      //   startIcon: Assets.icons.line.notificationOutline,
      //   onPressedEndIcon: () {
      //     print("End icon Location");
      //   },
      // ),
      Gap.h12,
      OutputWidget.startIcon(
        label: "Catatan",
        title:
            "Please use dresscode gold - white - black, and please be on time due to busy preacher schedule",
        startIcon: Assets.icons.line.readerOutline,
      ),
    ];

    if (state.type == ActivityType.announcement) {
      outputList = [
        OutputWidget.startIcon(
          label: "Deskripsi",
          title:
              "Pengumuman nikah dari sdr Nyong Anyong, Kolom 8 & sdri Noni Anoni Kolom 4 dari dinas pencatatan sipil kabupaten minahasa",
          startIcon: Assets.icons.line.readerOutline,
        ),
        Gap.h12,
        OutputWidget.endIcon(
          label: "Dokumen Edaran",
          title: "warta_jemaat_23_jan_2026.pdf",
          startIcon: Assets.icons.line.documentOutline,
          endIcon: Assets.icons.line.caretDownCircleOutline,
          onPressedEndIcon: () {
            print("End icon Location");
          },
        ),
        Gap.h12,
      ];
    }
    return [
      OutputWidget.bipra(
        label: "Untuk",
        startText: state.bipra.abv,
        title: state.bipra.name,
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
