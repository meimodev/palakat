import 'package:flutter/material.dart';

class PublishingOperationsListWidget extends StatelessWidget {
  const PublishingOperationsListWidget({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children,
    );
  }
}
