import 'dart:async';

import 'package:aesthetics_labs_admin/models/branch_model.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BranchAddressEditWidget extends StatefulWidget {
  BranchAddressEditWidget({super.key, required this.address, required this.onAddressChanged});
  AddressModel address;
  Function onAddressChanged;

  @override
  State<BranchAddressEditWidget> createState() => _BranchAddressEditWidgetState();
}

class _BranchAddressEditWidgetState extends State<BranchAddressEditWidget> {
  final TextEditingController _branchAddressTextController = TextEditingController();

  final TextEditingController _branchLatitudeController = TextEditingController();

  final TextEditingController _branchLongitudeController = TextEditingController();

  final TextEditingController _branchUrlController = TextEditingController();

  Timer? _debounce;

  final RxString _branchCoordinatesErrorText = "".obs;
  @override
  void initState() {
    super.initState();
    debugPrint("address: ${widget.address.name}");
    _branchAddressTextController.text = widget.address.name.toString();
    _branchLatitudeController.text = widget.address.latitude.toString();
    _branchLongitudeController.text = widget.address.longitude.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomTextField(
            controller: _branchAddressTextController,
            title: "Branch Address",
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 1000), () {
                widget.onAddressChanged(widget.address.copyWith(
                  name: value,
                  ),
                );
              });
            }),
        const SizedBox(height: 10),
        CustomTextField(
          // controller: _branchUrlController,
          title: "Branch Maps URL",
          onChanged: (value) {
            if (_debounce?.isActive ?? false) _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 2000), () {
              extractLatLngFromAdUrl(value);
            });
          },
        ),
        Obx(() => _branchCoordinatesErrorText.value.isNotEmpty
            ? Row(
                children: [
                  Text(
                    _branchCoordinatesErrorText.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                  IconButton(
                      onPressed: () {
                        //show dialog with help
                        Get.defaultDialog(
                          title: "How to get branch coordinates?",
                          content: const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                                "1. Open Google Maps and copy URl from the address bar\n2. Paste the URL in the Branch URL field\n3. Branch coordinates will be automatically extracted from the URL\n4. if it still says coordinates are not correct please check if URL format is similar to these below mentioned urls\n\t=>https://www.google.com/maps/@31.4657265,74.3704655,15z?entry=ttu\n\t=>https://www.google.com/maps/place/606+Street+19,+Sector+X+DHA+Phase+3,+Lahore,+Punjab,+Pakistan/@31.4661718,74.3726426,19z/data=!4m6!3m5!1s0x3919067026d36245:0x837f657b6bf23e32!8m2!3d31.466579!4d74.3723325!16s%2Fg%2F11l55xv1qz?entry=ttu\n5. If the URL is still invalid, please enter the coordinates manually, like Latitude is 31.4726812, Longitude is 74.3751081 for DHA branch\n\nNote: Longitude and Latitude are important as they mention location of our branches on the map"),
                          ),
                          confirm: TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text("OK")),
                        );
                      },
                    icon: const Icon(Icons.help_outline_rounded, color: primaryColor),
                  )
                ],
              )
            : const SizedBox()),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomTextField(controller: _branchLatitudeController, title: "Branch Latitude"),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomTextField(controller: _branchLongitudeController, title: "Branch Longitude"),
            ),
          ],
        )
      ],
    );
  }

  void extractLatLngFromAdUrl(String address) async {
    try {
      // if url does not contain @ then it is not a valid url
      if (!address.contains("@")) {
        setLatLngToTextFields("0", "0");
        return;
      }

      // if url does not contain , then it is not a valid url
      if (!address.contains(",")) {
        setLatLngToTextFields("0", "0");
        return;
      }

      // if url does not contain z then it is not a valid url
      if (!address.contains("z")) {
        setLatLngToTextFields("0", "0");
        return;
      }
      address = address.split("@")[1];
      debugPrint("address: $address");
      String lat = address.split(",")[0];
      String lng = address.split(",")[1];

      // extract lat and lng from url
      // String lat = address.substring(address.indexOf("@") + 1, address.indexOf(","));
      // String lng = address.substring(address.indexOf(",") + 1, address.indexOf("z"));

      debugPrint("lat: $lat");
      debugPrint("lng: $lng");
      setLatLngToTextFields(lat, lng);

      // String lat = address.substring(address.indexOf("@") + 1, address.indexOf(","));
      // String lng = address.substring(address.indexOf(",") + 1, address.indexOf(","));
      // debugPrint("lat: $lat");
      // debugPrint("lng: $lng");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void setLatLngToTextFields(String lat, String lng) {
    _branchLatitudeController.text = lat;
    _branchLongitudeController.text = lng;

    if (lat == "0" && lng == "0") {
      _branchCoordinatesErrorText.value = "Invalid URL, please enter a valid URL";
    } else {
      _branchCoordinatesErrorText.value = "";
      widget.onAddressChanged(widget.address.copyWith(
        latitude: double.parse(lat),
        longitude: double.parse(lng),
      ));
    }
  }
}
