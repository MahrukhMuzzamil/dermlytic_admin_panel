import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../controllers/branch_controller.dart';
import '../../controllers/user_controller.dart';
import '../../services/user_service.dart';
import '../general_widgets/drawer.dart';
import '../general_widgets/custom_filled_button.dart';
import '../general_widgets/permission_wrapper.dart';
import '../../styles/styles.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final BranchController _branchController = Get.put(BranchController());
  final UserController _userController = Get.find(tag: 'userController');
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _loading = false;
  UserRole? _filterRole;
  String _filterBranch = '';
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _loading = true);
    await _branchController.getBranches();
    await _fetchUsers();
    setState(() => _loading = false);
  }

  Future<void> _fetchUsers() async {
    try {
      List<UserModel> users;
      if (_showActiveOnly) {
        users = await UserService.getActiveUsers();
        print('DEBUG: Fetched ${users.length} active users');
      } else {
        users = await UserService.getAllUsers();
        print('DEBUG: Fetched ${users.length} total users');
      }
      
      // Debug: Print each user
      for (var user in users) {
        print('DEBUG: User - ${user.name}, Role: ${user.role}, Active: ${user.isActive}');
      }
      
      setState(() {
        _users = users;
        _applyFilters();
      });
      
      print('DEBUG: After filtering, ${_filteredUsers.length} users shown');
    } catch (e) {
      print('DEBUG: Error fetching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }

  void _applyFilters() {
    _filteredUsers = _users.where((user) {
      // Role filter
      if (_filterRole != null && user.role != _filterRole) {
        return false;
      }
      
      // Branch filter
      if (_filterBranch.isNotEmpty && user.branchId != _filterBranch) {
        return false;
      }
      
      return true;
    }).toList();
  }

  void _showUserForm([UserModel? user]) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    final specializationController = TextEditingController(text: user?.specialization ?? '');
    final passwordController = TextEditingController();
    UserRole selectedRole = user?.role ?? UserRole.compOpsUser;
    String? selectedBranch = user?.branchId;
    bool isActive = user?.isActive ?? true;
    List<Permission> selectedPermissions = user?.permissions ?? UserModel.getDefaultPermissions(selectedRole);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            width: 600,
            constraints: const BoxConstraints(maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        user == null ? 'Create New User' : 'Edit User',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Info
                        const Text('Basic Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name *',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: user == null, // Can't change email after creation
                          decoration: InputDecoration(
                            labelText: 'Email Address *',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            helperText: user != null ? 'Email cannot be changed after creation' : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        if (user == null) ...[
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              helperText: 'Minimum 6 characters',
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Role & Access
                        const Text('Role & Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        
                        DropdownButtonFormField<UserRole>(
                          value: selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role *',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _getAvailableRoles().map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Row(
                                children: [
                                  _getRoleIcon(role),
                                  const SizedBox(width: 8),
                                  Text(_getRoleDisplayName(role)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedRole = value;
                                // Update default permissions when role changes
                                selectedPermissions = UserModel.getDefaultPermissions(value);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Custom Permissions (only for Admin)
                        if (_userController.isAdmin()) ...[
                          const Text('Permissions:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(8),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: Permission.values.map((permission) {
                                  return FilterChip(
                                    label: Text(
                                      permission.name.replaceAllMapped(
                                        RegExp(r'([A-Z])'),
                                        (match) => ' ${match.group(0)}',
                                      ).trim(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    selected: selectedPermissions.contains(permission),
                                    onSelected: (selected) {
                                      setDialogState(() {
                                        if (selected) {
                                          selectedPermissions.add(permission);
                                        } else {
                                          selectedPermissions.remove(permission);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setDialogState(() {
                                    selectedPermissions = List.from(Permission.values);
                                  });
                                },
                                child: const Text('Select All'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setDialogState(() {
                                    selectedPermissions.clear();
                                  });
                                },
                                child: const Text('Clear All'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setDialogState(() {
                                    selectedPermissions = UserModel.getDefaultPermissions(selectedRole);
                                  });
                                },
                                child: const Text('Reset to Default'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // No branch assignment needed for simplified roles
                        
                        if (user != null) ...[
                          Row(
                            children: [
                              Switch(
                                value: isActive,
                                onChanged: (value) {
                                  setDialogState(() {
                                    isActive = value;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(isActive ? 'Active' : 'Inactive'),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Role Permissions Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Role Permissions: ${_getRoleDisplayName(selectedRole)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getRoleDescription(selectedRole),
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            CustomFilledButton(
                              title: user == null ? 'Create User' : 'Update User',
                              width: 140,
                              onPress: () async {
                                if (nameController.text.trim().isEmpty ||
                                    emailController.text.trim().isEmpty ||
                                    (user == null && passwordController.text.length < 6)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please fill all required fields')),
                                  );
                                  return;
                                }

                                try {
                                  if (user == null) {
                                    // Create new user
                                    await UserService.createUser(
                                      email: emailController.text.trim(),
                                      password: passwordController.text,
                                      name: nameController.text.trim(),
                                      role: selectedRole,
                                      branchId: selectedBranch,
                                      specialization: specializationController.text.trim().isEmpty ? null : specializationController.text.trim(),
                                      phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                                      createdByUserId: _userController.userID,
                                      customPermissions: selectedPermissions,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('User created successfully! Verification email sent.')),
                                    );
                                  } else {
                                    // Update existing user
                                    final updatedUser = user.copyWith(
                                      name: nameController.text.trim(),
                                      role: selectedRole,
                                      branchId: selectedBranch,
                                      specialization: specializationController.text.trim().isEmpty ? null : specializationController.text.trim(),
                                      phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                                      isActive: isActive,
                                      permissions: selectedPermissions,
                                    );
                                    await UserService.updateUser(updatedUser);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('User updated successfully!')),
                                    );
                                  }
                                  
                                  Navigator.pop(context);
                                  await _fetchUsers();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<UserRole> _getAvailableRoles() {
    final currentUser = _userController.user;
    if (currentUser?.isAdmin == true) {
      return UserRole.values; // Admin can create all roles
    }
    
    // Non-admin users can only create roles they have permission for
    List<UserRole> allowedRoles = [];
    if (_userController.hasPermission(Permission.createUsers)) {
      allowedRoles.addAll([
        UserRole.compOpsUser,
        UserRole.branchManager, 
        UserRole.staff,
        UserRole.doctor,
        UserRole.custom,
      ]);
    }
    return allowedRoles;
  }

  String _getRoleDisplayName(UserRole role) {
    return role.toString().split('.').last.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim().replaceFirst(
      role.toString().split('.').last[0],
      role.toString().split('.').last[0].toUpperCase(),
    );
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Super admin - can create any role and assign any permissions';
      case UserRole.compOpsUser:
        return 'Operations user - customizable permissions set by admin';
      case UserRole.branchManager:
        return 'Branch management - permissions customizable by admin';
      case UserRole.staff:
        return 'General staff - permissions customizable by admin';
      case UserRole.doctor:
        return 'Doctor role - permissions customizable by admin';
      case UserRole.custom:
        return 'Custom role - completely customizable by admin';
    }
  }

  Icon _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Icon(Icons.admin_panel_settings, color: Colors.red);
      case UserRole.compOpsUser:
        return const Icon(Icons.business_center, color: Colors.blue);
      case UserRole.branchManager:
        return const Icon(Icons.store_mall_directory, color: Colors.green);
      case UserRole.staff:
        return const Icon(Icons.people, color: Colors.orange);
      case UserRole.doctor:
        return const Icon(Icons.medical_services, color: Colors.purple);
      case UserRole.custom:
        return const Icon(Icons.settings, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundSecondary,
      appBar: AppBar(
        title: const Text('User Management', style: headingFontStyle),
        backgroundColor: primaryColor,
        foregroundColor: neutralWhite,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          PermissionWrapper(
            requiredPermission: Permission.createUsers,
            child: Container(
              margin: EdgeInsets.only(right: spacingM),
              child: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(spacingS),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(neutralWhite.red, neutralWhite.green, neutralWhite.blue, 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_add, size: 20),
                ),
                onPressed: () => _showUserForm(),
                tooltip: 'Create User',
              ),
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filters Section
                Container(
                  margin: EdgeInsets.all(spacingM),
                  padding: EdgeInsets.all(spacingL),
                  decoration: BoxDecoration(
                    color: backgroundPrimary,
                    borderRadius: cardRadius,
                    boxShadow: const [cardShadow],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Filter Users', style: subHeadingFontStyle),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<UserRole?>(
                              value: _filterRole,
                              decoration: const InputDecoration(
                                labelText: 'Filter by Role',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('All Roles')),
                                ...UserRole.values.map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Row(
                                    children: [
                                      _getRoleIcon(role),
                                      const SizedBox(width: 8),
                                      Text(_getRoleDisplayName(role)),
                                    ],
                                  ),
                                )).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _filterRole = value;
                                  _applyFilters();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() => DropdownButtonFormField<String>(
                              value: _filterBranch.isEmpty ? null : _filterBranch,
                              decoration: const InputDecoration(
                                labelText: 'Filter by Branch',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: [
                                const DropdownMenuItem(value: '', child: Text('All Branches')),
                                ..._branchController.branches.map((branch) => DropdownMenuItem(
                                  value: branch.branchId,
                                  child: Text(branch.branchName),
                                )).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _filterBranch = value ?? '';
                                  _applyFilters();
                                });
                              },
                            )),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              const Text('Active Only'),
                              Switch(
                                value: _showActiveOnly,
                                onChanged: (value) {
                                  setState(() {
                                    _showActiveOnly = value;
                                  });
                                  _fetchUsers();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Users List
                Expanded(
                  child: _filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No users found',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              PermissionWrapper(
                                requiredPermission: Permission.createUsers,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showUserForm(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Create First User'),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(spacingM),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final branch = _branchController.branches.firstWhereOrNull(
      (b) => b.branchId == user.branchId,
    );

    return Container(
      margin: EdgeInsets.only(bottom: spacingM),
      decoration: BoxDecoration(
        color: backgroundPrimary,
        borderRadius: cardRadius,
        boxShadow: const [cardShadow],
        border: user.isActive ? null : Border.all(color: Colors.red[300]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacingL),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: user.isActive ? Colors.blue[100] : Colors.grey[300],
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: user.isActive ? Colors.blue[800] : Colors.grey[600],
                ),
              ),
            ),
            SizedBox(width: spacingM),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(user.name, style: subHeadingFontStyle),
                      SizedBox(width: spacingS),
                      if (!user.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'INACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: spacingXS),
                  Row(
                    children: [
                      _getRoleIcon(user.role),
                      SizedBox(width: spacingS),
                      Text(user.roleDisplayName, style: bodyFontStyle),
                    ],
                  ),
                  if (user.email != null) ...[
                    SizedBox(height: spacingXS),
                    Row(
                      children: [
                        Icon(Icons.email, size: 16, color: Colors.grey[600]),
                        SizedBox(width: spacingS),
                        Text(user.email!, style: captionFontStyle),
                      ],
                    ),
                  ],
                  if (branch != null) ...[
                    SizedBox(height: spacingXS),
                    Row(
                      children: [
                        Icon(Icons.business, size: 16, color: Colors.grey[600]),
                        SizedBox(width: spacingS),
                        Text(branch.branchName, style: captionFontStyle),
                      ],
                    ),
                  ],
                  if (user.specialization != null) ...[
                    SizedBox(height: spacingXS),
                    Row(
                      children: [
                        Icon(Icons.medical_services, size: 16, color: Colors.grey[600]),
                        SizedBox(width: spacingS),
                        Text(user.specialization!, style: captionFontStyle),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Action Buttons
            PermissionWrapper(
              requiredPermission: Permission.updateUsers,
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showUserForm(user),
                    tooltip: 'Edit User',
                  ),
                  if (user.userID != _userController.userID) // Can't deactivate self
                    IconButton(
                      icon: Icon(
                        user.isActive ? Icons.block : Icons.check_circle,
                        color: user.isActive ? Colors.red : Colors.green,
                      ),
                      onPressed: () async {
                        try {
                          if (user.isActive) {
                            await UserService.deactivateUser(user.userID);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User deactivated')),
                            );
                          } else {
                            await UserService.activateUser(user.userID);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User activated')),
                            );
                          }
                          _fetchUsers();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                      tooltip: user.isActive ? 'Deactivate User' : 'Activate User',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
