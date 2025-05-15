import 'package:aesthetics_labs_admin/controllers/branch_controller.dart';
import 'package:aesthetics_labs_admin/ui/branch_management/update_branch_page/update_branch_page.dart';
import 'package:aesthetics_labs_admin/ui/branch_management/view_all_branches/branch_tile.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/base_layout.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewAllBranches extends StatefulWidget {
  const ViewAllBranches({super.key});

  @override
  State<ViewAllBranches> createState() => _ViewAllBranchesState();
}

class _ViewAllBranchesState extends State<ViewAllBranches> {
  final BranchController _branchController = Get.find(tag: 'branchController');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(titleText: "View All Branches"),
      body: BaseLayout(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (_branchController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_branchController.branches.isEmpty) {
                  return const Center(child: Text("No branches found"));
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = (constraints.maxWidth ~/ 380).clamp(1, 4);

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 4 / 5,
                      ),
                      itemCount: _branchController.branches.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Get.to(UpdateBranchPage(branch: _branchController.branches[index]));
                          },
                          child: BranchTile(branch: _branchController.branches[index]),
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
