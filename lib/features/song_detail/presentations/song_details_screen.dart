import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/scaffold/scaffold_widget.dart';
import 'package:palakat/core/widgets/screen_title/screen_title_widget.dart';

class SongDetails extends StatelessWidget {
  const SongDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Column(
        children: [
          ScreenTitleWidget.primary(
            title: 'KJ NO. 999',
            subTitle: 'KAMI PUJI DENGAN RIANG, DIKAU ALLAH YANG BESAR',
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: BaseColor.black,
            onPressedLeadIcon: () {
              Navigator.pop(context);
            },
          ),
          Gap.h24,
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'verse 1',
              style: BaseTypography.bodyMedium.toBold.toSecondary,
            ),
          ),
          Gap.h6,
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
            style: BaseTypography.bodyMedium.toPrimary,
          ),
          Gap.h12,
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'verse 2',
              style: BaseTypography.bodyMedium.toBold.toSecondary,
            ),
          ),
          Gap.h6,
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ',
            style: BaseTypography.bodyMedium.toPrimary,
          ),
          Gap.h12,
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Back to verse 1',
              style: BaseTypography.bodyMedium.toBold.toSecondary,
            ),
          ),
          Gap.h12,
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Back to verse 3',
              style: BaseTypography.bodyMedium.toBold.toSecondary,
            ),
          ),
          Gap.h12,
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'chorus',
              style: BaseTypography.bodyMedium.toBold.toSecondary,
            ),
          ),
          Gap.h6,
          Text(
            'at. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequ',
            style: BaseTypography.bodyMedium.toPrimary,
          ),
          Gap.h24,
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Link youtube / video title',
              style: BaseTypography.bodyMedium.toBold.toSecondary,
            ),
          ),
          Gap.h6,
          CachedNetworkImage(
              imageUrl:
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSzFxtFXz3P2AI7Yz3sIMfDtim_wROjrNwetA&s')
        ],
      ),
    );
  }
}
