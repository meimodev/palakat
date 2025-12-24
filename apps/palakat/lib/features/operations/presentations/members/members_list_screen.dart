import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/extension.dart';

/// Screen for viewing and managing church members.
/// Displays a list of current members with search and filter capabilities.
class MembersListScreen extends ConsumerWidget {
  const MembersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.titleSecondary(
            title: l10n.operationsItem_view_members_title,
            onBack: () => Navigator.of(context).pop(),
          ),
          Gap.h16,
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.group,
                    size: BaseSize.w48,
                    color: BaseColor.textSecondary,
                  ),
                  Gap.h16,
                  Text(
                    l10n.operationsItem_view_members_title,
                    style: BaseTypography.titleMedium.copyWith(
                      color: BaseColor.textPrimary,
                    ),
                  ),
                  Gap.h8,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: BaseSize.w32),
                    child: Text(
                      l10n.operationsItem_view_members_desc,
                      textAlign: TextAlign.center,
                      style: BaseTypography.bodyMedium.copyWith(
                        color: BaseColor.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
