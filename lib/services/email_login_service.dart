import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aesthetics_labs_admin/services/user_service.dart';
import 'package:aesthetics_labs_admin/models/user_model.dart';

class Authentication {
  // final UserController userController = Get.find(tag: 'userController');
  String userID = '';
  // Future<bool> init() async {
  //   if (userID.isNotEmpty) {
  //     userController.userID = userID;
  //     var document = await FirebaseFirestore.instance.collection('users').doc(userID).get();
  //     if (document.exists) {
  //       userController.user = UserModel.fromMap(document.data()!);
  //       userController.previouslyLoggedIn = true; //updating user already exists flag to true
  //     }
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  Future<UserModel?> autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool userStatus = prefs.containsKey('uid');
    if (userStatus) {
      String? uid = prefs.getString('uid');
      if (uid != null) {
        userID = uid;
        
        // Get user profile from Firestore
        final userModel = await UserService.getUserById(uid);
        
        if (userModel != null && userModel.isActive) {
          // Check if Firebase Auth is still valid
          final auth = FirebaseAuth.instance;
          if (auth.currentUser != null && auth.currentUser!.uid == uid) {
            return userModel;
          }
        }
        
        // If user is not found or inactive, clear preferences
        await prefs.clear();
      }
    } else {
      debugPrint("not connected");
    }
    return null;
  }

  Future<UserModel?> login(String identifier, String password) async {
    String errorMessage;
    try {
      // Use UserService to validate and get user
      final userModel = await UserService.validateAndGetUser(identifier, password);
      
      if (userModel == null) {
        Get.snackbar("Login Failed", "User not found or invalid credentials.", snackPosition: SnackPosition.BOTTOM);
        return null;
      }

      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      
      if (user != null && !user.emailVerified && userModel.email != 'mahrukh.tibbi@gmail.com') {
        Get.snackbar(
          "Email not Verified ",
          "Please verify your email.",
          mainButton: TextButton(
            onPressed: () {
              user.sendEmailVerification();
            },
            child: const Text(
              "Resend Verification email",
              style: TextStyle(color: Colors.white),
            ),
          ),
          colorText: Colors.white,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          maxWidth: 500,
        );
        await auth.signOut();
        return null;
      }

      // Check if user is active
      if (!userModel.isActive) {
        Get.snackbar("Account Deactivated", "Your account has been deactivated. Please contact administrator.", snackPosition: SnackPosition.BOTTOM);
        await auth.signOut();
        return null;
      }

      userID = userModel.userID;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('uid', userModel.userID);
      prefs.setString('email', userModel.email ?? "");
      prefs.setString('name', userModel.name);
      prefs.setString('role', userModel.role.name);
      
      return userModel;
      
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "user-not-found":
          errorMessage = "Incorrect Email or Password";
          break;
        case "wrong-password":
          errorMessage = "Incorrect Password";
          break;
        case "invalid-email":
          errorMessage = "Email is not valid.";
          break;
        case "user-disabled":
          errorMessage = "This account has been disabled";
          break;
        default:
          errorMessage = "Something Went Wrong: ${error.message}";
      }
      Get.snackbar(errorMessage, "Please Try Again.", snackPosition: SnackPosition.BOTTOM);
      print(error);
      return null;
    } catch (e) {
      if (e.toString().contains('deactivated')) {
        Get.snackbar("Account Deactivated", e.toString().replaceAll('Exception: ', ''), snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("Login Failed", "An error occurred during login.", snackPosition: SnackPosition.BOTTOM);
      }
      print('Login error: $e');
      return null;
    }
  }

  Future<bool> signUp(String name, String email, String password, String confirmPassword) async {
    final auth = FirebaseAuth.instance;
    String errorMessage;
    bool isSuccess = false;
    if (confirmPassword != password) {
      Get.snackbar(
        "Incorrect Confirm password",
        "Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return isSuccess;
    }

    try {
      final UserCredential signUPResponse = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      var user = signUPResponse.user;
      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('uid', user.uid);
        // userController.userID = user.uid;
        await user.sendEmailVerification();
        isSuccess = true;
        Get.snackbar(
          "Email Verification required",
          "Please verify your email",
          snackPosition: SnackPosition.BOTTOM,
        );
        // Get.offAll(() => LoginPage());
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case "user-not-found":
          errorMessage = "Incorrect Email or Password";
          break;
        case "wrong-password":
          errorMessage = "Incorrect Password";
          break;
        case "email-already-in-use":
          errorMessage = "Email already in use";
          break;
        case "invalid-email":
          errorMessage = "Email is not valid.";
          break;
        case "weak-password":
          errorMessage = "Password should be at least 6 characters ";
          break;

        default:
          errorMessage = error.code;
      }
      Get.back();
      Get.snackbar(errorMessage, "Please Try Again.", snackPosition: SnackPosition.BOTTOM);
    }
    return isSuccess;
  }
  // logout
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
  }
}
