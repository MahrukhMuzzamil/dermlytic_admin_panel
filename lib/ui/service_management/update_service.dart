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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UpdateServicePage extends StatefulWidget {
  const UpdateServicePage({super.key, required this.productModel});
  final ProductModel productModel;
  @override
  State<UpdateServicePage> createState() => _UpdateServicePageState();
}

class _UpdateServicePageState extends State<UpdateServicePage> {
  final ProductController productController = Get.find(tag: "productController");
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  XFile? _branchImage;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    // Populate the text controllers with data from productModel
    titleController.text = widget.productModel.title;
    priceController.text = widget.productModel.price.toString();
    durationController.text = widget.productModel.duration.toString();
    discountController.text = widget.productModel.discount.toString();
    descriptionController.text = widget.productModel.description ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(titleText: "Update Service"),
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
                      // Add the image selection widget here
                    ],
                  ),
                ),
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
                  child: _branchImage != null
                      ? kIsWeb
                          ? Image.memory(imageBytes!)
                          : Image.file(File(_branchImage!.path))
                      : widget.productModel.imageUrl != null
                          ? Image.network(widget.productModel.imageUrl)
                          : Container(
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
                                  Text("Click to choose image for Branch"),
                                ],
                              ),
                            ),
                ),
              ),

              const SizedBox(height: 20),
              // Add the update button here
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomFilledButton(
                    title: "Update Service",
                    width: Get.width * .25,
                    onPress: () async {
                      customLoadingMessageDialog("Updating Service...");
                      try {
                        String? url;
                        if (imageBytes != null) {
                          url = await UploadImageService().fromWebUploadImage(imageBytes!, "branches");
                          debugPrint("url is $url");
                        }
                        if (imageBytes != null && url == null) {
                          print("Error uploading image");
                          Get.back();
                          return;
                        }

                        ProductModel productModel = ProductModel(
                          title: titleController.text,
                          imageUrl: url ?? widget.productModel.imageUrl,
                          price: double.parse(priceController.text),
                          duration: double.parse(durationController.text),
                          discount: double.parse(discountController.text),
                          description: descriptionController.text,
                        );
                        bool isSuccess = await productController.updateProduct(productModel);
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
                  ),
                  SizedBox(
                    width: Get.width * .05,
                  ),
                  CustomFilledButton(
                    title: "Delete Service",
                    color: Colors.red,
                    width: Get.width * .25,
                    onPress: () async {
                      customLoadingMessageDialog("Deleting Service, Please wait...");
                      bool isSuccess = await productController.deleteProduct(widget.productModel.productId!);
                      Get.back();
                      if (isSuccess) {
                        Get.snackbar("Success", "Product deleted");
                        Get.back();
                      } else {
                        Get.snackbar("Failure", "Something went wrong please try again");
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
