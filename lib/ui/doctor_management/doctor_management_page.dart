import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../models/branch_model.dart';
import '../../controllers/branch_controller.dart';
import '../general_widgets/drawer.dart';

import '../general_widgets/custom_filled_button.dart';
import '../../styles/styles.dart';

class DoctorManagementPage extends StatefulWidget {
  const DoctorManagementPage({super.key});

  @override
  State<DoctorManagementPage> createState() => _DoctorManagementPageState();
}

class _DoctorManagementPageState extends State<DoctorManagementPage> {
  final BranchController _branchController = Get.put(BranchController());
  BranchModel? _selectedBranch;
  List<UserModel> _doctors = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initializeBranches();
  }

  Future<void> _initializeBranches() async {
    setState(() => _loading = true);
    await _branchController.getBranches();
    if (_branchController.branches.isNotEmpty) {
      _selectedBranch = _branchController.branches[0];
      await _fetchDoctors();
    }
    setState(() => _loading = false);
  }

  Future<void> _fetchDoctors() async {
    if (_selectedBranch == null) return;
    
    setState(() => _loading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('branchId', isEqualTo: _selectedBranch!.branchId)
          .get();
      
      _doctors = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching doctors: $e')),
      );
    }
    setState(() => _loading = false);
  }

  void _showDoctorForm([UserModel? doctor]) {
    final nameController = TextEditingController(text: doctor?.name ?? '');
    final specializationController = TextEditingController(text: doctor?.specialization ?? '');
    final phoneController = TextEditingController(text: doctor?.phoneNumber ?? '');
    final emailController = TextEditingController(text: doctor?.email ?? '');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fixed header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      doctor == null ? 'Add Doctor' : 'Edit Doctor',
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
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Name *',
                  hintText: 'Enter doctor name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specializationController,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  hintText: 'e.g., Dermatologist',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email address',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tertiaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Branch: ${_selectedBranch?.branchName ?? 'No branch selected'}',
                      style: TextStyle(fontWeight: FontWeight.w500, color: primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  CustomFilledButton(
                    title: doctor == null ? 'Add Doctor' : 'Update Doctor',
                    width: 140,
                    onPress: () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter doctor name')),
                        );
                        return;
                      }
                      
                      if (_selectedBranch == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a branch first')),
                        );
                        return;
                      }

                      final userData = UserModel(
                        userID: doctor?.userID ?? FirebaseFirestore.instance.collection('users').doc().id,
                        name: nameController.text.trim(),
                        role: 'doctor',
                        branchId: _selectedBranch!.branchId,
                        specialization: specializationController.text.trim().isEmpty ? null : specializationController.text.trim(),
                        phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                      );

                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userData.userID)
                            .set(userData.toMap());
                        
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(doctor == null ? 'Doctor added successfully!' : 'Doctor updated successfully!')),
                        );
                        await _fetchDoctors();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving doctor: $e')),
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
    );
  }

  Future<void> _deleteDoctor(UserModel doctor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: Text('Are you sure you want to delete Dr. ${doctor.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(doctor.userID)
            .delete();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor deleted successfully!')),
        );
        await _fetchDoctors();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting doctor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Management'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _selectedBranch != null ? () => _showDoctorForm() : null,
            tooltip: 'Add Doctor',
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Branch selection header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: tertiaryColor,
                  child: Row(
                    children: [
                      const Icon(Icons.business, color: Colors.black87),
                      const SizedBox(width: 8),
                      const Text(
                        'Select Branch:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(() => DropdownButton<BranchModel>(
                          value: _selectedBranch,
                          isExpanded: true,
                          items: _branchController.branches.map((branch) {
                            return DropdownMenuItem(
                              value: branch,
                              child: Text(branch.branchName),
                            );
                          }).toList(),
                          onChanged: (branch) {
                            setState(() {
                              _selectedBranch = branch;
                            });
                            if (branch != null) {
                              _fetchDoctors();
                            }
                          },
                          hint: const Text('Select a branch'),
                        )),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton.icon(
                          onPressed: _selectedBranch != null ? () => _showDoctorForm() : null,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Doctor'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Doctors list
                Expanded(
                  child: _selectedBranch == null
                      ? const Center(
                          child: Text(
                            'Please select a branch to view doctors',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : _doctors.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.medical_services, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No doctors added for ${_selectedBranch!.branchName}',
                                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: 180,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showDoctorForm(),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add First Doctor'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _doctors.length,
                              itemBuilder: (context, index) {
                                final doctor = _doctors[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: primaryColor,
                                      child: Text(
                                        doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      'Dr. ${doctor.name}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (doctor.specialization != null)
                                          Text('Specialization: ${doctor.specialization}'),
                                        if (doctor.phoneNumber != null)
                                          Text('Phone: ${doctor.phoneNumber}'),
                                        if (doctor.email != null)
                                          Text('Email: ${doctor.email}'),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _showDoctorForm(doctor),
                                          tooltip: 'Edit Doctor',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteDoctor(doctor),
                                          tooltip: 'Delete Doctor',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}
