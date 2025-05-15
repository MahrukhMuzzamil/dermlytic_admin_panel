import 'package:aesthetics_labs_admin/controllers/branch_controller.dart';
import 'package:aesthetics_labs_admin/controllers/product_controller.dart';
import 'package:aesthetics_labs_admin/controllers/user_controller.dart';
import 'package:aesthetics_labs_admin/firebase_options.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:aesthetics_labs_admin/ui/branch_management/view_all_branches/view_all_branches.dart';
import 'package:aesthetics_labs_admin/ui/login/login.dart';
import 'package:aesthetics_labs_admin/ui/booking_management/view_bookings.dart';
import 'package:aesthetics_labs_admin/ui/service_management/view_all_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const LoadingPage(),
      getPages: [
        GetPage(name: '/', page: () => const LoadingPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/ViewAllBranches', page: () => const ViewAllBranches()),
        GetPage(name: '/ViewBookings', page: () => const ViewBookings()),
        GetPage(name: '/ViewAllServices', page: () => ViewAllServices()),
      ],
    );
  }
}

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    initControllers();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

Future<void> initControllers() async {
  await Get.put(BranchController(), tag: 'branchController').onInit();
  await Get.put(ProductController(), tag: 'productController').onInit();
  await Get.put(UserController(), tag: 'userController').onInit();

  // After controllers are initialized, navigate to login
  Future.delayed(const Duration(milliseconds: 500), () {
    Get.offNamed('/login');
  });
}
