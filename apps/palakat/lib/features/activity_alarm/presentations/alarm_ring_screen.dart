import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/services/notification_display_service_provider.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';

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
    final l10n = context.l10n;
    final title = widget.title?.trim().isNotEmpty == true
        ? widget.title!.trim()
        : l10n.lbl_activity;
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
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20.0,
              12.0,
              20.0,
              20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ActivityAlarmReveal(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.shade100,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: AppColors.warning.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.notificationActive,
                            color: AppColors.warning,
                            size: 18.0,
                          ),
                          Gap.w10,
                          Text(
                            l10n.activityAlarm_ringing,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: AppColors.warning.shade800,
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
                          width: 88,
                          height: 88,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.1),
                            border: Border.all(
                              color: AppColors.surfaceContainerLowest,
                            ),
                          ),
                          child: Icon(
                            AppIcons.notificationActive,
                            size: 36.0,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      Gap.h24,
                      ActivityAlarmReveal(
                        delay: const Duration(milliseconds: 90),
                        child: Text(
                          timeText,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                            color: AppColors.surfaceContainerLowest,
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
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: AppColors.surfaceContainerLowest,
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
                          padding: EdgeInsets.all(18.0),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(
                              16.0,
                            ),
                            border: Border.all(
                              color: AppColors.ghostBorder(0.08),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.lbl_activity,
                                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Gap.h8,
                              Text(
                                title,
                                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (reminderText != null &&
                                  reminderText.trim().isNotEmpty) ...[
                                Gap.h16,
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                    vertical: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(
                                      16.0,
                                    ),
                                  ),
                                  child: Text(
                                    reminderText,
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: AppColors.warning,
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
                        child: CompactLoadingWidget(
                          message: l10n.activityAlarm_startingAudio,
                          size: 18.0,
                          baseColor: AppColors.warning.withValues(alpha: 0.24),
                          highlightColor: AppColors.surfaceContainerLowest,
                          backgroundColor: AppColors.onSurface.withValues(alpha: 0.24),
                          borderColor: AppColors.surfaceContainerLowest.withValues(
                            alpha: 0.18,
                          ),
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
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.surfaceContainerLowest,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: Text(
                      l10n.activityAlarm_dismiss,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.surfaceContainerLowest,
                      ),
                    ),
                  ),
                ),
                Gap.h10,
                ActivityAlarmReveal(
                  delay: const Duration(milliseconds: 260),
                  child: OutlinedButton(
                    onPressed: _openActivity,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      side: BorderSide(
                        color: AppColors.surfaceContainerLowest,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: Text(
                      l10n.activityAlarm_viewActivity,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.surfaceContainerLowest,
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
