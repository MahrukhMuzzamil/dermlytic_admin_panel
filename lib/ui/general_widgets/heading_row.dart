import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:flutter/material.dart';

class HeadingRow extends StatelessWidget {
  const HeadingRow({super.key, required this.title, this.width});
  final String title;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      color: primaryColor,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }
}
