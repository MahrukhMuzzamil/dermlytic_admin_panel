import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aesthetics_labs_admin/controllers/user_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aesthetics_labs_admin/firebase_options.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Center(
              child: CachedNetworkImage(
                imageUrl: "https://firebasestorage.googleapis.com/v0/b/aesthetics-lab-1.firebasestorage.app/o/logo-black.png?alt=media&token=4943f29c-0e3a-4be9-a4fe-c6693c55162d",
                placeholder: (context, url) => const SizedBox(
                  height: 60,
                  width: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 200,
                  height: 60,
                  alignment: Alignment.center,
                  child: const Text(
                    'Aesthetics Lab',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )),
        elevation: 0,
        backgroundColor: primaryColor.withOpacity(0.1),
        // toolbarHeight: 60,
        leading: const SizedBox(),
      ),
      backgroundColor: primaryColor.withOpacity(0.1),
      body: Center(
      child: SingleChildScrollView(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: isDesktop ? 600 : screenWidth * 0.9,
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        elevation: 5,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome Back!",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  UserController userController = Get.find(tag: 'userController');
                  userController.login(
                    emailController.text.trim().toLowerCase(),
                    passwordController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
),

      ),
    );
  }
}
