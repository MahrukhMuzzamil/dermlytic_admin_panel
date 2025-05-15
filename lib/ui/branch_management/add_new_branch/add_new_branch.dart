import 'dart:io';
import 'package:aesthetics_labs_admin/controllers/branch_controller.dart';
import 'package:aesthetics_labs_admin/models/branch_model.dart';
import 'package:aesthetics_labs_admin/services/upload_image.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:aesthetics_labs_admin/ui/branch_management/address_input_widget.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/base_layout.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_app_bar.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_loading.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_text_field.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddNewBranch extends StatefulWidget {
  const AddNewBranch({super.key});

  @override
  State<AddNewBranch> createState() => _AddNewBranchState();
}

class _AddNewBranchState extends State<AddNewBranch> {
  final BranchController _branchController = Get.find(tag: 'branchController');
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _branchPhoneController = TextEditingController();
  final TextEditingController _branchDescription = TextEditingController();
  final DateTime _openingTime = DateTime.now();
  final DateTime _closingTime = DateTime.now();
  XFile? _branchImage;
  Uint8List? imageBytes;
  AddressModel? _branchAddress;

  @override
  void initState() {
    super.initState();
    _branchAddress ??= AddressModel(name: "", latitude: 0, longitude: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(titleText: "Add New Branch"),
      body: BaseLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: Get.width * .35,
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
                          controller: _branchDescription,
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
                            child: _branchImage == null
                                ? Container(
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
                                  )
                                : kIsWeb
                                    ? Image.memory(imageBytes!)
                                    : Image.file(File(_branchImage!.path)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: Get.width * .35,
                    child: BranchAddressEditWidget(
                      address: _branchAddress ??
                          AddressModel(
                            name: "",
                            latitude: 0,
                            longitude: 0,
                          ),
                      onAddressChanged: (value) {
                        debugPrint("address changed");
                        setState(() {
                          _branchAddress = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () async {
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
                    BranchModel branch = BranchModel(
                      branchName: _branchNameController.text,
                      branchPhone: _branchPhoneController.text,
                      branchDescription: _branchDescription.text,
                      branchAddress: _branchAddress,
                      branchImage: url,
                      openingTime: _openingTime,
                      closingTime: _closingTime,
                    );
                    await _branchController.addBranch(branch);
                    Get.back();
                  },
                  child: const Text("Add Branch"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
