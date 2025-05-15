import 'package:aesthetics_labs_admin/controllers/user_controller.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

AppBar customAppBar({
  String? titleText,
  Widget? leading,
  double? titleFont,
  List<Widget>? actions,
  Color? backgroundColor, 
}) {
  UserController userController = Get.find(tag: "userController");
  return AppBar(
    backgroundColor: backgroundColor ?? primaryColor,
    bottomOpacity: 0,
    foregroundColor: primaryColor,
  
    centerTitle: true,
    elevation: 0,

    actions: actions ??
        [
          const SizedBox(width: 100),
          Text(
            userController.email,
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
        ],
    leading: leading,
    title: SizedBox(
      width: double.infinity,
      child: Text(
        titleText ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: titleFont ?? 25.0, color: Colors.black),
      ),
    ),
  );
}
