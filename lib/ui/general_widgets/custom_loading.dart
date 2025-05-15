import 'package:flutter/material.dart';
import 'package:get/get.dart';

  customLoadingDialog() {
  //display a get loading popup before reading
  Get.dialog(
    const Center(
      child: CircularProgressIndicator(
        color: Colors.white,
      ),
    ),
    barrierDismissible: false,
  );
}
