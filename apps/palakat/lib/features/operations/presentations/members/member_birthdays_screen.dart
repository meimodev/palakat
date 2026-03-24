import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/members/member_birthdays_controller.dart';
import 'package:palakat/features/operations/presentations/operations_motion_widget.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' as shared;

class MemberBirthdaysScreen extends ConsumerWidget {
  const MemberBirthdaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(memberBirthdaysControllerProvider);
    final controller = ref.read(memberBirthdaysControllerProvider.notifier);

    final start = state.filterStartDate;
    final end = state.filterEndDate;
    final selectedRange = (start != null && end != null)
        ? DateTimeRange(start: start, end: end)
        : null;

    final items = _birthdaysInRange(state.memberships, selectedRange);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OperationsReveal(
            child: ScreenTitleWidget.titleSecondary(
              title: l10n.tbl_birth,
              subTitle: state.scopeLabel,
              onBack: () => context.pop(),
            ),
          ),
          Gap.h16,
          OperationsReveal(
            delay: const Duration(milliseconds: 40),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: DateRangePresetInput(
                label: l10n.lbl_dateRange,
                start: start,
                end: end,
                showYear: false,
                allowedPresets: const [
                  DateRangePreset.allTime,
                  DateRangePreset.thisWeek,
                  DateRangePreset.thisMonth,
                  DateRangePreset.thisYear,
                  DateRangePreset.lastWeek,
                  DateRangePreset.lastMonth,
                  DateRangePreset.lastYear,
                  DateRangePreset.custom,
                ],
                onChanged: (s, e) {
                  controller.setDateRange(start: s, end: e);
                },
              ),
            ),
          ),
          Gap.h16,
          Expanded(
            child: LoadingWrapper(
              loading: state.isLoading,
              hasError: state.errorMessage != null && !state.isLoading,
              errorMessage: state.errorMessage,
              onRetry: controller.fetchMembers,
              shimmerPlaceholder: PalakatShimmerPlaceholders.listSection(),
              child: _BirthdaysContent(items: items),
            ),
          ),
        ],
      ),
    );
  }
}

class _BirthdaysContent extends StatelessWidget {
  const _BirthdaysContent({required this.items});

  final List<_BirthdayItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (items.isEmpty) {
      return OperationsAnimatedPresence(
        visible: true,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: InfoBoxWidget(message: l10n.err_noData),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: 16.0),
      itemCount: items.length,
      separatorBuilder: (context, index) => Gap.h12,
      itemBuilder: (context, index) {
        final item = items[index];
        final membership = item.membership;
        final account = membership.account;
        final name = account?.name ?? l10n.lbl_unknown;
        final dateLabel = item.date.ddMmmm;
        final id = membership.id;

        return OperationsReveal(
          delay: Duration(milliseconds: 40 + (index * 30)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
              boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 16),
            ),
            child: Material(
              color: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  SanctuaryLayout.radiusLarge,
                ),
                side: BorderSide(color: AppColors.ghostBorder(0.08)),
              ),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: id == null
                    ? null
                    : () {
                        context.pushNamed(
                          AppRoute.memberDetail,
                          pathParameters: {'membershipId': id.toString()},
                        );
                      },
                borderRadius: BorderRadius.circular(
                  SanctuaryLayout.radiusLarge,
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 36.0,
                        height: 36.0,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.18),
                          ),
                          shape: BoxShape.circle,
                          boxShadow: SanctuaryDepth.ambient(
                            opacity: 0.02,
                            blur: 8,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          AppIcons.birthday,
                          size: 16.0,
                          color: AppColors.warning,
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                            ),
                            Gap.h4,
                            Text(
                              dateLabel,
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      if (account?.claimed == true) ...[
                        Gap.w8,
                        Icon(
                          AppIcons.verified,
                          size: 16.0,
                          color: AppColors.success,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BirthdayItem {
  const _BirthdayItem({required this.membership, required this.date});

  final shared.Membership membership;
  final DateTime date;
}

List<_BirthdayItem> _birthdaysInRange(
  List<shared.Membership> memberships,
  DateTimeRange? range,
) {
  final now = DateTime.now();

  DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  final start = dateOnly(range?.start ?? DateTime(now.year, 1, 1));
  final end = dateOnly(range?.end ?? DateTime(now.year, 12, 31));

  final items = <_BirthdayItem>[];

  for (final m in memberships) {
    final dob = m.account?.dob;
    if (dob == null) continue;

    final yearsToCheck = <int>[];
    for (var y = start.year - 1; y <= end.year + 1; y++) {
      yearsToCheck.add(y);
    }

    DateTime? inRangeDate;
    for (final y in yearsToCheck) {
      final candidate = _safeDate(y, dob.month, dob.day);
      final day = dateOnly(candidate);
      final inRange = !day.isBefore(start) && !day.isAfter(end);
      if (inRange) {
        inRangeDate = day;
        break;
      }
    }

    if (inRangeDate != null) {
      items.add(_BirthdayItem(membership: m, date: inRangeDate));
    }
  }

  items.sort((a, b) => a.date.compareTo(b.date));
  return items;
}

DateTime _safeDate(int year, int month, int day) {
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;
  final safeDay = day > lastDayOfMonth ? lastDayOfMonth : day;
  return DateTime(year, month, safeDay);
}
