import 'dart:async';
import 'package:aesthetics_labs_admin/controllers/branch_controller.dart';
import 'package:aesthetics_labs_admin/controllers/product_controller.dart';
import 'package:aesthetics_labs_admin/models/branch_model.dart';
import 'package:aesthetics_labs_admin/models/session_model.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/base_layout.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_app_bar.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_text_field.dart';
import 'package:booking_calendar/booking_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNewBooking extends StatefulWidget {
  const AddNewBooking({super.key});

  @override
  State<AddNewBooking> createState() => _AddNewBookingState();
}

class _AddNewBookingState extends State<AddNewBooking> {
  final now = DateTime.now();
  late BookingService currentBookingService;
  CollectionReference bookings = FirebaseFirestore.instance.collection('bookings');
  BranchController branchController = Get.find(tag: "branchController");
  final TextEditingController _userPhoneController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  ProductController productController = Get.find(tag: "productController");
  late BranchModel selectedBranch;
  late ProductModel selectedProduct = productController.products[0];
  final GlobalKey _bookingCalendarKey = GlobalKey();
  int selectedRoom = 1;

  @override
  void initState() {
    super.initState();
    selectedBranch = branchController.branches[0];

    currentBookingService = BookingService(
      serviceName: selectedProduct.title,
      serviceDuration: selectedProduct.duration.toInt(),
      bookingStart: DateTime(now.year, now.month, now.day, 12, 0),
      bookingEnd: DateTime(now.year, now.month, now.day, 21, 0),
      userId: "userID",
      roomId: selectedRoom.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(titleText: "Booking"),
      body: BaseLayout(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                if (branchController.branches.isNotEmpty && productController.products.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDropdownContainer(
                          child: DropdownButton(
                            isExpanded: true,
                            value: selectedProduct,
                            hint: const Text("Select Treatment"),
                            icon: const Icon(Icons.calendar_month),
                            items: productController.products.map((productItem) {
                              return DropdownMenuItem(
                                value: productItem,
                                child: Text(productItem.title.toString()),
                              );
                            }).toList(),
                            onChanged: (ProductModel? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedProduct = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        _buildDropdownContainer(
                          child: DropdownButton(
                            isExpanded: true,
                            value: selectedBranch,
                            hint: const Text("Select Branch"),
                            icon: const Icon(Icons.pin_drop_sharp),
                            items: branchController.branches.map((branch) {
                              return DropdownMenuItem(
                                value: branch,
                                child: Text(branch.branchName.toString()),
                              );
                            }).toList(),
                            onChanged: (BranchModel? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedBranch = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        _buildDropdownContainer(
                          child: DropdownButton(
                            isExpanded: true,
                            value: selectedRoom,
                            hint: const Text("Select Room"),
                            icon: const Icon(Icons.house_rounded),
                            items: List.generate(selectedBranch.roomsCount ?? 1, (index) {
                              return DropdownMenuItem(
                                value: index + 1,
                                child: Text("Room ${index + 1}"),
                              );
                            }),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedRoom = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        CustomTextField(title: "User Phone", controller: _userPhoneController, width: 250),
                        CustomTextField(title: "User Name", controller: _userNameController, width: 250),
                      ],
                    ),
                  ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .8,
                  child: Center(
                    child: BookingCalendar(
                      bookingService: currentBookingService,
                      convertStreamResultToDateTimeRanges: ({required dynamic streamResult}) => [],
                      getBookingStream: ({required DateTime start, required DateTime end}) => null, // Removed Firestore fetch
                      uploadBooking: uploadBookingFirebase,
                      bookedSlotColor: primaryColor,
                      bookingButtonColor: primaryColor,
                      selectedSlotColor: secondaryColor,
                      availableSlotColor: tertiaryColor,
                      loadingWidget: const Center(child: Text('Loading...')), // Updated
                      uploadingWidget: const CircularProgressIndicator(),
                      errorWidget: const Center(child: Text('Error occurred')), // Updated
                      locale: 'en_us',
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      wholeDayIsBookedWidget: const Text('Sorry, everything is booked'),
                      bookingGridCrossAxisCount: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method to build dropdown containers
  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor),
        color: primaryColor.withOpacity(0.3),
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child: child,
    );
  }

  /// Uploads new booking to Firestore
  Future<void> uploadBookingFirebase({required BookingService newBooking}) async {
    try {
      await bookings
          .doc(selectedBranch.branchId)
          .collection('bookings')
          .add(newBooking.toJson());

      print("Booking Added");
      _userNameController.clear();
      _userPhoneController.clear();
    } catch (error) {
      print("Failed to add booking: $error");
    }
  }
}
