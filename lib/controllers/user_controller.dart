import 'package:aesthetics_labs_admin/services/email_login_service.dart';
import 'package:aesthetics_labs_admin/ui/booking_management/add_new_booking.dart';
import 'package:aesthetics_labs_admin/ui/branch_management/add_new_branch/add_new_branch.dart';
import 'package:aesthetics_labs_admin/ui/login/login.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  String userID = '';
  String email = '';
  bool previouslyLoggedIn = false;
  // UserModel user;
  final Authentication _authentication = Authentication();

  @override
  Future<void> onInit() async {
    super.onInit();
    String? userID = await _authentication.autoLogin();
    if (userID != null) {
      this.userID = userID;
      previouslyLoggedIn = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      email = prefs.getString('email')!;
      Get.to(const AddNewBranch());
    } else {
      previouslyLoggedIn = false;
      Get.to(LoginPage());
    }
  }

  void login(String email, String password) async {
    String? userID = await _authentication.login(email, password);
    if (userID != null) {
      this.userID = userID;
      email = email;
      previouslyLoggedIn = true;
      Get.to(const AddNewBooking());
    } else {
      // Get.to(const LoginPage());
    }
  }

  // logout
  void logout() async {
    await _authentication.logout();
    previouslyLoggedIn = false;
    Get.to(LoginPage());
  }
}
