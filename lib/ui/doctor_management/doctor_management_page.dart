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
      // Primary source: dedicated doctors collection
      final doctorsSnap = await FirebaseFirestore.instance
          .collection('doctors')
          .where('branchId', isEqualTo: _selectedBranch!.branchId)
          .where('isActive', isEqualTo: true)
          .get();

      // Legacy fallback: users collection with role=doctor (existing data before migration)
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('branchId', isEqualTo: _selectedBranch!.branchId)
          .where('isActive', isEqualTo: true)
          .get();

      print('DEBUG: DoctorManagement - Fetched doctors={${doctorsSnap.docs.length}} and legacyUsers={${usersSnap.docs.length}} for branch=${_selectedBranch!.branchId}');

      // Merge both sources, de-dup by id
      final Map<String, UserModel> merged = {};

      for (final d in doctorsSnap.docs) {
        final data = d.data();
        data['userID'] = d.id;
        merged[d.id] = UserModel.fromMap(data);
      }

      for (final u in usersSnap.docs) {
        final data = u.data();
        data['userID'] = u.id;
        merged.putIfAbsent(u.id, () => UserModel.fromMap(data));
      }

      _doctors = merged.values.toList();

      // Debug totals across collections
      final allDoctorsSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('isActive', isEqualTo: true)
          .get();
      final allUsersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('isActive', isEqualTo: true)
          .get();
      print('DEBUG: Totals - doctorsColl=${allDoctorsSnapshot.docs.length}, usersColl(role=doctor)=${allUsersSnapshot.docs.length}');

      print('DEBUG: Found ${_doctors.length} doctors for branch ${_selectedBranch!.branchId}');
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
                        role: UserRole.doctor, // Create actual doctors that sync with AppointmentPage
                        permissions: UserModel.getDefaultPermissions(UserRole.doctor),
                        branchId: _selectedBranch!.branchId,
                        specialization: specializationController.text.trim().isEmpty ? null : specializationController.text.trim(),
                        phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                      );

                      try {
                        // 1) Write full record to doctors collection
                        final doctorData = <String, dynamic>{
                          'userID': userData.userID,
                          'name': userData.name,
                          'role': 'doctor',
                          'branchId': userData.branchId,
                          'isActive': true,
                          'specialization': userData.specialization,
                          'phoneNumber': userData.phoneNumber,
                          'email': userData.email,
                        };
                        await FirebaseFirestore.instance
                            .collection('doctors')
                            .doc(userData.userID)
                            .set(doctorData);
                        
                        // 2) Mirror minimal fields to users collection for compatibility
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userData.userID)
                            .set({
                              'name': userData.name,
                              'role': 'doctor',
                              'branchId': userData.branchId,
                              'isActive': true,
                              'specialization': userData.specialization,
                              'phoneNumber': userData.phoneNumber,
                              'email': userData.email,
                            }, SetOptions(merge: true));
                        
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
        // Remove from doctors collection
        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(doctor.userID)
            .delete();
        // Also deactivate/remove mirror in users collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(doctor.userID)
            .set({'isActive': false}, SetOptions(merge: true));
        
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
      backgroundColor: backgroundSecondary,
      appBar: AppBar(
        title: const Text('Doctor Management', style: headingFontStyle),
        backgroundColor: primaryColor,
        foregroundColor: neutralWhite,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: spacingM),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(spacingS),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(neutralWhite.red, neutralWhite.green, neutralWhite.blue, 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, size: 20),
              ),
              onPressed: _selectedBranch != null ? () => _showDoctorForm() : null,
              tooltip: 'Add Doctor',
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      // Modern branch selection header
                      Container(
                  margin: EdgeInsets.all(spacingM),
                  padding: EdgeInsets.all(spacingL),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [backgroundPrimary, neutralLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: cardRadius,
                    boxShadow: const [cardShadow],
                    border: Border.all(color: neutralMedium),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(spacingM),
                        decoration: BoxDecoration(
                          gradient: secondaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.business, color: neutralWhite, size: 24),
                      ),
                      SizedBox(width: spacingM),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Branch Selection', style: captionFontStyle),
                          const Text('Choose clinic location', style: subHeadingFontStyle),
                        ],
                      ),
                      SizedBox(width: spacingL),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
                          decoration: BoxDecoration(
                            color: backgroundPrimary,
                            borderRadius: inputRadius,
                            border: Border.all(color: neutralMedium),
                          ),
                          child: Obx(() => DropdownButton<BranchModel>(
                            value: _selectedBranch,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: _branchController.branches.map((branch) {
                              return DropdownMenuItem(
                                value: branch,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    SizedBox(width: spacingS),
                                    Text(branch.branchName, style: bodyFontStyle),
                                  ],
                                ),
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
                            hint: const Text('Select a branch', style: bodyFontStyle),
                          )),
                        ),
                      ),
                      SizedBox(width: spacingM),
                      Container(
                        decoration: BoxDecoration(
                          gradient: primaryGradient,
                          borderRadius: buttonRadius,
                          boxShadow: const [subtleShadow],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _selectedBranch != null ? () => _showDoctorForm() : null,
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Add Doctor'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: neutralWhite,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: buttonRadius),
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
                              child: Container(
                                margin: EdgeInsets.all(spacingM),
                                padding: EdgeInsets.all(spacingL),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [backgroundPrimary, neutralLight],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: cardRadius,
                                  boxShadow: const [cardShadow],
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [primaryColor.withOpacity(0.1), accentColor.withOpacity(0.1)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(60),
                                      ),
                                      child: Icon(
                                        Icons.medical_services,
                                        size: 64,
                                        color: primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: spacingL),
                                    Text(
                                      'No doctors yet',
                                      style: headingFontStyle.copyWith(color: neutralBlack),
                                    ),
                                    SizedBox(height: spacingS),
                                    Text(
                                      'Add your first doctor for ${_selectedBranch!.branchName}',
                                      style: bodyFontStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: spacingL),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: primaryGradient,
                                        borderRadius: buttonRadius,
                                        boxShadow: const [subtleShadow],
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showDoctorForm(),
                                        icon: const Icon(Icons.add, size: 20),
                                        label: const Text('Add First Doctor'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: neutralWhite,
                                          shadowColor: Colors.transparent,
                                          padding: EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingM),
                                          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
                                        ),
                                      ),
                                    ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(spacingM),
                              itemCount: _doctors.length,
                              itemBuilder: (context, index) {
                                final doctor = _doctors[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: spacingM),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [backgroundPrimary, neutralLight],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: cardRadius,
                                    boxShadow: const [cardShadow],
                                    border: Border.all(color: neutralMedium),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(spacingL),
                                    child: Row(
                                      children: [
                                        // Modern doctor avatar
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            gradient: accentGradient,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: const [subtleShadow],
                                          ),
                                          child: Center(
                                            child: Text(
                                              doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                                              style: const TextStyle(
                                                color: neutralWhite,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: spacingM),
                                        // Doctor info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Dr. ${doctor.name}',
                                                style: subHeadingFontStyle.copyWith(color: neutralBlack),
                                              ),
                                              SizedBox(height: spacingXS),
                                              if (doctor.specialization != null)
                                                _buildInfoRow(Icons.medical_services, doctor.specialization!),
                                              if (doctor.phoneNumber != null)
                                                _buildInfoRow(Icons.phone, doctor.phoneNumber!),
                                              if (doctor.email != null)
                                                _buildInfoRow(Icons.email, doctor.email!),
                                            ],
                                          ),
                                        ),
                                        // Action buttons
                                        Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: infoColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: Icon(Icons.edit, color: infoColor, size: 20),
                                                onPressed: () => _showDoctorForm(doctor),
                                                tooltip: 'Edit Doctor',
                                              ),
                                            ),
                                            SizedBox(height: spacingS),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: errorColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: Icon(Icons.delete, color: errorColor, size: 20),
                                                onPressed: () => _deleteDoctor(doctor),
                                                tooltip: 'Delete Doctor',
                                              ),
                                            ),
                                          ],
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
              },
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: spacingXS),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 14, color: primaryColor),
          ),
          SizedBox(width: spacingS),
          Text(text, style: captionFontStyle),
        ],
      ),
    );
  }
}
