import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:flutter/material.dart';

class CustomHollowButton extends StatelessWidget {
  const CustomHollowButton({required this.title, required this.onPress, this.heigth, this.width, this.borderColor, this.isClicked, super.key});
  final String title;
  final Function onPress;
  final double? heigth;
  final double? width;
  final Color? borderColor;
  final bool? isClicked;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => {onPress()},
      style: ButtonStyle(
        backgroundColor: isClicked ?? false ? WidgetStateProperty.all<Color>(primaryColor.withOpacity(0.1)) : WidgetStateProperty.all<Color>(Colors.white),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
        minimumSize: WidgetStateProperty.all<Size>(Size(width ?? 50, heigth ?? 60)),
        //set height of 60
        // minimumSize: MaterialStateProperty.all<Size>(Size(150, 60)),
        side: isClicked ?? false
            ? WidgetStateProperty.all<BorderSide>(
                BorderSide(
                  color: primaryColor.withOpacity(0.01),
                  width: 1,
                ),
              )
            : null,
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: const BorderSide(
              color: primaryColor,
            ),
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, color: isClicked ?? false ? primaryColor : Colors.grey[700]),
      ),
    );
  }
}
