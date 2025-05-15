import 'package:aesthetics_labs_admin/models/branch_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class BranchService {
  final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;

  Future<List<BranchModel>> getBranches() async {
    List<BranchModel> branches = [];
    try {
      await _firestoreInstance.collection('branches').get().then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          branches.add(BranchModel.fromMap(doc.data() as Map<String, dynamic>, documentId: doc.id));
        }
      });
      return branches;
    } catch (e) {
      debugPrint(e.toString());
      return branches;
    }
  }

  // add a new branch
  Future<bool> addBranch(BranchModel branch) async {
    try {
      await _firestoreInstance.collection('branches').add(branch.toMap());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // update a branch
  Future<bool> updateBranch(BranchModel branch) async {
    try {
      await _firestoreInstance.collection('branches').doc(branch.branchId).update(branch.toMap());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // delete a branch
  Future<bool> deleteBranch(String branchId) async {
    try {
      await _firestoreInstance.collection('branches').doc(branchId).delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // get a branch
  Future<BranchModel?> getBranch(String branchId) async {
    BranchModel? branch;
    try {
      await _firestoreInstance.collection('branches').doc(branchId).get().then((DocumentSnapshot documentSnapshot) {
        branch = BranchModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      });
      return branch;
    } catch (e) {
      debugPrint(e.toString());
      return branch;
    }
  }

  // get a branch by name
  Future<BranchModel?> getBranchByName(String branchName) async {
    BranchModel? branch;
    try {
      await _firestoreInstance.collection('branches').where('branchName', isEqualTo: branchName).get().then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          branch = BranchModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      });
      return branch;
    } catch (e) {
      debugPrint(e.toString());
      return branch;
    }
  }

  // update branch timing (opening and closing time)
  Future<bool> updateBranchTiming(String branchId, DateTime openingTime, DateTime closingTime) async {
    try {
      await _firestoreInstance.collection('branches').doc(branchId).update({
        'openingTime': openingTime.millisecondsSinceEpoch,
        'closingTime': closingTime.millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
