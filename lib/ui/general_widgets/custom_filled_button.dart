import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({super.key, required this.title, required this.onPress, this.color, this.width, this.height, this.isDisabled});

  final String title;
  final Function onPress;
  final Color? color;
  final double? width;
  final double? height;
  final bool? isDisabled;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (isDisabled != null && isDisabled == true) return;
        onPress();
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: isDisabled != null && isDisabled == true ? disabledColor : color ?? primaryColor,
        minimumSize: Size(width ?? 120, height ?? 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        title,
        style: bodyFontStyleBold,
      ),
    );
  }
}
