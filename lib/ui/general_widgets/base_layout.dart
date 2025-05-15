import 'package:aesthetics_labs_admin/ui/general_widgets/drawer.dart';
import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;

  const BaseLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const MyDrawer(), // Drawer displayed on the left side
        Expanded(child: child), // Main content area
      ],
    );
  }
}
