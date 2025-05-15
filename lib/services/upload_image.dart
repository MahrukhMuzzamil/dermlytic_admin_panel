import 'dart:io';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_loading_message_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

class UploadImageService {
  final storageRef = FirebaseStorage.instance.ref();
  Future<String?> uploadFile(File file, String firbasePath) async {
    customLoadingMessageDialog("Image is uploading");
    String fileName = basename(file.path);
    var snapshot = storageRef.child('$firbasePath/$fileName');
    try {
      await snapshot.putFile(file);
      String url = await snapshot.getDownloadURL();
      Get.back(); //remove the loading dialog
      return url;
    } on FirebaseException catch (e) {
      Get.back(); //remove the loading dialog
      debugPrint(e.toString());
    }

    return null;
  }

  Future<String> fromWebUploadImage(Uint8List fileBytes, String path) async {
    customLoadingMessageDialog("Image is uploading");
    String url = "";
    var name = Timestamp.now().millisecondsSinceEpoch;
    var snapshot = storageRef.child('$path/$name');
    TaskSnapshot task = await snapshot.putData(
      fileBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    url = await task.ref.getDownloadURL();
    if (url.isNotEmpty) {
      // databaseController.isFileUploaded.value = true;
      Get.back(); //remove the loading dialog
      printInfo(info: "image uploaded$url");
    } else {
      Get.snackbar("error", "image not uploaded");
    }
    return url;
  }
}
