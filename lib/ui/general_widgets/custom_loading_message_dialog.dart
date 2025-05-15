import 'package:flutter/material.dart';
import 'package:get/get.dart';

customLoadingMessageDialog(String message) {
  //display a get loading popup before reading
  // Get.dialog(
  //   const Center(
  //     child: CircularProgressIndicator(
  //       color: Colors.white,
  //     ),
  //   ),
  //   barrierDismissible: false,
  // );
  Get.dialog(
    AlertDialog(
      title: const Text("Loading"),
      content: Row(
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Text(message),
        ],
      ),
    ),
    barrierDismissible: false,
  );
}
