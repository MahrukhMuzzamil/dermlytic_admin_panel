import 'package:aesthetics_labs_admin/services/email_login_service.dart';

import 'package:aesthetics_labs_admin/ui/login/login.dart';
import 'package:aesthetics_labs_admin/models/user_model.dart';
import 'package:aesthetics_labs_admin/ui/dashboard/scheduler_page.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  String userID = '';
  String email = '';
  bool previouslyLoggedIn = false;
  UserModel? user;
  final Authentication _authentication = Authentication();

  @override
  Future<void> onInit() async {
    super.onInit();
    UserModel? userModel = await _authentication.autoLogin();
    if (userModel != null) {
      userID = userModel.userID;
      email = userModel.email ?? '';
      user = userModel;
      previouslyLoggedIn = true;
      // Don't navigate here - let AuthWrapper handle it
    } else {
      previouslyLoggedIn = false;
      // Don't navigate here - let AuthWrapper handle it
    }
    update(); // Notify GetBuilder to rebuild
  }

  void login(String email, String password) async {
    UserModel? userModel = await _authentication.login(email, password);
    if (userModel != null) {
      userID = userModel.userID;
      this.email = userModel.email ?? '';
      user = userModel;
      previouslyLoggedIn = true;
      update(); // Notify GetBuilder to rebuild
      _navigateBasedOnRole(userModel);
    } else {
      // Login failed, stay on login page
    }
  }

  void _navigateBasedOnRole(UserModel userModel) {
    // Both Admin and CompOps users go to the main dashboard
    Get.offAll(() => const SchedulerPage());
  }

  // Helper method to check if current user has permission
  bool hasPermission(Permission permission) {
    return user?.hasPermission(permission) ?? false;
  }

  // Helper method to get current user role
  UserRole? getCurrentUserRole() {
    return user?.role;
  }

  // Helper method to check if user is admin
  bool isAdmin() {
    return user?.isAdmin ?? false;
  }
  
  bool canCreateUsers() {
    return user?.canCreateUsers ?? false;
  }
  
  bool canCreateRole(UserRole targetRole) {
    // Only admin can create other admins or any role
    if (targetRole == UserRole.admin) {
      return isAdmin();
    }
    // Admin can create any role, others need createUsers permission
    return isAdmin() || hasPermission(Permission.createUsers);
  }

  // logout
  void logout() async {
    await _authentication.logout();
    userID = '';
    email = '';
    user = null;
    previouslyLoggedIn = false;
    Get.offAll(() => LoginPage());
  }
}
