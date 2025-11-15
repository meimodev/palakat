import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({
    super.key,
    required this.activity,
  });

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final state = activity;

    return ScaffoldWidget(
      child: Column(
        children: [
          ScreenTitleWidget.primary(
            title: state.activityType.name.toCamelCase,
            subTitle: state.title,
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h16,
          Column(
            children: _buildOutputList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String title,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              Container(
                width: BaseSize.w40,
                height: BaseSize.w40,
                decoration: BoxDecoration(
                  color: BaseColor.teal[100],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.teal[200]!.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: BaseSize.w20,
                  color: BaseColor.teal[700],
                ),
              ),
              Gap.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: BaseTypography.labelMedium.copyWith(
                        color: BaseColor.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      title,
                      style: BaseTypography.bodyMedium.copyWith(
                        color: BaseColor.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onPressed != null) ...[
                Gap.w8,
                Icon(
                  Icons.chevron_right,
                  size: BaseSize.w24,
                  color: BaseColor.secondaryText,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOutputList(Activity state) {
    List<Widget> outputList = [
      _buildInfoCard(
        label: "Tanggal",
        title: "23 Januari 2026",
        icon: Icons.calendar_today_outlined,
      ),
      Gap.h12,
      _buildInfoCard(
        label: "Jam",
        title: "18:00",
        icon: Icons.access_time_outlined,
      ),
      Gap.h12,
      _buildInfoCard(
        label: "Lokasi",
        title: "Kel. Jhon Manembo, Kolom 3, Samping Alfamart",
        icon: Icons.location_on_outlined,
        onPressed: () {
          // Navigate to location
        },
      ),
      Gap.h12,
      _buildInfoCard(
        label: "Catatan",
        title:
            "Please use dresscode gold - white - black, and please be on time due to busy preacher schedule",
        icon: Icons.description_outlined,
      ),
    ];

    if (state.activityType == ActivityType.announcement) {
      outputList = [
        _buildInfoCard(
          label: "Deskripsi",
          title:
              "Pengumuman nikah dari sdr Nyong Anyong, Kolom 8 & sdri Noni Anoni Kolom 4 dari dinas pencatatan sipil kabupaten minahasa",
          icon: Icons.description_outlined,
        ),
        Gap.h12,
        _buildInfoCard(
          label: "Dokumen Edaran",
          title: "warta_jemaat_23_jan_2026.pdf",
          icon: Icons.insert_drive_file_outlined,
          onPressed: () {
            // Download document
          },
        ),
        Gap.h12,
      ];
    }

    return [
      // Bipra card
      Material(
        color: BaseColor.cardBackground1,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        surfaceTintColor: BaseColor.blue[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w12,
                  vertical: BaseSize.h8,
                ),
                decoration: BoxDecoration(
                  color: BaseColor.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.bipra?.abv ?? "",
                  style: BaseTypography.titleMedium.copyWith(
                    color: BaseColor.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Untuk",
                      style: BaseTypography.labelMedium.copyWith(
                        color: BaseColor.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      state.bipra?.name ?? "",
                      style: BaseTypography.bodyMedium.copyWith(
                        color: BaseColor.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      Gap.h12,
      ...outputList,
      Gap.h16,
      // Publisher section
      Material(
        color: BaseColor.cardBackground1,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        surfaceTintColor: BaseColor.teal[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: BaseSize.w32,
                    height: BaseSize.w32,
                    decoration: BoxDecoration(
                      color: BaseColor.teal[100],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person_outline,
                      size: BaseSize.w16,
                      color: BaseColor.teal[700],
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Text(
                      "Penerbit",
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BaseColor.black,
                      ),
                    ),
                  ),
                ],
              ),
              Gap.h12,
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: BaseSize.w20,
                    color: BaseColor.secondaryText,
                  ),
                  Gap.w8,
                  Expanded(
                    child: Text(
                      "Jhon Manembo",
                      style: BaseTypography.bodyMedium.copyWith(
                        color: BaseColor.black,
                      ),
                    ),
                  ),
                ],
              ),
              Gap.h8,
              Row(
                children: [
                  Icon(
                    Icons.church_outlined,
                    size: BaseSize.w20,
                    color: BaseColor.secondaryText,
                  ),
                  Gap.w8,
                  Expanded(
                    child: Text(
                      "GMIM Mahanaim, Wawalintouan",
                      style: BaseTypography.bodyMedium.copyWith(
                        color: BaseColor.black,
                      ),
                    ),
                  ),
                ],
              ),
              Gap.h8,
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: BaseSize.w20,
                    color: BaseColor.secondaryText,
                  ),
                  Gap.w8,
                  Expanded(
                    child: Text(
                      "Rabu, 32 January 2028",
                      style: BaseTypography.bodyMedium.copyWith(
                        color: BaseColor.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }
}
