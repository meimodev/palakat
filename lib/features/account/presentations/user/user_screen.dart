import 'package:flutter/material.dart';
import 'package:palakat/core/widgets/widgets.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Center(
        child: Text("User"),
      ),
    );
  }
}
