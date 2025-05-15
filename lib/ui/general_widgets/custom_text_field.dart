import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, this.controller, required this.title, this.hint, this.onChanged, this.inputFormatters, this.keyboardType, this.width});
  final TextEditingController? controller;
  final String title;
  final String? hint;
  final Function? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: hint,
              labelText: title,
            ),
            onChanged: (value) {
              if (onChanged != null) {
                onChanged!(value);
              }
            },
            inputFormatters: inputFormatters,
            keyboardType: keyboardType),
      ),
    );
  }
}
