import 'dart:async';
import 'package:aesthetics_labs_admin/controllers/branch_controller.dart';
import 'package:aesthetics_labs_admin/controllers/product_controller.dart';
import 'package:aesthetics_labs_admin/models/branch_model.dart';
import 'package:aesthetics_labs_admin/models/session_model.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/base_layout.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_app_bar.dart';
import 'package:booking_calendar/booking_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aesthetics_labs_admin/ui/appointments/appointment_page_simple.dart';

class AddNewBooking extends StatefulWidget {
  const AddNewBooking({super.key});

  @override
  State<AddNewBooking> createState() => _AddNewBookingState();
}

class _AddNewBookingState extends State<AddNewBooking> {
  final now = DateTime.now();
  final BranchController branchController = Get.find(tag: "branchController");
  final ProductController productController = Get.find(tag: "productController");
  final TextEditingController _userPhoneController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  CollectionReference bookings = FirebaseFirestore.instance.collection('bookings');
  BranchModel? selectedBranch;
  ProductModel? selectedProduct;
  int selectedRoom = 1;
  late BookingService currentBookingService;

  @override
  void initState() {
    super.initState();
    // Will be set in build when data is available
  }

  void updateBookingService(BranchModel branch, ProductModel product) {
    currentBookingService = BookingService(
      serviceName: product.title,
      serviceDuration: product.duration.toInt(),
      bookingStart: DateTime(now.year, now.month, now.day, 12, 0),
      bookingEnd: DateTime(now.year, now.month, now.day, 21, 0),
      userId: _userPhoneController.text.isNotEmpty ? _userPhoneController.text : "userID",
      roomId: selectedRoom.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(titleText: "Book Appointment"),
      body: BaseLayout(
        child: Obx(() {
          if (branchController.isLoading.value || productController.products.isEmpty || branchController.branches.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final branch = selectedBranch ?? branchController.branches[0];
          final product = selectedProduct ?? productController.products[0];
          updateBookingService(branch, product);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Branch selector
                Row(
                  children: [
                    _buildDropdownContainer(
                      child: DropdownButton<BranchModel>(
                        value: selectedBranch ?? branchController.branches[0],
                        isExpanded: true,
                        items: branchController.branches
                            .map((b) => DropdownMenuItem(value: b, child: Text(b.branchName)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedBranch = val;
                          });
                        },
                        hint: const Text('Select Branch'),
                      ),
                    ),
                  ],
                ),
                // Appointment calendar/list at the top
                Builder(
                  builder: (context) {
                    final branchId = (selectedBranch ?? branchController.branches[0]).branchId ?? '';
                    print('AddNewBooking: Using branchId: $branchId for branch: ${(selectedBranch ?? branchController.branches[0]).branchName}');
                    return SizedBox(
                      height: 400, // Adjust as needed
                      child: AppointmentPageSimple(
                        key: ValueKey(branchId), // Force rebuild when branch changes
                        branchId: branchId,
                      ),
                    );
                  }
                ),
                const Divider(),
                // Booking form below
              ],
            ),
          );
        }),
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
          .doc((selectedBranch ?? branchController.branches[0]).branchId)
          .collection('bookings')
          .add(newBooking.toJson());
      _userNameController.clear();
      _userPhoneController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking successful!')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add booking: $error')),
        );
      }
    }
  }
}
