import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aesthetics_labs_admin/models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new user with Firebase Auth and Firestore profile
  static Future<String?> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? branchId,
    String? specialization,
    String? phoneNumber,
    String? createdByUserId,
    List<Permission>? customPermissions,
  }) async {
    try {
      // Create Firebase Auth user
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create Firebase user');
      }

      // Update display name
      await firebaseUser.updateDisplayName(name);

      // Send email verification
      await firebaseUser.sendEmailVerification();

      // Create UserModel with appropriate permissions
      final userModel = UserModel(
        userID: firebaseUser.uid,
        name: name,
        role: role,
        permissions: customPermissions ?? UserModel.getDefaultPermissions(role),
        isActive: true,
        branchId: branchId,
        specialization: specialization,
        phoneNumber: phoneNumber,
        email: email,
        createdBy: createdByUserId,
      );

      // Save user profile to Firestore
      await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toMap());

      return firebaseUser.uid;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  // Get user by ID
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Update user profile
  static Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.userID).update(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Update last login time
  static Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Deactivate user (soft delete)
  static Future<void> deactivateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
      });
    } catch (e) {
      print('Error deactivating user: $e');
      rethrow;
    }
  }

  // Activate user
  static Future<void> activateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': true,
      });
    } catch (e) {
      print('Error activating user: $e');
      rethrow;
    }
  }

  // Get all users (for admin management)
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['userID'] = doc.id; // Ensure userID matches document ID
            return UserModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  // Get users by role
  static Future<List<UserModel>> getUsersByRole(UserRole role) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role.name)
          .get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching users by role: $e');
      return [];
    }
  }

  // Get users by branch
  static Future<List<UserModel>> getUsersByBranch(String branchId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('branchId', isEqualTo: branchId)
          .get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching users by branch: $e');
      return [];
    }
  }

  // Get active users only
  static Future<List<UserModel>> getActiveUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('isActive', isEqualTo: true)
          .get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['userID'] = doc.id; // Ensure userID matches document ID
            return UserModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      print('Error fetching active users: $e');
      return [];
    }
  }

  // Update user permissions
  static Future<void> updateUserPermissions(String userId, List<Permission> permissions) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'permissions': permissions.map((p) => p.name).toList(),
      });
    } catch (e) {
      print('Error updating user permissions: $e');
      rethrow;
    }
  }

  // Delete user completely (use with caution)
  static Future<void> deleteUser(String userId) async {
    try {
      // Delete from Firestore
      await _firestore.collection('users').doc(userId).delete();
      
      // Note: Deleting from Firebase Auth requires admin SDK on backend
      // For now, we'll just deactivate in Firestore
      print('User deleted from Firestore. Firebase Auth deletion requires backend implementation.');
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Check if user has specific permission
  static Future<bool> userHasPermission(String userId, Permission permission) async {
    try {
      final user = await getUserById(userId);
      return user?.hasPermission(permission) ?? false;
    } catch (e) {
      print('Error checking user permission: $e');
      return false;
    }
  }

  // Get users created by specific admin
  static Future<List<UserModel>> getUsersCreatedBy(String adminId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('createdBy', isEqualTo: adminId)
          .get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching users created by admin: $e');
      return [];
    }
  }

  // Validate user credentials and return user model
  static Future<UserModel?> validateAndGetUser(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // Get user profile from Firestore
      final userModel = await getUserById(firebaseUser.uid);
      
      // Check if user is active
      if (userModel != null && !userModel.isActive) {
        await _auth.signOut();
        throw Exception('User account is deactivated');
      }

      // Update last login
      if (userModel != null) {
        await updateLastLogin(userModel.userID);
      }

      return userModel;
    } catch (e) {
      print('Error validating user: $e');
      rethrow;
    }
  }

  // Reset user password
  static Future<void> resetUserPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }
}
