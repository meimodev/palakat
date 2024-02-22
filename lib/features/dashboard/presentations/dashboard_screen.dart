import 'package:flutter/material.dart';
import 'package:palakat/core/widgets/scaffold/scaffold_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldWidget(
      backgroundColor: Colors.blue,
      child: Center(
        child: Text("Dashboard Screen"),
      ),
    );
  }
}
