import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<String?> autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool userStatus = prefs.containsKey('uid');
    if (userStatus) {
      String? uid = prefs.getString('uid');
      userID = uid!;

      return uid;
      // await init();
    } else {
      // userController.previouslyLoggedIn = false; //if this is false then in main.dart=>checkLoginAndRediect we will check for this and redirect user to signup page
      debugPrint("not connected");
    }
    return null;
  }

  Future<String?> login(String identifier, String password) async {
    String errorMessage;
    final auth = FirebaseAuth.instance;
    try {
      final UserCredential userCredential = await auth.signInWithEmailAndPassword(email: identifier, password: password);
      final user = userCredential.user;
      if (user != null) {
        if (!user.emailVerified) {
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
          return null;
        } else {
          userID = user.uid;
          // userController.userID = userID;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('uid', userCredential.user!.uid);
          prefs.setString('email', user.email ?? "");
          prefs.setString('name', user.displayName ?? "");
          print("dispay name:${user.displayName} ");
          // await init();
          return user.uid;
        }
      }
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
        default:
          errorMessage = "Something Went Wrong,";
      }
      // Get.back();
      Get.snackbar(errorMessage, "Please Try Again.", snackPosition: SnackPosition.BOTTOM);
      print(error);
      return null;
    }
    return null;
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
