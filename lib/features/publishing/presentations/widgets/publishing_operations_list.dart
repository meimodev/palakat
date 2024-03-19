import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'widgets.dart';

class PublishingOperationsListWidget extends StatelessWidget {
  const PublishingOperationsListWidget({
    super.key,
    required this.data,required this.onPressedCard,
  });

  final List<Map<String, dynamic>> data;
  final VoidCallback onPressedCard;

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
          onPressedCard: onPressedCard,
        );
      },
      itemCount: data.length,
      separatorBuilder: (BuildContext context, int index) => Gap.h12,
    );
  }
}

