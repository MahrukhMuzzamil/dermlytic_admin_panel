import 'package:aesthetics_labs_admin/models/branch_model.dart';
import 'package:aesthetics_labs_admin/services/branch_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class BranchController extends GetxController {
  final BranchService _branchService = BranchService();
  RxList<BranchModel> branches = <BranchModel>[].obs;
  RxBool isLoading = false.obs; // ✅ Added loading state

  @override
  Future<void> onInit() async {
    super.onInit();
    await getBranches();
  }

  // Fetch all branches
  Future<void> getBranches() async {
    try {
      isLoading.value = true; // ✅ Start loading
      var value = await _branchService.getBranches();
      branches.value = value;
    } catch (e) {
      debugPrint("Error fetching branches: $e");
    } finally {
      isLoading.value = false; // ✅ Stop loading
    }
  }

  // Add a new branch
  Future<bool> addBranch(BranchModel branch) async {
    try {
      isLoading.value = true; // ✅ Indicate processing
      await _branchService.addBranch(branch);
      branches.add(branch);
      return true;
    } catch (e) {
      debugPrint("Error adding branch: $e");
      return false;
    } finally {
      isLoading.value = false; // ✅ Stop loading
    }
  }

  // Update a branch
  Future<bool> updateBranch(BranchModel branch) async {
    try {
      isLoading.value = true; // ✅ Indicate processing
      await _branchService.updateBranch(branch);
      int index = branches.indexWhere((element) => element.branchId == branch.branchId);
      if (index != -1) {
        branches[index] = branch;
      }
      return true;
    } catch (e) {
      debugPrint("Error updating branch: $e");
      return false;
    } finally {
      isLoading.value = false; // ✅ Stop loading
    }
  }

  // Delete a branch
  Future<bool> deleteBranch(String branchId) async {
    try {
      isLoading.value = true; // ✅ Indicate processing
      await _branchService.deleteBranch(branchId);
      branches.removeWhere((element) => element.branchId == branchId);
      return true;
    } catch (e) {
      debugPrint("Error deleting branch: $e");
      return false;
    } finally {
      isLoading.value = false; // ✅ Stop loading
    }
  }

  // Get a branch by ID
  BranchModel? getBranchById(String branchId) {
    try {
      return branches.firstWhere((element) => element.branchId == branchId);
    } catch (e) {
      debugPrint("Error getting branch by ID: $e");
      return null;
    }
  }

  // Get a branch by name
  BranchModel? getBranchByName(String branchName) {
    try {
      return branches.firstWhere((element) => element.branchName == branchName);
    } catch (e) {
      debugPrint("Error getting branch by name: $e");
      return null;
    }
  }

  // Update branch timing
  Future<bool> updateBranchTiming(String branchId, DateTime openingTime, DateTime closingTime) async {
    try {
      BranchModel? branch = getBranchById(branchId);
      if (branch == null) throw Exception('Branch not found');
      branch = branch.copyWith(openingTime: openingTime, closingTime: closingTime);
      return updateBranch(branch);
    } catch (e) {
      debugPrint("Error updating branch timing: $e");
      return false;
    }
  }
}
