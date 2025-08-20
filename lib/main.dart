import 'package:aesthetics_labs_admin/controllers/branch_controller.dart';
import 'package:aesthetics_labs_admin/controllers/product_controller.dart';
import 'package:aesthetics_labs_admin/controllers/user_controller.dart';
import 'package:aesthetics_labs_admin/firebase_options.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:aesthetics_labs_admin/ui/branch_management/view_all_branches/view_all_branches.dart';
import 'package:aesthetics_labs_admin/ui/login/login.dart';
import 'package:aesthetics_labs_admin/ui/booking_management/view_bookings.dart';
import 'package:aesthetics_labs_admin/ui/service_management/view_all_services.dart';
import 'package:aesthetics_labs_admin/ui/appointments/appointment_page_simple.dart';
import 'package:aesthetics_labs_admin/ui/dashboard/scheduler_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Register controllers globally before app starts
  Get.put(BranchController(), tag: 'branchController');
  Get.put(ProductController(), tag: 'productController');
  Get.put(UserController(), tag: 'userController');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Aesthetics Lab Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/ViewAllBranches', page: () => const ViewAllBranches()),
        GetPage(name: '/ViewBookings', page: () => const ViewBookings()),
        GetPage(name: '/ViewAllServices', page: () => ViewAllServices()),
      ],
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Give the UserController time to initialize
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GetBuilder<UserController>(
      tag: 'userController',
      builder: (userController) {
        // If user is logged in, show the main app
        if (userController.user != null && userController.userID.isNotEmpty) {
          return const SchedulerPage();
        }
        
        // Otherwise show login page
        return LoginPage();
      },
    );
  }
}
