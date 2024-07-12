import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';

import 'widgets/widgets.dart';

final List<Map<String, dynamic>> _data = List.generate(
  10,
  (index) => {
    "title": "KJ no.$index Something Something",
    "snippet":
        "Lorem ipsum dolor sit amet something something to make, to something",
    "onPressed": () {
      // print("Pressed $index");
    },
  },
);

class SongBookScreen extends StatelessWidget {
  const SongBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(
            title: "Song Book",
          ),
          Gap.h24,
          InputWidget.text(
            hint: "Search title / lirics",
            endIcon: Assets.icons.line.search,
            borderColor: BaseColor.primary3,
          ),
          Gap.h12,
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _data.length,
            separatorBuilder: (context, index) => Gap.h12,
            itemBuilder: (context, index) {
              final d = _data[index];

              return CardSongSnippetListItemWidget(
                title: d['title'],
                snippet: d['snippet'],
                onPressed: d['onPressed'],
              );
            },
          )
        ],
      ),
    );
  }
}
