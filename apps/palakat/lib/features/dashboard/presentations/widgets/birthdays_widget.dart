import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' as shared;
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/services.dart';

final thisWeekBirthdaysProvider =
    FutureProvider.autoDispose<List<BirthdayItem>>((ref) async {
      final local = ref.read(localStorageServiceProvider);
      final membership =
          local.currentMembership ?? local.currentAuth?.account.membership;
      final permissionRepo = ref.read(churchPermissionPolicyRepositoryProvider);

      final permissionsResult = await permissionRepo.fetchMyPermissions();
      var canReadMembers = membership?.membershipPositions.isNotEmpty ?? false;
      permissionsResult.when(
        onSuccess: (permissions) {
          canReadMembers = permissions.permissions.contains('ops.members.read');
          return null;
        },
        onFailure: (_) {},
      );

      if (!canReadMembers) return const <BirthdayItem>[];

      final churchId = membership?.church?.id ?? membership?.column?.churchId;
      final columnId = membership?.column?.id;

      if (churchId == null) return const <BirthdayItem>[];

      final membershipRepo = ref.read(membershipRepositoryProvider);

      final request =
          shared.PaginationRequestWrapper<shared.GetFetchMemberPosition>(
            page: 1,
            pageSize: 200,
            sortBy: 'id',
            sortOrder: 'desc',
            data: shared.GetFetchMemberPosition(
              churchId: churchId,
              columnId: columnId,
            ),
          );

      final result = await membershipRepo.fetchMemberPositionsPagination(
        paginationRequest: request,
      );

      final response = result.when(
        onSuccess: (res) => res,
        onFailure: (failure) => throw failure,
      );

      final memberships = response?.data ?? const <shared.Membership>[];

      final now = DateTime.now();
      final range = DateTimeRange(
        start: now.toStartOfTheWeek,
        end: now.toEndOfTheWeek,
      );

      return _birthdaysInRange(memberships, range);
    });

class BirthdaysWidget extends ConsumerWidget {
  const BirthdaysWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(thisWeekBirthdaysProvider);

    final failure = async.error is shared.Failure
        ? (async.error as shared.Failure)
        : null;
    final errorMessage = failure?.message;

    return LoadingWrapper(
      loading: async.isLoading,
      hasError: async.hasError && (errorMessage != null),
      errorMessage: errorMessage,
      onRetry: () => ref.invalidate(thisWeekBirthdaysProvider),
      shimmerPlaceholder: Column(
        children: [
          PalakatShimmerPlaceholders.listItemCard(),
          Gap.h8,
          PalakatShimmerPlaceholders.listItemCard(),
        ],
      ),
      child: Builder(
        builder: (_) {
          final items = async.value ?? const <BirthdayItem>[];
          if (items.isEmpty) return const SizedBox();

          final l10n = context.l10n;

          final maxItems = 5;
          final itemCount = items.length > maxItems ? maxItems : items.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Gap.h16,
              SegmentTitleWidget(
                onPressedViewAll: () =>
                    context.pushNamed(AppRoute.memberBirthdays),
                count: items.length,
                title: '${l10n.tbl_birth} - ${l10n.dateRangeFilter_thisWeek}',
                titleStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                leadingIcon: AppIcons.birthday,
                leadingBg: AppColors.warning.shade100,
                leadingFg: AppColors.warning.shade700,
              ),
              Gap.h12,
              ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                separatorBuilder: (_, _) => Gap.h12,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final membership = item.membership;
                  final account = membership.account;
                  final id = membership.id;

                  final name = (account?.name.trim().isNotEmpty == true)
                      ? account!.name
                      : l10n.lbl_unknown;

                  return Material(
                    color: AppColors.surfaceContainerLowest,
                    elevation: 1,
                    shadowColor: AppColors.onSurface,
                    surfaceTintColor: AppColors.warning,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
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
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: AppColors.warning.shade100,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: AppColors.warning.shade200,
                                ),
                                boxShadow: SanctuaryDepth.ambient(
                                  opacity: 0.02,
                                  blur: 8,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                AppIcons.birthday,
                                size: 16.0,
                                color: AppColors.warning.shade700,
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                  ),
                                  Gap.h4,
                                  Text(
                                    item.date.ddMmmm,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
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
                  );
                },
              ),
              Gap.h16,
            ],
          );
        },
      ),
    );
  }
}

class BirthdayItem {
  const BirthdayItem({required this.membership, required this.date});

  final shared.Membership membership;
  final DateTime date;
}

List<BirthdayItem> _birthdaysInRange(
  List<shared.Membership> memberships,
  DateTimeRange range,
) {
  DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  final start = dateOnly(range.start);
  final end = dateOnly(range.end);

  final items = <BirthdayItem>[];

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
      items.add(BirthdayItem(membership: m, date: inRangeDate));
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
