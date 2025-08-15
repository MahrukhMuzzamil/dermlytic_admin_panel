import 'package:aesthetics_labs_admin/controllers/user_controller.dart';
import 'package:aesthetics_labs_admin/ui/booking_management/add_new_booking.dart';
import 'package:aesthetics_labs_admin/ui/dashboard/scheduler_page.dart';
import 'package:aesthetics_labs_admin/ui/booking_management/view_bookings.dart';
import 'package:aesthetics_labs_admin/ui/branch_management/view_all_branches/view_all_branches.dart';
import 'package:aesthetics_labs_admin/ui/branch_management/add_new_branch/add_new_branch.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_filled_button.dart';
import 'package:aesthetics_labs_admin/ui/service_management/add_new_service.dart';
import 'package:aesthetics_labs_admin/ui/service_management/view_all_services.dart';
import 'package:aesthetics_labs_admin/ui/doctor_management/doctor_management_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: "https://firebasestorage.googleapis.com/v0/b/aesthetics-lab-1.firebasestorage.app/o/logo-black.png?alt=media&token=4943f29c-0e3a-4be9-a4fe-c6693c55162d",
                  width: 200,
                  placeholder: (context, url) => const SizedBox(
                    height: 50,
                    width: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 200,
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      'Aesthetics Lab',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Column(
                children: [
                  ListTile(
                    title: const Text('Dashboard'),
                    onTap: () {
                      Get.off(const SchedulerPage(), preventDuplicates: false);
                    },
                  ),
                  ListTile(
                    title: const Text('Add New Branch'),
                    onTap: () {
                      Get.to(AddNewBranch());
                    },
                  ),
                  ListTile(
                    title: const Text('View All Branches'),
                    onTap: () {
                      Get.to(const ViewAllBranches());
                    },
                  ),
                  ListTile(
                    title: const Text('Doctor Management'),
                    onTap: () {
                      Get.to(const DoctorManagementPage());
                    },
                  ),
                  ListTile(
                    title: const Text('Add new Service'),
                    onTap: () {
                      Get.to(
                        const AddNewService(),
                        preventDuplicates: false,
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('View all services'),
                    onTap: () {
                      Get.off(ViewAllServices());
                    },
                  ),
                  ListTile(
                    title: const Text('Add new Booking'),
                    onTap: () {
                      Get.off(const AddNewBooking(), preventDuplicates: false);
                    },
                  ),
                  ListTile(
                    title: const Text('View All Bookings'),
                    onTap: () {
                      Get.off(const ViewBookings(), preventDuplicates: false);
                    },
                  ),
                  
                  ListTile(
                    title: const Text('View new Bookings'),
                    onTap: () {
                      Get.to(
                        const ViewBookings(isLatest: true),
                        preventDuplicates: false,
                      );
                    },
                  ),
                  
                  /*ListTile(
                    title: const Text('Reports'),
                    onTap: () async {
                      final bookings = await processCsvData();
                      Get.to(
                        ReportsData(bookings: bookings),
                        preventDuplicates: false,
                      );
                    },
                  ),*/
                ],
              ),

              const SizedBox(height: 20),

         
              // Logout Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomFilledButton(
                  title: "Logout",
                  width: 200,
                  onPress: () {
                    UserController userController = Get.find(tag: 'userController');
                    userController.logout();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
