import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/services/notification_display_service_provider.dart';

import '../services/alarm_tone_service.dart';

class AlarmRingScreen extends ConsumerStatefulWidget {
  const AlarmRingScreen({
    super.key,
    required this.activityId,
    this.title,
    this.reminderName,
    this.reminderValue,
    this.alarmKey,
    this.notificationId,
  });

  final int activityId;
  final String? title;
  final String? reminderName;
  final String? reminderValue;
  final String? alarmKey;
  final int? notificationId;

  @override
  ConsumerState<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends ConsumerState<AlarmRingScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _starting = true;

  @override
  void initState() {
    super.initState();
    unawaited(_cancelAlarmNotification());
    unawaited(_start());
  }

  Future<void> _cancelAlarmNotification() async {
    final id = widget.notificationId;
    if (id == null) return;

    try {
      final display = ref.read(notificationDisplayServiceSyncProvider);
      await display?.cancelNotification(id);
    } catch (_) {}
  }

  Future<void> _start() async {
    try {
      final path = await AlarmToneService().ensureToneFilePath();
      await _player.setFilePath(path);
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _starting = false;
        });
      }
    }
  }

  Future<void> _stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  @override
  void dispose() {
    unawaited(_stop());
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title?.trim().isNotEmpty == true
        ? widget.title!.trim()
        : 'Activity';
    final reminderText = widget.reminderName ?? widget.reminderValue;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        unawaited(_stop());
        unawaited(_cancelAlarmNotification());
      },
      child: Scaffold(
        backgroundColor: BaseColor.white,
        appBar: AppBar(
          backgroundColor: BaseColor.white,
          elevation: 0,
          automaticallyImplyLeading: true,
          title: Text(
            'Alarm',
            style: BaseTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: BaseColor.black,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(BaseSize.w16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(BaseSize.w16),
                  decoration: BoxDecoration(
                    color: BaseColor.yellow[50],
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    border: Border.all(color: BaseColor.yellow[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: BaseSize.w48,
                        height: BaseSize.w48,
                        decoration: BoxDecoration(
                          color: BaseColor.yellow[100],
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          AppIcons.notificationActive,
                          size: BaseSize.w24,
                          color: BaseColor.yellow[700],
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: BaseTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: BaseColor.black,
                              ),
                            ),
                            if (reminderText != null &&
                                reminderText.trim().isNotEmpty) ...[
                              Gap.h4,
                              Text(
                                reminderText,
                                style: BaseTypography.bodySmall.copyWith(
                                  color: BaseColor.neutral[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.h16,
                if (_starting)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: BaseSize.h8),
                      child: SizedBox(
                        width: BaseSize.w24,
                        height: BaseSize.w24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BaseColor.yellow[700],
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    await _stop();
                    await _cancelAlarmNotification();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BaseColor.red[600],
                    foregroundColor: BaseColor.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      vertical: BaseSize.customHeight(14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: Text(
                    'Dismiss / Stop',
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: BaseColor.white,
                    ),
                  ),
                ),
                Gap.customGapHeight(10),
                OutlinedButton(
                  onPressed: () async {
                    await _stop();
                    await _cancelAlarmNotification();
                    if (!context.mounted) return;
                    context.pushNamed(
                      AppRoute.activityDetail,
                      pathParameters: {
                        'activityId': widget.activityId.toString(),
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: BaseSize.customHeight(14),
                    ),
                    side: BorderSide(color: BaseColor.neutral[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: Text(
                    'View activity',
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: BaseColor.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
