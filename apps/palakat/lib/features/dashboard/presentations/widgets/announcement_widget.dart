import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets.dart';

class AnnouncementWidget extends ConsumerWidget {
  const AnnouncementWidget({
    super.key,
    required this.onPressedViewAll,
    required this.announcements,
  });

  final void Function() onPressedViewAll;
  final List<Activity> announcements;

  Future<void> _openUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentTitleWidget(
          onPressedViewAll: onPressedViewAll,
          count: announcements.length,
          title: context.l10n.activityType_announcement,
          leadingIcon: AppIcons.announcement,
          leadingBg: BaseColor.yellow[50],
          leadingFg: BaseColor.yellow[700],
        ),
        Gap.h12,
        if (announcements.isEmpty)
          const SizedBox()
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: announcements.length,
            separatorBuilder: (_, _) => Gap.h12,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              final fileId = announcement.fileId;
              return CardAnnouncementWidget(
                title: announcement.title,
                publishedOn: announcement.date,
                onPressedCard: () {
                  context.pushNamed(
                    AppRoute.activityDetail,
                    pathParameters: {'activityId': announcement.id.toString()},
                  );
                },
                onPressedDownload: fileId == null
                    ? null
                    : () async {
                        final repo = ref.read(fileManagerRepositoryProvider);
                        final result = await repo.resolveDownloadUrl(
                          fileId: fileId,
                        );
                        result.when(
                          onSuccess: (url) => _openUrl(url),
                          onFailure: (failure) {
                            final msg = failure.message.trim();
                            if (msg.isEmpty) return;
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(msg)));
                          },
                        );
                      },
              );
            },
          ),
      ],
    );
  }
}
