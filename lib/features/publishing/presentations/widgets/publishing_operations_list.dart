import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'widgets.dart';

class PublishingOperationsListWidget extends StatelessWidget {
  const PublishingOperationsListWidget({
    super.key,
    required this.data,
  });

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics:const NeverScrollableScrollPhysics(),

      itemBuilder: (context, index) {
        final d = data[index];
        return CardPublishingOperationWidget(
          title: d['title'],
          description: d['description'],
          onPressedCard: d['onPressed'],
        );
      },
      itemCount: data.length,
      separatorBuilder: (BuildContext context, int index) => Gap.h12,
    );
  }
}

