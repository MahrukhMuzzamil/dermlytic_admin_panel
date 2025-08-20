// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// User roles enum for better type safety
enum UserRole {
  admin,           // Super admin - can create roles and assign any permissions
  compOpsUser,     // Operations user - customizable permissions
  branchManager,   // Branch management - customizable permissions  
  staff,           // General staff - customizable permissions
  doctor,          // Doctor role - customizable permissions
  custom,          // Custom role defined by admin
}

// Permission categories
enum Permission {
  // User management permissions
  createUsers,
  viewUsers,
  updateUsers,
  deleteUsers,
  
  // Branch management permissions
  createBranches,
  viewBranches,
  updateBranches,
  deleteBranches,
  
  // Doctor management permissions
  createDoctors,
  viewDoctors,
  updateDoctors,
  deleteDoctors,
  
  // Appointment management permissions
  createAppointments,
  viewAppointments,
  updateAppointments,
  deleteAppointments,
  
  // Service management permissions
  createServices,
  viewServices,
  updateServices,
  deleteServices,
  
  // Booking management permissions
  createBookings,
  viewBookings,
  updateBookings,
  deleteBookings,
  
  // Reports and analytics
  viewReports,
  viewAnalytics,
}

class UserModel {
  String userID;
  String name;
  UserRole role;
  List<Permission> permissions;
  
  // Special field to handle "ALL" permission as string
  bool get hasAllPermissions => role == UserRole.admin;
  bool isActive;
  String? branchId; // Association with clinic/branch
  String? specialization; // Doctor's specialization
  String? phoneNumber; // Contact info
  String? email; // Email
  DateTime createdAt;
  DateTime? lastLoginAt;
  String? createdBy; // ID of admin who created this user
  
  UserModel({
    required this.userID,
    required this.name,
    required this.role,
    this.permissions = const [],
    this.isActive = true,
    this.branchId,
    this.specialization,
    this.phoneNumber,
    this.email,
    DateTime? createdAt,
    this.lastLoginAt,
    this.createdBy,
  }) : createdAt = createdAt ?? DateTime.now();
  
  // Helper method to get default permissions for a role
  static List<Permission> getDefaultPermissions(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Permission.values; // All permissions - can do everything
        
      case UserRole.compOpsUser:
        return [
          // Default CompOps permissions (admin can customize these)
          Permission.viewUsers,
          Permission.updateUsers,
          Permission.createBranches,
          Permission.viewBranches,
          Permission.updateBranches,
          Permission.deleteBranches,
          Permission.createDoctors,
          Permission.viewDoctors,
          Permission.updateDoctors,
          Permission.deleteDoctors,
          Permission.createAppointments,
          Permission.viewAppointments,
          Permission.updateAppointments,
          Permission.deleteAppointments,
          Permission.createServices,
          Permission.viewServices,
          Permission.updateServices,
          Permission.deleteServices,
          Permission.createBookings,
          Permission.viewBookings,
          Permission.updateBookings,
          Permission.deleteBookings,
          Permission.viewReports,
          Permission.viewAnalytics,
        ];
        
      case UserRole.branchManager:
        return [
          // Default Branch Manager permissions
          Permission.viewUsers,
          Permission.createDoctors,
          Permission.viewDoctors,
          Permission.updateDoctors,
          Permission.viewBranches,
          Permission.updateBranches,
          Permission.createAppointments,
          Permission.viewAppointments,
          Permission.updateAppointments,
          Permission.deleteAppointments,
          Permission.viewServices,
          Permission.createBookings,
          Permission.viewBookings,
          Permission.updateBookings,
          Permission.viewReports,
        ];
        
      case UserRole.staff:
        return [
          // Default Staff permissions
          Permission.viewDoctors,
          Permission.createAppointments,
          Permission.viewAppointments,
          Permission.updateAppointments,
          Permission.viewServices,
          Permission.createBookings,
          Permission.viewBookings,
          Permission.updateBookings,
        ];
        
      case UserRole.doctor:
        return [
          // Default Doctor permissions
          Permission.viewDoctors,
          Permission.viewAppointments,
          Permission.updateAppointments,
          Permission.viewBookings,
          Permission.updateBookings,
          Permission.viewServices,
        ];
        
      case UserRole.custom:
        return []; // Custom roles start with no permissions - admin assigns them
    }
  }

  // Helper method to check if user has a specific permission  
  bool hasPermission(Permission permission) {
    // Admin users always have all permissions
    if (role == UserRole.admin) {
      return true;
    }
    // Check if user has specific permission
    return permissions.contains(permission);
  }
  

  
  // Check if user has admin privileges
  bool get isAdmin {
    return role == UserRole.admin;
  }
  
  // Check if user can create other users
  bool get canCreateUsers {
    return isAdmin || hasPermission(Permission.createUsers);
  }

  // Helper method to get role display name
  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.compOpsUser:
        return 'CompOps User';
      case UserRole.branchManager:
        return 'Branch Manager';
      case UserRole.staff:
        return 'Staff';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.custom:
        return 'Custom Role';
    }
  }

  UserModel copyWith({
    String? userID,
    String? name,
    UserRole? role,
    List<Permission>? permissions,
    bool? isActive,
    String? branchId,
    String? specialization,
    String? phoneNumber,
    String? email,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? createdBy,
  }) {
    return UserModel(
      userID: userID ?? this.userID,
      name: name ?? this.name,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      branchId: branchId ?? this.branchId,
      specialization: specialization ?? this.specialization,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userID': userID,
      'name': name,
      'role': role.name,
      'permissions': permissions.map((p) => p.name).toList(),
      'isActive': isActive,
      'branchId': branchId,
      'specialization': specialization,
      'phoneNumber': phoneNumber,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Handle legacy role field (string) and new role field (enum)
    UserRole role;
    if (map['role'] is String) {
      // Legacy support for existing string roles
      switch (map['role'] as String) {
        case 'admin':
        case 'superAdmin': // Treat legacy superAdmin as admin
          role = UserRole.admin;
          break;
        case 'compOpsUser':
        case 'doctor': // Treat legacy doctor as compOpsUser
        case 'staff': // Treat legacy staff as compOpsUser
          role = UserRole.compOpsUser;
          break;
        default:
          role = UserRole.compOpsUser; // Default fallback
      }
    } else {
      role = UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.compOpsUser,
      );
    }

    // Parse permissions (handle both string and array formats)
    List<Permission> permissions = [];
    if (map['permissions'] != null) {
      if (map['permissions'] is String) {
        // Handle string format like "createUsers,viewUsers,updateUsers"
        final permissionsString = map['permissions'] as String;
        if (permissionsString == 'ALL' || permissionsString.contains('ALL')) {
          permissions = Permission.values; // Give all permissions
        } else {
          final permissionsList = permissionsString.split(',').map((s) => s.trim()).toList();
          permissions = permissionsList
              .map((p) => Permission.values.firstWhere(
                    (perm) => perm.name == p,
                    orElse: () => Permission.viewAppointments, // Default fallback
                  ))
              .toList();
        }
      } else {
        // Handle array format
        final permissionsList = List<String>.from(map['permissions']);
        permissions = permissionsList
            .map((p) => Permission.values.firstWhere(
                  (perm) => perm.name == p,
                  orElse: () => Permission.viewAppointments, // Default fallback
                ))
            .toList();
      }
    } else {
      // If no permissions are set, use default permissions for the role
      permissions = getDefaultPermissions(role);
    }

    return UserModel(
      userID: map['userID'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown User',
      role: role,
      permissions: permissions,
      isActive: map['isActive'] as bool? ?? true,
      branchId: map['branchId'] as String?,
      specialization: map['specialization'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
      createdAt: map['createdAt'] != null 
          ? _parseDateTime(map['createdAt'])
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null 
          ? _parseDateTime(map['lastLoginAt'])
          : null,
      createdBy: map['createdBy'] as String?,
    );
  }

  // Helper method to parse various date formats
  static DateTime _parseDateTime(dynamic dateValue) {
    try {
      if (dateValue is String) {
        // Handle ISO 8601 format with Z suffix
        String dateStr = dateValue;
        if (dateStr.endsWith('Z')) {
          dateStr = dateStr.substring(0, dateStr.length - 1) + '+00:00';
        }
        return DateTime.parse(dateStr);
      } else if (dateValue is int) {
        // Handle milliseconds since epoch
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      } else {
        // Fallback to current time
        return DateTime.now();
      }
    } catch (e) {
      print('Warning: Failed to parse date $dateValue, using current time');
      return DateTime.now();
    }
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(userID: $userID, name: $name, role: $role, permissions: $permissions, isActive: $isActive, branchId: $branchId, specialization: $specialization, phoneNumber: $phoneNumber, email: $email, createdAt: $createdAt, lastLoginAt: $lastLoginAt, createdBy: $createdBy)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return other.userID == userID &&
        other.name == name &&
        other.role == role &&
        other.permissions == permissions &&
        other.isActive == isActive &&
        other.branchId == branchId &&
        other.specialization == specialization &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.createdBy == createdBy;
  }

  @override
  int get hashCode {
    return userID.hashCode ^
        name.hashCode ^
        role.hashCode ^
        permissions.hashCode ^
        isActive.hashCode ^
        branchId.hashCode ^
        specialization.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode ^
        createdBy.hashCode;
  }
}
