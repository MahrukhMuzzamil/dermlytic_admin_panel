import 'package:flutter/material.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:aesthetics_labs_admin/ui/general_widgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';

class AppointmentPageSimple extends StatefulWidget {
  final String branchId;
  const AppointmentPageSimple({super.key, required this.branchId});

  @override
  State<AppointmentPageSimple> createState() => _AppointmentPageSimpleState();
}

class _AppointmentPageSimpleState extends State<AppointmentPageSimple> {
  // Dynamic data from database
  List<String> _rows = [];
  List<String> _doctors = [];
  List<String> _rooms = [];
  
  final List<String> _timeSlots = [
    '8:00 AM', '8:30 AM', '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM', '1:00 PM', '1:30 PM',
    '2:00 PM', '2:30 PM', '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM',
    '5:00 PM', '5:30 PM', '6:00 PM', '6:30 PM', '7:00 PM', '7:30 PM',
    '8:00 PM', '8:30 PM', '9:00 PM', '9:30 PM', '10:00 PM', '10:30 PM',
  ];
  
  Map<String, List<Map<String, dynamic>>> _appointmentsByConsultant = {};
  DateTime selectedDate = DateTime.now();
  final DateFormat timeFormat = DateFormat('h:mm a');
  final double slotWidth = 90;
  final int slotMinutes = 30;
  final double rowHeight = 50;
  // Scroll controllers for scrollbars and syncing
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _leftVerticalController = ScrollController();
  final ScrollController _rightVerticalController = ScrollController();
  bool _syncingScroll = false;

  // Form controllers for booking
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _selectedGender;
  String? _selectedService;
  String? _selectedConsultant;
  String? _selectedStatus;
  String? _selectedReferral;

  @override
  void initState() {
    super.initState();
    _fetchDoctorsAndRooms();
    _leftVerticalController.addListener(() {
      if (_syncingScroll) return;
      if (!_rightVerticalController.hasClients) return;
      _syncingScroll = true;
      _rightVerticalController.jumpTo(_leftVerticalController.position.pixels);
      _syncingScroll = false;
    });
    _rightVerticalController.addListener(() {
      if (_syncingScroll) return;
      if (!_leftVerticalController.hasClients) return;
      _syncingScroll = true;
      _leftVerticalController.jumpTo(_rightVerticalController.position.pixels);
      _syncingScroll = false;
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _leftVerticalController.dispose();
    _rightVerticalController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppointmentPageSimple oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branchId != widget.branchId) {
      _fetchDoctorsAndRooms();
    }
  }

  Future<void> _fetchDoctorsAndRooms() async {
    if (widget.branchId.isEmpty) {
      print('AppointmentPage: No branchId provided, skipping doctor fetch');
      return;
    }
    
    print('AppointmentPage: Fetching doctors for branch: ${widget.branchId}');
    
    try {
      final doctorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('branchId', isEqualTo: widget.branchId)
          .get();
      
      final doctors = doctorSnapshot.docs.map((doc) {
        final data = doc.data();
        final doctorName = data['name'] as String? ?? 'Unknown Doctor';
        print('AppointmentPage: Found doctor: $doctorName for branch: ${data['branchId']}');
        return doctorName;
      }).toList();

      print('AppointmentPage: Total doctors found for branch ${widget.branchId}: ${doctors.length}');

      final branchSnapshot = await FirebaseFirestore.instance
          .collection('branches')
          .doc(widget.branchId)
          .get();
      
      final rooms = <String>[];
      if (branchSnapshot.exists) {
        final branchData = branchSnapshot.data() as Map<String, dynamic>;
        final roomCount = branchData['roomsCount'] as int? ?? 2;
        for (int i = 1; i <= roomCount; i++) {
          rooms.add('Room $i');
        }
      }

      setState(() {
        _doctors = doctors;
        _rooms = rooms;
        _rows = [...doctors, ...rooms];
      });
      
      print('AppointmentPage: Updated UI with ${doctors.length} doctors and ${rooms.length} rooms');
    } catch (e) {
      print('Error fetching doctors and rooms: $e');
      setState(() {
        _doctors = [];
        _rooms = ['Room 1', 'Room 2'];
        _rows = ['Room 1', 'Room 2'];
      });
    }
  }

  void _showAppointmentForm({String? timeSlot, String? consultant}) {
    // Reset form
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _codeController.clear();
    _selectedGender = null;
    _selectedService = null;
    _selectedConsultant = consultant;
    _selectedStatus = 'Open & confirmed';
    _selectedReferral = null;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_note, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Book Appointment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(timeSlot ?? 'Select Time', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Form content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Details
                      const Text('Patient Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Patient Name *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                labelText: 'Gender *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.wc),
                              ),
                              items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                              onChanged: (val) => setState(() => _selectedGender = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: 'Patient Code',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.confirmation_number),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Appointment Details
                      const Text('Appointment Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 12),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedService,
                        decoration: InputDecoration(
                          labelText: 'Service *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.medical_services),
                        ),
                        items: [
                          'HydraFacial', 'Chemical Peels', 'Microneedling', 'Botox', 'Dermal Fillers',
                          'Laser Hair Removal', 'Carbon Peel', 'Free Consultation'
                        ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _selectedService = val),
                      ),
                      const SizedBox(height: 12),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedConsultant,
                        decoration: InputDecoration(
                          labelText: 'Consultant/Room *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        items: _rows.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (val) => setState(() => _selectedConsultant = val),
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.flag),
                              ),
                              items: ['Open & confirmed', 'In-progress', 'Serviced', 'Cancelled']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (val) => setState(() => _selectedStatus = val),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedReferral,
                              decoration: InputDecoration(
                                labelText: 'Referral Source',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.source),
                              ),
                              items: ['Direct', 'Facebook', 'Google', 'Friend', 'Instagram', 'Other']
                                  .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                              onChanged: (val) => setState(() => _selectedReferral = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _saveAppointment(timeSlot),
                              child: const Text('Book Appointment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
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

  void _saveAppointment(String? timeSlot) async {
    // Validation
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _selectedGender == null ||
        _selectedService == null ||
        _selectedConsultant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    try {
      // Parse time slot to create appointment start time
      DateTime startTime = selectedDate;
      if (timeSlot != null) {
        final timeParts = timeSlot.split(' ');
        final hourMinute = timeParts[0].split(':');
        int hour = int.parse(hourMinute[0]);
        final minute = int.parse(hourMinute[1]);
        
        if (timeParts[1] == 'PM' && hour != 12) hour += 12;
        if (timeParts[1] == 'AM' && hour == 12) hour = 0;
        
        startTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, hour, minute);
      }

      // Default 30-minute duration
      final endTime = startTime.add(const Duration(minutes: 30));

      final appointmentData = {
        'userName': _nameController.text.trim(),
        'userPhoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'code': _codeController.text.trim(),
        'gender': _selectedGender,
        'serviceName': _selectedService,
        'consultant': _selectedConsultant,
        'status': _selectedStatus,
        'referral': _selectedReferral ?? 'Direct',
        'branchId': widget.branchId,
        'roomId': _selectedConsultant,
        'start': Timestamp.fromDate(startTime),
        'end': Timestamp.fromDate(endTime),
        'duration': '30 mins',
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.branchId)
          .collection('bookings')
          .add(appointmentData);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking appointment: $e')),
      );
    }
  }

  // Helper method to get appointment for a specific time slot
  Map<String, dynamic>? _getAppointmentForSlot(String consultant, String timeSlot) {
    // Parse the time slot to get the hour and minute
    final timeParts = timeSlot.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    
    if (timeParts[1] == 'PM' && hour != 12) hour += 12;
    if (timeParts[1] == 'AM' && hour == 12) hour = 0;
    
    final slotDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, hour, minute);
    
    // Check all appointments for this consultant
    final consultantAppointments = _appointmentsByConsultant[consultant] ?? [];
    
    for (final appointment in consultantAppointments) {
      final start = (appointment['start'] as Timestamp).toDate();
      final end = appointment['end'] != null 
        ? (appointment['end'] as Timestamp).toDate()
        : start.add(const Duration(minutes: 30)); // Default 30 min if no end time
      
      // Check if the time slot falls within the appointment time
      if (slotDateTime.isAfter(start.subtract(const Duration(minutes: 1))) &&
          slotDateTime.isBefore(end)) {
        return appointment;
      }
    }
    
    return null;
  }

  // Helper method to get status color (synced with dashboard)
  Color _getStatusColor(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'serviced') return Colors.green.shade400;
    if (s == 'in-progress') return lightGrey;
    if (s == 'open & confirmed') return primaryColor;
    if (s == 'cancelled') return Colors.pink.shade300;
    return Colors.blueGrey; // default like dashboard
  }

  // Method to show appointment details when clicking on existing appointment
  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: primaryColor, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Appointment Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Patient', appointment['userName'] ?? 'Unknown'),
              _buildDetailRow('Phone', appointment['userPhoneNumber'] ?? 'N/A'),
              _buildDetailRow('Email', appointment['email'] ?? 'N/A'),
              _buildDetailRow('Service', appointment['serviceName'] ?? 'N/A'),
              _buildDetailRow('Consultant', appointment['consultant'] ?? 'N/A'),
              _buildDetailRow('Status', appointment['status'] ?? 'N/A'),
              _buildDetailRow('Code', appointment['code'] ?? 'N/A'),
              if (appointment['start'] != null)
                _buildDetailRow('Time', 
                  '${DateFormat('MMM dd, yyyy - h:mm a').format((appointment['start'] as Timestamp).toDate())}'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditAppointmentForm(appointment);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Edit form populated with existing appointment details
  void _showEditAppointmentForm(Map<String, dynamic> appointment) {
    // Prefill controllers and selections
    _nameController.text = (appointment['userName'] ?? '').toString();
    _phoneController.text = (appointment['userPhoneNumber'] ?? '').toString();
    _emailController.text = (appointment['email'] ?? '').toString();
    _codeController.text = (appointment['code'] ?? '').toString();
    _selectedGender = appointment['gender'] as String?;
    _selectedService = appointment['serviceName'] as String?;
    _selectedConsultant = appointment['consultant'] as String?;
    _selectedStatus = (appointment['status'] as String?) ?? 'Open & confirmed';
    _selectedReferral = appointment['referral'] as String?;

    DateTime originalStart = appointment['start'] is Timestamp
        ? (appointment['start'] as Timestamp).toDate()
        : (appointment['start'] as DateTime? ?? DateTime.now());
    DateTime originalEnd = appointment['end'] is Timestamp
        ? (appointment['end'] as Timestamp).toDate()
        : (appointment['end'] as DateTime? ?? originalStart.add(const Duration(minutes: 30)));
    int originalDurationMins = originalEnd.difference(originalStart).inMinutes;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Edit Appointment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: StatefulBuilder(
                  builder: (context, setLocalState) {
                    DateTime tempStart = originalStart;
                    return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reschedule controls
                      const Text('Reschedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: tempStart,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setLocalState(() {
                                  tempStart = DateTime(picked.year, picked.month, picked.day, tempStart.hour, tempStart.minute);
                                  originalStart = tempStart;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today),
                            label: Text('${tempStart.day.toString().padLeft(2, '0')}/${tempStart.month.toString().padLeft(2, '0')}/${tempStart.year}'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: tempStart.hour, minute: tempStart.minute),
                              );
                              if (picked != null) {
                                setLocalState(() {
                                  tempStart = DateTime(tempStart.year, tempStart.month, tempStart.day, picked.hour, picked.minute);
                                  originalStart = tempStart;
                                });
                              }
                            },
                            icon: const Icon(Icons.schedule),
                            label: Text(DateFormat('h:mm a').format(tempStart)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Reuse the same input widgets as booking form
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Patient Name *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                labelText: 'Gender *',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.wc),
                              ),
                              items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                              onChanged: (val) => setState(() => _selectedGender = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: 'Patient Code',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.confirmation_number),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedService,
                        decoration: InputDecoration(
                          labelText: 'Service *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.medical_services),
                        ),
                        items: [
                          'HydraFacial', 'Chemical Peels', 'Microneedling', 'Botox', 'Dermal Fillers',
                          'Laser Hair Removal', 'Carbon Peel', 'Free Consultation'
                        ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _selectedService = val),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedConsultant,
                        decoration: InputDecoration(
                          labelText: 'Consultant/Room *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        items: _rows.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (val) => setState(() => _selectedConsultant = val),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.flag),
                              ),
                              items: ['Open & confirmed', 'In-progress', 'Serviced', 'Cancelled']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (val) => setState(() => _selectedStatus = val),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: ['Direct','Facebook','Google','Friend','Instagram','Other'].contains(_selectedReferral) ? _selectedReferral : 'Direct',
                              decoration: InputDecoration(
                                labelText: 'Referral Source',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.source),
                              ),
                              items: ['Direct', 'Facebook', 'Google', 'Friend', 'Instagram', 'Other']
                                  .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                              onChanged: (val) => setState(() => _selectedReferral = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateAppointment(appointment, newStart: originalStart, newDurationMinutes: originalDurationMins),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateAppointment(Map<String, dynamic> original, {DateTime? newStart, int? newDurationMinutes}) async {
    // Validate
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _selectedService == null ||
        _selectedConsultant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    try {
      final docId = original['_id'] as String?;
      if (docId == null) throw 'Missing document id for appointment';

      final update = <String, dynamic>{
        'userName': _nameController.text.trim(),
        'userPhoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'code': _codeController.text.trim(),
        'gender': _selectedGender,
        'serviceName': _selectedService,
        'consultant': _selectedConsultant,
        'roomId': _selectedConsultant,
        'status': _selectedStatus,
        'referral': _selectedReferral,
      };

      if (newStart != null) {
        final duration = (newDurationMinutes ?? 30).clamp(5, 24 * 60);
        update['start'] = Timestamp.fromDate(newStart);
        update['end'] = Timestamp.fromDate(newStart.add(Duration(minutes: duration)));
      }

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.branchId)
          .collection('bookings')
          .doc(docId)
          .update(update);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Calculate utilization percentage for a consultant for the visible day
  String _utilizationPercent(String rowLabel) {
    final appts = _appointmentsByConsultant[rowLabel] ?? [];
    if (appts.isEmpty) return '0%';
    
    final dayStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 8, 0);
    final dayEnd = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 22, 30);
    
    int booked = 0;
    for (final appt in appts) {
      DateTime? s;
      DateTime? e;
      final sr = appt['start'];
      final er = appt['end'];
      
      if (sr is Timestamp) s = sr.toDate();
      if (sr is DateTime) s = sr;
      if (er is Timestamp) e = er.toDate();
      if (er is DateTime) e = er;
      
      if (s == null) continue;
      e ??= s.add(const Duration(minutes: 30)); // Default 30 min if no end time
      
      final vs = s.isBefore(dayStart) ? dayStart : s;
      final ve = e.isAfter(dayEnd) ? dayEnd : e;
      
      if (ve.isAfter(vs)) booked += ve.difference(vs).inMinutes;
    }
    
    final total = dayEnd.difference(dayStart).inMinutes;
    final pct = (booked / total * 100).clamp(0, 100);
    return '${pct.toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundSecondary,
      appBar: AppBar(
        title: const Text('Appointments Scheduler', style: headingFontStyle),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      drawer: const MyDrawer(),
      body: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad, PointerDeviceKind.stylus},
        ),
        child: Column(
        children: [
          // Compact date picker section
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundPrimary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: primaryColor, size: 18),
                const SizedBox(width: 12),
                Text(
                  '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.edit_calendar, size: 16),
                  label: const Text('Change', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                if (widget.branchId.isEmpty)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('branches').snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const SizedBox(width: 80, height: 20, child: LinearProgressIndicator(minHeight: 2));
                      }
                      if (!snap.hasData || snap.data!.docs.isEmpty) {
                        return const Text('No branches', style: TextStyle(fontSize: 12));
                      }
                      final items = snap.data!.docs
                          .map((d) => DropdownMenuItem<String>(
                                value: d.id,
                                child: Text((d.data() as Map<String, dynamic>)['branchName'] ?? 'Branch'),
                              ))
                          .toList();
                      return DropdownButton<String>(
                        value: null,
                        hint: const Text('Select Branch', style: TextStyle(fontSize: 12)),
                        items: items,
                        onChanged: (val) {
                          if (val != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => AppointmentPageSimple(branchId: val)),
                            );
                          }
                        },
                      );
                    },
                ),
              ],
            ),
          ),
          
          // Main content
          Expanded(
            child: widget.branchId.isEmpty
                ? const Center(child: Text('Please select a branch to view the scheduler.'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .doc(widget.branchId)
                        .collection('bookings')
                        .where(
                          'start',
                          isGreaterThanOrEqualTo:
                              DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0),
                        )
                        .where(
                          'start',
                          isLessThanOrEqualTo:
                              DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59, 999),
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      // Map Firestore data to _appointmentsByConsultant
                      _appointmentsByConsultant = {};
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        print('Found ${snapshot.data!.docs.length} appointments for date ${selectedDate.toString().split(' ')[0]}');
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final consultant = (data['consultant'] ?? 'Unknown') as String;
                          // Attach the Firestore document id for editing updates
                          final withId = {...data, '_id': doc.id};
                          print('Appointment: ${data['userName']} with $consultant at ${data['start']}');
                          (_appointmentsByConsultant[consultant] ??= []).add(withId);
                        }
                        print('Appointments by consultant: ${_appointmentsByConsultant.keys.toList()}');
                      } else {
                        print('No appointments found for date ${selectedDate.toString().split(' ')[0]}');
                      }

                      if (_rows.isEmpty) {
                        _fetchDoctorsAndRooms();
                      }

                      return Column(
                        children: [
                          // Compact timeline header
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 150,
                                  alignment: Alignment.center,
                                  child: const Text('Consultants & Rooms', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 32,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _timeSlots.length,
                                      itemBuilder: (context, index) {
                                        final slot = _timeSlots[index];
                                        return Container(
                                          width: slotWidth,
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          alignment: Alignment.center,
                                          child: Text(slot, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Timeline body
                          Expanded(
                            child: _rows.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.medical_services, size: 48, color: Colors.grey[400]),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No doctors or rooms configured for this branch',
                                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Please add doctors in Doctor Management',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: backgroundPrimary,
                                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                      boxShadow: const [cardShadow],
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Consultant names
                                        Container(
                                          width: 150,
                                          decoration: BoxDecoration(
                                            border: Border(right: BorderSide(color: Colors.grey[300]!)),
                                          ),
                                          child: Scrollbar(
                                            controller: _leftVerticalController,
                                            thumbVisibility: true,
                                            child: ListView.builder(
                                              controller: _leftVerticalController,
                                              itemCount: _rows.length,
                                              itemBuilder: (context, rowIdx) {
                                              final rowLabel = _rows[rowIdx];
                                              final isDoctor = _doctors.contains(rowLabel);
                                              return Container(
                                                height: rowHeight,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                                                  color: rowIdx % 2 == 0 ? Colors.grey[50] : Colors.white,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 28,
                                                      height: 28,
                                                      decoration: BoxDecoration(
                                                        color: isDoctor ? primaryColor : secondaryColor,
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Icon(
                                                        isDoctor ? Icons.person : Icons.meeting_room,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            rowLabel,
                                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          Text(
                                                            '${_utilizationPercent(rowLabel)} busy',
                                                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              },
                                            ),
                                          ),
                                        ),
                                        
                                        // Timeline grid
                                        Expanded(
                                          child: Scrollbar(
                                            controller: _horizontalController,
                                            thumbVisibility: true,
                                            child: SingleChildScrollView(
                                              controller: _horizontalController,
                                              scrollDirection: Axis.horizontal,
                                              child: SizedBox(
                                                width: _timeSlots.length * slotWidth,
                                                child: Scrollbar(
                                                  controller: _rightVerticalController,
                                                  thumbVisibility: true,
                                                  child: ListView.builder(
                                                    controller: _rightVerticalController,
                                                    itemCount: _rows.length,
                                                    itemBuilder: (context, rowIdx) {
                                                  return Container(
                                                    height: rowHeight,
                                                    child: Row(
                                                      children: List.generate(_timeSlots.length, (index) {
                                                        final even = index % 2 == 0;
                                                        final timeSlot = _timeSlots[index];
                                                        final consultant = _rows[rowIdx];
                                                        
                                                        // Check if there's an appointment in this slot
                                                        final appointment = _getAppointmentForSlot(consultant, timeSlot);
                                                        
                                                        return GestureDetector(
                                                          onTap: appointment == null 
                                                            ? () => _showAppointmentForm(
                                                                timeSlot: timeSlot,
                                                                consultant: consultant,
                                                              )
                                                            : () => _showAppointmentDetails(appointment),
                                                          child: Container(
                                                            width: slotWidth,
                                                            height: rowHeight,
                                                            decoration: BoxDecoration(
                                                              color: appointment != null 
                                                                ? _getStatusColor(appointment['status'] ?? 'Open & confirmed')
                                                                : (even ? Colors.grey[50] : Colors.white),
                                                              border: Border(
                                                                right: BorderSide(color: Colors.grey[300]!, width: 0.5),
                                                                bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
                                                              ),
                                                              borderRadius: appointment != null 
                                                                ? BorderRadius.circular(4) 
                                                                : null,
                                                            ),
                                                            child: MouseRegion(
                                                              cursor: SystemMouseCursors.click,
                                                              child: appointment != null
                                                                ? Padding(
                                                                    padding: const EdgeInsets.all(2),
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        Text(
                                                                          appointment['userName'] ?? 'Unknown',
                                                                          style: const TextStyle(
                                                                            fontSize: 10,
                                                                            fontWeight: FontWeight.bold,
                                                                            color: Colors.white,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                        ),
                                                                        Text(
                                                                          appointment['serviceName'] ?? '',
                                                                          style: const TextStyle(
                                                                            fontSize: 8,
                                                                            color: Colors.white,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                : const Center(
                                                                    child: Icon(Icons.add, color: Colors.grey, size: 16),
                                                                  ),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          ),
                                        ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
  }
}
