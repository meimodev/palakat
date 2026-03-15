import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/services/notification_display_service_provider.dart';

import 'activity_alarm_motion_widget.dart';

class AlarmRingScreen extends ConsumerStatefulWidget {
  const AlarmRingScreen({
    super.key,
    required this.activityId,
    this.alarmAtUtcIso,
    this.title,
    this.reminderName,
    this.reminderValue,
    this.alarmKey,
    this.notificationId,
  });

  final int activityId;
  final String? alarmAtUtcIso;
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
      await _player.setAsset('assets/alarm.mp3');
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(1);
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

  Future<void> _dismissAndClose() async {
    await _stop();
    await _cancelAlarmNotification();
    if (!mounted) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    context.goNamed(AppRoute.home);
  }

  Future<void> _openActivity() async {
    await _stop();
    await _cancelAlarmNotification();
    if (!mounted) return;

    context.pushNamed(
      AppRoute.activityDetail,
      pathParameters: {'activityId': widget.activityId.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title?.trim().isNotEmpty == true
        ? widget.title!.trim()
        : 'Activity';
    final reminderText = widget.reminderName ?? widget.reminderValue;
    final alarmAt =
        DateTime.tryParse(widget.alarmAtUtcIso ?? '')?.toLocal() ??
        DateTime.now();
    final timeText = DateFormat('HH:mm').format(alarmAt);
    final dayText = DateFormat('EEE, d MMM').format(alarmAt);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        unawaited(_stop());
        unawaited(_cancelAlarmNotification());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF08101D),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              BaseSize.w20,
              BaseSize.h12,
              BaseSize.w20,
              BaseSize.h20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ActivityAlarmReveal(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w12,
                        vertical: BaseSize.h8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(BaseSize.radiusXl),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.notificationActive,
                            color: const Color(0xFFFFD54F),
                            size: BaseSize.w18,
                          ),
                          Gap.w10,
                          Text(
                            'Alarm ringing',
                            style: BaseTypography.bodyMedium.copyWith(
                              color: BaseColor.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ActivityAlarmReveal(
                        delay: const Duration(milliseconds: 40),
                        child: Container(
                          width: BaseSize.customWidth(88),
                          height: BaseSize.customWidth(88),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0x1AFFFFFF),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Icon(
                            AppIcons.notificationActive,
                            size: BaseSize.w36,
                            color: const Color(0xFFFFD54F),
                          ),
                        ),
                      ),
                      Gap.h24,
                      ActivityAlarmReveal(
                        delay: const Duration(milliseconds: 90),
                        child: Text(
                          timeText,
                          textAlign: TextAlign.center,
                          style: BaseTypography.headlineLarge.copyWith(
                            color: BaseColor.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 72,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                      Gap.h8,
                      ActivityAlarmReveal(
                        delay: const Duration(milliseconds: 130),
                        child: Text(
                          dayText,
                          textAlign: TextAlign.center,
                          style: BaseTypography.titleLarge.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Gap.h24,
                      ActivityAlarmReveal(
                        delay: const Duration(milliseconds: 180),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(BaseSize.w18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              BaseSize.radiusLg,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Activity',
                                style: BaseTypography.labelLarge.copyWith(
                                  color: Colors.white.withValues(alpha: 0.64),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Gap.h8,
                              Text(
                                title,
                                style: BaseTypography.headlineSmall.copyWith(
                                  color: BaseColor.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (reminderText != null &&
                                  reminderText.trim().isNotEmpty) ...[
                                Gap.h16,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: BaseSize.w14,
                                    vertical: BaseSize.h8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x14FFD54F),
                                    borderRadius: BorderRadius.circular(
                                      BaseSize.radiusXl,
                                    ),
                                  ),
                                  child: Text(
                                    reminderText,
                                    style: BaseTypography.bodyMedium.copyWith(
                                      color: const Color(0xFFFFE082),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Gap.h20,
                      ActivityAlarmAnimatedPresence(
                        visible: _starting,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: BaseSize.w18,
                              height: BaseSize.w18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: const Color(0xFFFFD54F),
                              ),
                            ),
                            Gap.customGapWidth(10),
                            Text(
                              'Starting alarm audio...',
                              style: BaseTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ActivityAlarmReveal(
                  delay: const Duration(milliseconds: 220),
                  child: ElevatedButton(
                    onPressed: _dismissAndClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BaseColor.red[600],
                      foregroundColor: BaseColor.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        vertical: BaseSize.customHeight(16),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                      ),
                    ),
                    child: Text(
                      'Dismiss alarm',
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BaseColor.white,
                      ),
                    ),
                  ),
                ),
                Gap.customGapHeight(10),
                ActivityAlarmReveal(
                  delay: const Duration(milliseconds: 260),
                  child: OutlinedButton(
                    onPressed: _openActivity,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: BaseSize.customHeight(16),
                      ),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                      ),
                    ),
                    child: Text(
                      'View activity',
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BaseColor.white,
                      ),
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
