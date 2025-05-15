import 'package:aesthetics_labs_admin/ui/general_widgets/base_layout.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_app_bar.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/session_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/product_controller.dart';

class ViewAllServices extends StatelessWidget {
  ViewAllServices({super.key});
  final ProductController productController = Get.find(tag: "productController");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(titleText: "View all services"),
      body: BaseLayout(
        child: Obx(
          () => productController.products.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded( // Ensures GridView takes available space
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Three items per row
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            childAspectRatio: 3 / 2, // Adjusted aspect ratio
                          ),
                          itemCount: productController.products.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown, // Ensures proper fitting
                                child: SessionTile(session: productController.products[index]),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator()), // Loading indicator
        ),
      ),
    );
  }
}
