import 'dart:io';

import 'package:aesthetics_labs_admin/controllers/product_controller.dart';
import 'package:aesthetics_labs_admin/models/session_model.dart';
import 'package:aesthetics_labs_admin/services/upload_image.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/base_layout.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_app_bar.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_filled_button.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_loading_message_dialog.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_text_field.dart';
import 'package:aesthetics_labs_admin/ui/service_management/view_all_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

class AddNewService extends StatefulWidget {
  const AddNewService({super.key});

  @override
  State<AddNewService> createState() => _AddNewServiceState();
}

class _AddNewServiceState extends State<AddNewService> {
  late ProductModel productModel;
  final ProductController productController = Get.find(tag: "productController");
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  XFile? _branchImage;
  Uint8List? imageBytes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(titleText: "Add New Service"),
      body: BaseLayout(
        child: SingleChildScrollView(
            child: Column(
          children: [
            Center(
              child: SizedBox(
                width: Get.width * .6,
                child: Column(
                  children: [
                    CustomTextField(
                      title: "Title",
                      controller: titleController,
                      inputFormatters: const [],
                    ),
                    CustomTextField(
                      title: "Price",
                      controller: priceController,
                      keyboardType: TextInputType.number,
                    ),
                    CustomTextField(
                      title: "Duration",
                      controller: durationController,
                      keyboardType: TextInputType.number,
                    ),
                    CustomTextField(
                      title: "Discount",
                      controller: discountController,
                      keyboardType: TextInputType.number,
                    ),
                    CustomTextField(
                      title: "Description",
                      controller: descriptionController,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 370, maxHeight: 500),
                      child: GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            var f = await image.readAsBytes();
                            setState(() {
                              _branchImage = image;
                              imageBytes = f;
                            });
                          }
                        },
                        child: _branchImage == null
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: primaryColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                // max height of 100

                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.photo_size_select_actual_outlined,
                                      size: 300,
                                      color: primaryColor,
                                    ),
                                    Text("Click to choose image for Service"),
                                  ],
                                ),
                              )
                            : kIsWeb
                                ? Image.memory(imageBytes!)
                                : Image.file(File(_branchImage!.path)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomFilledButton(
              title: "Add a service",
              width: Get.width * .3,
              onPress: () async {
                customLoadingMessageDialog("Adding Service...");
                try {
                  String? url;
                  if (imageBytes != null) {
                    url = await UploadImageService().fromWebUploadImage(imageBytes!, "branches");
                    debugPrint("url is $url");
                  }
                  if (url == null) return;

                  productModel = ProductModel(
                    title: titleController.text,
                    imageUrl: url,
                    price: double.parse(priceController.text),
                    duration: double.parse(durationController.text),
                    discount: double.parse(discountController.text),
                    description: descriptionController.text,
                  );
                  bool isSuccess = await productController.addProduct(productModel);
                  Get.back();
                  if (isSuccess) {
                    Get.snackbar("Product added Successfully", "");
                    Get.off(ViewAllServices());
                  } else {
                    Get.snackbar("Error", "Error adding product");
                  }
                } catch (e) {
                  Get.back(); // close the dialog
                  Get.snackbar("Error", "Error adding product");
                }
              },
            )
          ],
        )),
      ),
    );
  }
}
