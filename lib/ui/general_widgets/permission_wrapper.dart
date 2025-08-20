import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aesthetics_labs_admin/models/user_model.dart';
import 'package:aesthetics_labs_admin/controllers/user_controller.dart';

/// A widget that wraps child widgets and shows/hides them based on user permissions
class PermissionWrapper extends StatelessWidget {
  final Widget child;
  final Permission? requiredPermission;
  final List<Permission>? requiredPermissions; // Must have ALL permissions
  final List<Permission>? anyOfPermissions; // Must have ANY of these permissions
  final List<UserRole>? allowedRoles;
  final Widget? fallback; // Widget to show when permission is denied
  final bool showUnauthorizedMessage;

  const PermissionWrapper({
    super.key,
    required this.child,
    this.requiredPermission,
    this.requiredPermissions,
    this.anyOfPermissions,
    this.allowedRoles,
    this.fallback,
    this.showUnauthorizedMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find(tag: 'userController');
    
    // If no user is logged in, don't show the child
    if (userController.user == null) {
      return fallback ?? const SizedBox.shrink();
    }

    final user = userController.user!;

    // Check role-based access first
    if (allowedRoles != null && allowedRoles!.isNotEmpty) {
      if (!allowedRoles!.contains(user.role)) {
        return _buildFallback();
      }
    }

    // Check single permission
    if (requiredPermission != null) {
      if (!user.hasPermission(requiredPermission!)) {
        return _buildFallback();
      }
    }

    // Check all required permissions (AND logic)
    if (requiredPermissions != null && requiredPermissions!.isNotEmpty) {
      for (final permission in requiredPermissions!) {
        if (!user.hasPermission(permission)) {
          return _buildFallback();
        }
      }
    }

    // Check any of permissions (OR logic)
    if (anyOfPermissions != null && anyOfPermissions!.isNotEmpty) {
      bool hasAnyPermission = false;
      for (final permission in anyOfPermissions!) {
        if (user.hasPermission(permission)) {
          hasAnyPermission = true;
          break;
        }
      }
      if (!hasAnyPermission) {
        return _buildFallback();
      }
    }

    // If all checks pass, show the child
    return child;
  }

  Widget _buildFallback() {
    if (fallback != null) {
      return fallback!;
    }
    
    if (showUnauthorizedMessage) {
      return const UnauthorizedWidget();
    }
    
    return const SizedBox.shrink();
  }
}

/// A pre-built unauthorized access message widget
class UnauthorizedWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;

  const UnauthorizedWidget({
    super.key,
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.lock,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'You don\'t have permission to access this feature',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Contact your administrator if you need access',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension methods for easier permission checking
extension PermissionHelpers on Widget {
  /// Wrap this widget with permission-based visibility
  Widget requirePermission(Permission permission, {Widget? fallback}) {
    return PermissionWrapper(
      requiredPermission: permission,
      fallback: fallback,
      child: this,
    );
  }

  /// Wrap this widget with role-based visibility
  Widget requireRole(UserRole role, {Widget? fallback}) {
    return PermissionWrapper(
      allowedRoles: [role],
      fallback: fallback,
      child: this,
    );
  }

  /// Wrap this widget with multiple role support
  Widget requireAnyRole(List<UserRole> roles, {Widget? fallback}) {
    return PermissionWrapper(
      allowedRoles: roles,
      fallback: fallback,
      child: this,
    );
  }

  /// Wrap this widget requiring admin access
  Widget requireAdmin({Widget? fallback}) {
    return PermissionWrapper(
      allowedRoles: [UserRole.admin],
      fallback: fallback,
      child: this,
    );
  }
}

/// Utility class for quick permission checks in code
class PermissionChecker {
  static UserController get _userController => Get.find(tag: 'userController');

  static bool hasPermission(Permission permission) {
    return _userController.hasPermission(permission);
  }

  static bool hasRole(UserRole role) {
    return _userController.user?.role == role;
  }

  static bool hasAnyRole(List<UserRole> roles) {
    final userRole = _userController.user?.role;
    return userRole != null && roles.contains(userRole);
  }

  static bool isAdmin() {
    return _userController.isAdmin();
  }

  static bool canCreateUsers() {
    return hasPermission(Permission.createUsers);
  }

  static bool canManageBranches() {
    return hasPermission(Permission.createBranches) || 
           hasPermission(Permission.updateBranches) || 
           hasPermission(Permission.deleteBranches);
  }

  static bool canManageDoctors() {
    return hasPermission(Permission.createDoctors) || 
           hasPermission(Permission.updateDoctors) || 
           hasPermission(Permission.deleteDoctors);
  }

  static bool canManageAppointments() {
    return hasPermission(Permission.createAppointments) || 
           hasPermission(Permission.updateAppointments) || 
           hasPermission(Permission.deleteAppointments);
  }

  static bool canViewReports() {
    return hasPermission(Permission.viewReports);
  }
}
