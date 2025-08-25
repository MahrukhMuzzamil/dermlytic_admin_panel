import 'package:aesthetics_labs_admin/controllers/user_controller.dart';
import 'package:aesthetics_labs_admin/ui/booking_management/add_new_booking.dart';
import 'package:aesthetics_labs_admin/ui/dashboard/scheduler_page.dart';
import 'package:aesthetics_labs_admin/ui/branch_management/view_all_branches/view_all_branches.dart';
import 'package:aesthetics_labs_admin/ui/branch_management/add_new_branch/add_new_branch.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_filled_button.dart';
import 'package:aesthetics_labs_admin/ui/service_management/add_new_service.dart';
import 'package:aesthetics_labs_admin/ui/service_management/view_all_services.dart';
import 'package:aesthetics_labs_admin/ui/doctor_management/doctor_management_page.dart';
import 'package:aesthetics_labs_admin/ui/user_management/user_management_page.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/permission_wrapper.dart';
import 'package:aesthetics_labs_admin/models/user_model.dart';
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
                  // Dashboard - Available to all users
                  ListTile(
                    title: const Text('Dashboard'),
                    leading: const Icon(Icons.dashboard),
                    onTap: () {
                      Get.off(const SchedulerPage(), preventDuplicates: false);
                    },
                  ),
                  
                                        // User Management - Only for Admin
                  PermissionWrapper(
                    anyOfPermissions: [Permission.createUsers, Permission.viewUsers],
                    child: ListTile(
                      title: const Text('User Management'),
                      leading: const Icon(Icons.people),
                      onTap: () {
                        Get.to(const UserManagementPage());
                      },
                    ),
                  ),
                  
                  // Branch Management
                  PermissionWrapper(
                    requiredPermission: Permission.createBranches,
                    child: ListTile(
                      title: const Text('Add New Branch'),
                      leading: const Icon(Icons.add_business),
                      onTap: () {
                        Get.to(AddNewBranch());
                      },
                    ),
                  ),
                  PermissionWrapper(
                    requiredPermission: Permission.viewBranches,
                    child: ListTile(
                      title: const Text('View All Branches'),
                      leading: const Icon(Icons.business),
                      onTap: () {
                        Get.to(const ViewAllBranches());
                      },
                    ),
                  ),
                  
                  // Doctor Management
                  PermissionWrapper(
                    anyOfPermissions: [
                      Permission.createDoctors,
                      Permission.viewDoctors,
                      Permission.updateDoctors,
                    ],
                    child: ListTile(
                      title: const Text('Doctor Management'),
                      leading: const Icon(Icons.medical_services),
                      onTap: () {
                        Get.to(const DoctorManagementPage());
                      },
                    ),
                  ),
                  
                  // Service Management
                  PermissionWrapper(
                    requiredPermission: Permission.createServices,
                    child: ListTile(
                      title: const Text('Add new Service'),
                      leading: const Icon(Icons.add_circle),
                      onTap: () {
                        Get.to(
                          const AddNewService(),
                          preventDuplicates: false,
                        );
                      },
                    ),
                  ),
                  PermissionWrapper(
                    requiredPermission: Permission.viewServices,
                    child: ListTile(
                      title: const Text('View all services'),
                      leading: const Icon(Icons.room_service),
                      onTap: () {
                        Get.off(ViewAllServices());
                      },
                    ),
                  ),
                  
                  // Booking Management
                  PermissionWrapper(
                    requiredPermission: Permission.createBookings,
                    child: ListTile(
                      title: const Text('Add new Booking'),
                      leading: const Icon(Icons.book_online),
                      onTap: () {
                        Get.off(const AddNewBooking(), preventDuplicates: false);
                      },
                    ),
                  ),
                  // Removed "View Appointments/Bookings" menu entries per request
                  
                  // Reports - Only for users with report permissions
                  PermissionWrapper(
                    requiredPermission: Permission.viewReports,
                    child: ListTile(
                      title: const Text('Reports'),
                      leading: const Icon(Icons.analytics),
                      onTap: () {
                        Get.snackbar('Coming Soon', 'Reports feature will be available soon');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // User Info Section
              GetBuilder<UserController>(
                tag: 'userController',
                builder: (userController) {
                  final user = userController.user;
                  
                  if (user != null) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    user.roleDisplayName,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (user.email != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            user.email!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                  return const SizedBox.shrink();
                },
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
