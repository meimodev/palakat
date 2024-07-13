import 'package:flutter/material.dart';
import 'package:palakat/core/widgets/scaffold/scaffold_widget.dart';
import 'package:palakat/core/widgets/screen_title/screen_title_widget.dart';

class SongScreen extends StatelessWidget {
  const SongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Column(
        children: [const ScreenTitleWidget.titleOnly(title: 'Kidung')],
      ),
    );
  }
}
