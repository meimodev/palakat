import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/operations/presentations/members/member_birthdays_controller.dart';
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
          ScreenTitleWidget.titleSecondary(
            title: l10n.tbl_birth,
            subTitle: state.scopeLabel,
            onBack: () => context.pop(),
          ),
          Gap.h16,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
            child: DateRangePresetInput(
              label: l10n.lbl_dateRange,
              start: start,
              end: end,
              showYear: false,
              allowedPresets: const [
                DateRangePreset.allTime,
                DateRangePreset.thisWeek,
                DateRangePreset.thisMonth,
                DateRangePreset.lastWeek,
                DateRangePreset.lastMonth,
                DateRangePreset.custom,
              ],
              onChanged: (s, e) {
                controller.setDateRange(start: s, end: e);
              },
            ),
          ),
          Gap.h16,
          Expanded(
            child: LoadingWrapper(
              loading: state.isLoading,
              hasError: state.errorMessage != null && !state.isLoading,
              errorMessage: state.errorMessage,
              onRetry: controller.fetchMembers,
              shimmerPlaceholder: Column(
                children: [
                  PalakatShimmerPlaceholders.listItemCard(),
                  Gap.h8,
                  PalakatShimmerPlaceholders.listItemCard(),
                  Gap.h8,
                  PalakatShimmerPlaceholders.listItemCard(),
                ],
              ),
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
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: BaseSize.h12),
          child: InfoBoxWidget(message: l10n.err_noData),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: BaseSize.h16),
      itemCount: items.length,
      separatorBuilder: (context, index) => Gap.h12,
      itemBuilder: (context, index) {
        final item = items[index];
        final membership = item.membership;
        final account = membership.account;
        final name = account?.name ?? l10n.lbl_unknown;
        final dateLabel = item.date.ddMmmm;
        final id = membership.id;

        return Material(
          color: BaseColor.cardBackground1,
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          surfaceTintColor: BaseColor.yellow[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w12),
              child: Row(
                children: [
                  Container(
                    width: BaseSize.w36,
                    height: BaseSize.w36,
                    decoration: BoxDecoration(
                      color: BaseColor.yellow[100],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      AppIcons.calendarToday,
                      size: BaseSize.w16,
                      color: BaseColor.yellow[700],
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
                          style: BaseTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: BaseColor.black,
                          ),
                        ),
                        Gap.h4,
                        Text(
                          dateLabel,
                          style: BaseTypography.bodySmall.copyWith(
                            color: BaseColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (account?.claimed == true) ...[
                    Gap.w8,
                    Icon(
                      AppIcons.verified,
                      size: BaseSize.w16,
                      color: BaseColor.green[700],
                    ),
                  ],
                ],
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
