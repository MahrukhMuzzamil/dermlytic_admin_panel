import 'dart:io';
import 'package:aesthetics_labs_admin/controllers/branch_controller.dart';
import 'package:aesthetics_labs_admin/services/upload_image.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:aesthetics_labs_admin/ui/branch_management/address_input_widget.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/base_layout.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_app_bar.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_filled_button.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_loading.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_loading_message_dialog.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import '../../../models/branch_model.dart';

class UpdateBranchPage extends StatefulWidget {
  final BranchModel branch;

  const UpdateBranchPage({super.key, required this.branch});

  @override
  State<UpdateBranchPage> createState() => _UpdateBranchPageState();
}

class _UpdateBranchPageState extends State<UpdateBranchPage> {
  final BranchController _branchController = Get.find(tag: 'branchController');

  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _branchPhoneController = TextEditingController();
  final TextEditingController _branchDescriptionController = TextEditingController();
  XFile? _branchImage;
  Uint8List? imageBytes;
  AddressModel? _branchAddress;
  @override
  void initState() {
    super.initState();
    // Initialize text controllers with branch details
    _branchNameController.text = widget.branch.branchName;
    _branchPhoneController.text = widget.branch.branchPhone!;
    _branchDescriptionController.text = widget.branch.branchDescription!;
    _branchAddress = widget.branch.branchAddress;
    debugPrint("branchId is ${widget.branch.branchId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(titleText: "Update a Branch"),
      body: BaseLayout(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: Get.width * .4,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _branchNameController,
                              title: "Branch Name",
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: _branchPhoneController,
                              title: "Branch Phone",
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              controller: _branchDescriptionController,
                              title: "Branch Description",
                            ),
                            const SizedBox(height: 10),
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
                                      : widget.branch.branchImage != null
                                          ? Image.network(widget.branch.branchImage!)
                                          : Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: primaryColor),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
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
                          ],
                        ),
                      ),
                      SizedBox(
                        width: Get.width * .4,
                        child: BranchAddressEditWidget(
                          address: _branchAddress ??
                              AddressModel(
                                name: "",
                                latitude: 0,
                                longitude: 0,
                              ),
                          onAddressChanged: (value) {
                            debugPrint("address changed${value.latitude}");
                            setState(() {
                              _branchAddress = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomFilledButton(
                  title: "Update Branch",
                  width: Get.width * .25,
                  onPress: () async {
                    if (_branchNameController.text.isEmpty) {
                      Get.snackbar("Error", "Branch name is required");
                      return;
                    }
                    String? url;
                    if (imageBytes != null) {
                      url = await UploadImageService().fromWebUploadImage(imageBytes!, "branches");
                      debugPrint("url is $url");
                    }

                    customLoadingDialog();
                    
                    BranchModel branch = widget.branch.copyWith(
                      branchName: _branchNameController.text,
                      branchPhone: _branchPhoneController.text,
                      branchDescription: _branchDescriptionController.text,
                      branchAddress: _branchAddress,
                      branchImage: url,
                    );
                    await _branchController.updateBranch(branch);
                    Get.back();
                  },
                ),
                SizedBox(
                  width: Get.width * .05,
                ),
                CustomFilledButton(
                  title: "Delete Branch",
                  color: Colors.red,
                  width: Get.width * .25,
                  onPress: () async {
                    customLoadingMessageDialog("Deleting branch, Please wait...");
                    bool isSuccess = await _branchController.deleteBranch(widget.branch.branchId!);
                    Get.back();
                    if (isSuccess) {
                      Get.snackbar("Success", "Branch deleted");
                      Get.back();
                    } else {
                      Get.snackbar("Failure", "Something went wrong please try again");
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
