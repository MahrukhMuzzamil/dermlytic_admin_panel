import 'package:flutter/material.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/drawer.dart';
// import 'package:aesthetics_labs_admin/ui/general_widgets/doctor_utilization_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// Removed GetX imports; using direct Firestore stream for branches

class AppointmentPage extends StatefulWidget {
  final String branchId;
  const AppointmentPage({super.key, required this.branchId});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}


class _AppointmentPageState extends State<AppointmentPage> {
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
  // Real appointments fetched from Firestore (per consultant)
  // consultant -> list of appointments (maps with at least start/end)
  Map<String, List<Map<String, dynamic>>> _appointmentsByConsultant = {};
  DateTime selectedDate = DateTime.now();
  final DateFormat timeFormat = DateFormat('h:mm a');
  final double slotWidth = 90;
  final int slotMinutes = 30;
  final double rowHeight = 64;
  final double lanePadding = 6;
  @override
  void initState() {
    super.initState();
    _fetchDoctorsAndRooms();
  }

  @override
  void didUpdateWidget(AppointmentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh doctors if branch changed
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
      // Fetch doctors for this branch
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

      // Get branch info for room count
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
        _rows = [...doctors, ...rooms]; // Combine doctors and rooms
      });
      
      print('AppointmentPage: Updated UI with ${doctors.length} doctors and ${rooms.length} rooms');
    } catch (e) {
      print('Error fetching doctors and rooms: $e');
      // Fallback to basic rooms if error
      setState(() {
        _doctors = [];
        _rooms = ['Room 1', 'Room 2'];
        _rows = ['Room 1', 'Room 2'];
      });
    }
  }

  // Controllers for form fields
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedGender;
  String? _selectedReferral;
  String? _selectedService;
  String? _selectedConsultant;
  String? _selectedDuration;
  String? _selectedRoom;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  // String? _selectedSlot; // not used
  String? _selectedStatus;

  // Scroll controllers to synchronize header/body and name/timeline lists
  final ScrollController _hHeaderController = ScrollController();
  final ScrollController _hBodyController = ScrollController();
  final ScrollController _vNamesController = ScrollController();
  final ScrollController _vGridController = ScrollController();

  @override
  void dispose() {
    _mobileController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _codeController.dispose();
    _emailController.dispose();
    _hHeaderController.dispose();
    _hBodyController.dispose();
    _vNamesController.dispose();
    _vGridController.dispose();
    super.dispose();
  }

  void _showAppointmentForm(String row, String timeSlot, [Map<String, dynamic>? appt]) {
    // Pre-fill controllers if editing
    if (appt != null) {
      _firstNameController.text = appt['userName'] ?? '';
      // You can prefill other fields as needed
      // For time fields, convert Timestamp to string for display
      if (appt['start'] != null) {
        DateTime startDT = appt['start'] is Timestamp ? (appt['start'] as Timestamp).toDate() : appt['start'];
        _selectedStartTime = TimeOfDay(hour: startDT.hour, minute: startDT.minute);
      }
      if (appt['end'] != null) {
        DateTime endDT = appt['end'] is Timestamp ? (appt['end'] as Timestamp).toDate() : appt['end'];
        _selectedEndTime = TimeOfDay(hour: endDT.hour, minute: endDT.minute);
      }
    } else {
      _firstNameController.clear();
      _lastNameController.clear();
      _mobileController.clear();
      _codeController.clear();
      _emailController.clear();
      _selectedGender = null;
      _selectedReferral = null;
      _selectedService = null;
      _selectedConsultant = row;
      _selectedDuration = null;
      _selectedRoom = null;
      _selectedStatus = null;
      // Parse timeSlot string to TimeOfDay

      try {
        final timeParts = timeSlot.replaceAll(' ', '').split(":");
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1].replaceAll(RegExp(r'[^0-9]'), ''));
        final isPM = timeSlot.toLowerCase().contains('pm');
        if (isPM && hour < 12) hour += 12;
        if (!isPM && hour == 12) hour = 0;
        _selectedStartTime = TimeOfDay(hour: hour, minute: minute);
      } catch (e) {
        _selectedStartTime = null;
      }
      _selectedEndTime = null;
    }
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: 600,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(appt == null ? 'Add Appointment' : 'Edit Appointment', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(),
                    // Client Info
                    //client info section
                    
                    //client info section
          

                    const Text('Client Info', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(controller: _mobileController, decoration: const InputDecoration(labelText: 'Mobile *', prefixText: '+92')),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First *'))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last *'))),
                      ],
                    ),
                    TextField(controller: _codeController, decoration: const InputDecoration(labelText: 'Code')),
                    TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (val) => setState(() => _selectedGender = val),
                            decoration: const InputDecoration(labelText: 'Gender *'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedReferral,
                            items: ['Google', 'Facebook', 'Friend', 'Other'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (val) => setState(() => _selectedReferral = val),
                            decoration: const InputDecoration(labelText: 'Referral *'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Appointment Info
                    const Text('Appointment Info', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(labelText: 'Service'),
                            onChanged: (val) => _selectedService = val,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedConsultant ?? row,
                            items: ['Any', ..._doctors, ..._rooms].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) => setState(() => _selectedConsultant = val),
                            decoration: const InputDecoration(labelText: 'Consultant'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            items: const [
                              'Open & confirmed',
                              'In-progress',
                              'Serviced',
                              'Cancelled',
                            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (val) => setState(() => _selectedStatus = val),
                            decoration: const InputDecoration(labelText: 'Status'),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _selectedStartTime ?? TimeOfDay(hour: 9, minute: 0),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedStartTime = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Start'),
                              child: Text(_selectedStartTime != null ? _selectedStartTime!.format(context) : 'Select Time'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedDuration,
                            items: ['15 mins', '30 mins', '45 mins', '60 mins'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (val) => setState(() => _selectedDuration = val),
                            decoration: const InputDecoration(labelText: 'Duration'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _selectedEndTime ?? TimeOfDay(hour: 9, minute: 0),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedEndTime = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'End'),
                              child: Text(_selectedEndTime != null ? _selectedEndTime!.format(context) : 'Select Time'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedRoom,
                      items: ['N/A', ..._rooms].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (val) => setState(() => _selectedRoom = val),
                      decoration: const InputDecoration(labelText: 'Room'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Gather data
                            // Parse start and end time as DateTime
                            DateTime? startDateTime;
                            if (_selectedStartTime != null) {
                              startDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, _selectedStartTime!.hour, _selectedStartTime!.minute);
                            }
                            DateTime? endDateTime;
                            if (_selectedEndTime != null) {
                              endDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, _selectedEndTime!.hour, _selectedEndTime!.minute);
                            }
                            final bookingData = {
                              'userPhoneNumber': _mobileController.text,
                              'userName': _firstNameController.text + ' ' + _lastNameController.text,
                              'code': _codeController.text,
                              'email': _emailController.text,
                              'gender': _selectedGender,
                              'referral': _selectedReferral,
                              'serviceName': _selectedService ?? '',
                              'consultant': _selectedConsultant ?? row,
                              'start': startDateTime,
                              'duration': _selectedDuration,
                              'end': endDateTime,
                              'roomId': _selectedRoom,
                                 'status': _selectedStatus ?? 'Open & confirmed',
                              'createdAt': DateTime.now(),
                            };
                            try {
                              // Write to Firestore (adjust path as needed)
                               await FirebaseFirestore.instance
                                   .collection('bookings')
                                   .doc(widget.branchId)
                                   .collection('bookings')
                                   .add({...bookingData, 'branchId': widget.branchId});
                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Booking successful!')),
                                );
                              }
                              setState(() {}); // Refresh UI
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to add booking: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('Save'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getColor(String? color) {
    switch (color) {
      case 'red': return Colors.red.shade200;
      case 'orange': return Colors.orange.shade200;
      case 'yellow': return Colors.yellow.shade200;
      case 'green': return Colors.green.shade200;
      case 'purple': return Colors.purple.shade200;
      case 'pink': return Colors.pink.shade200;
      default: return Colors.grey.shade200;
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Serviced':
        return Colors.green.shade200;
      case 'In-progress':
        return Colors.grey.shade300;
      case 'Open & confirmed':
        return Colors.indigo.shade200;
      case 'Cancelled':
        return Colors.purple.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  // Helpers to calculate positioning on the timeline
  DateTime _dayStart(DateTime forDate) =>
      DateTime(forDate.year, forDate.month, forDate.day, 8, 0);

  DateTime _dayEnd(DateTime forDate) =>
      DateTime(forDate.year, forDate.month, forDate.day, 22, 30);

  double _leftFromTime(DateTime dt) {
    final start = _dayStart(selectedDate);
    final minutesFromStart = dt.difference(start).inMinutes;
    final slotsFromStart = minutesFromStart / slotMinutes;
    return slotsFromStart * slotWidth;
  }

  double _widthFromDuration(Duration duration) {
    final slots = duration.inMinutes / slotMinutes;
    return slots * slotWidth;
  }

  String _formatTime(DateTime dt) => timeFormat.format(dt);

  // Build one consultant row with background grid and positioned appointments
  Widget _buildConsultantTimelineRow(String rowLabel) {
    final totalWidth = _timeSlots.length * slotWidth;
    final appointments = _appointmentsByConsultant[rowLabel] ?? [];
    final isToday = DateTime.now().year == selectedDate.year &&
        DateTime.now().month == selectedDate.month &&
        DateTime.now().day == selectedDate.day;
    final now = DateTime.now();

    return SizedBox(
      width: totalWidth,
      height: rowHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          // Convert click x to nearest slot time
          final dx = details.localPosition.dx.clamp(0, totalWidth);
          final slotsFromStart = (dx / slotWidth).floor();
          final dateTime = _dayStart(selectedDate)
              .add(Duration(minutes: slotsFromStart * slotMinutes));
          final slotKey = _formatTime(dateTime);
          _showAppointmentForm(rowLabel, slotKey, null);
        },
        child: Stack(
          children: [
            // Background grid
            Row(
              children: List.generate(_timeSlots.length, (index) {
                final even = index % 2 == 0;
                return Container(
                  width: slotWidth,
                  height: rowHeight,
                  decoration: BoxDecoration(
                    color: even ? Colors.pink[50] : Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey[300]!),
                      top: BorderSide(color: Colors.grey[300]!),
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                );
              }),
            ),
            // Now line
            if (isToday && now.isAfter(_dayStart(selectedDate)) && now.isBefore(_dayEnd(selectedDate)))
              Positioned(
                left: _leftFromTime(now),
                top: 0,
                bottom: 0,
                child: Container(width: 2, color: Colors.redAccent),
              ),
            // Appointments overlay with simple overlap lane assignment (up to 3 lanes visually)
            ..._assignLanes(appointments).map((laneItem) {
              final appt = laneItem['data'] as Map<String, dynamic>;
              final dynamic startRaw = appt['start'];
              final dynamic endRaw = appt['end'];
              DateTime? start; 
              DateTime? end;
              if (startRaw is Timestamp) start = startRaw.toDate();
              if (startRaw is DateTime) start = startRaw;
              if (endRaw is Timestamp) end = endRaw.toDate();
              if (endRaw is DateTime) end = endRaw;
              if (start == null) return const SizedBox.shrink();
              final DateTime startDt = start;
              final DateTime endDt = end ?? startDt.add(const Duration(minutes: 30));

              // Clamp to visible day window
              final visibleStart = startDt.isBefore(_dayStart(selectedDate))
                  ? _dayStart(selectedDate)
                  : startDt;
              final visibleEnd = endDt.isAfter(_dayEnd(selectedDate))
                  ? _dayEnd(selectedDate)
                  : endDt;

              final left = _leftFromTime(visibleStart);
              final width = (_widthFromDuration(visibleEnd.difference(visibleStart))).clamp(18.0, double.infinity);
              final color = appt['color'] != null
                  ? _getColor(appt['color'] as String?)
                  : _statusColor(appt['status'] as String?);
              final userName = (appt['userName'] ?? '') as String;
              final int lane = laneItem['lane'] as int; // 0..n
              final lanesUsed = (laneItem['lanesUsed'] as int).clamp(1, 3);
              final double laneHeight = (rowHeight - lanePadding * 2) / lanesUsed;
              final double top = lanePadding + lane * laneHeight;

              return Positioned(
                left: left,
                top: top,
                height: laneHeight - 6,
                width: width,
                child: InkWell(
                  onTap: () {
                    final slotKey = _formatTime(startDt);
                    _showAppointmentForm(rowLabel, slotKey, appt);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: Colors.grey[500]!),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            userName.isEmpty ? 'Appointment' : userName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Assign simple lanes for overlapping appointments within a row
  List<Map<String, Object>> _assignLanes(List<Map<String, dynamic>> appts) {
    if (appts.isEmpty) return const [];
    // normalize to DateTime, filter invalid
    final items = appts
        .map((a) {
          DateTime? s;
          DateTime? e;
          final sr = a['start'];
          final er = a['end'];
          if (sr is Timestamp) s = sr.toDate();
          if (sr is DateTime) s = sr;
          if (er is Timestamp) e = er.toDate();
          if (er is DateTime) e = er;
          if (s == null) return null;
          e ??= s.add(const Duration(minutes: 30));
          return {'data': a, 'start': s, 'end': e};
        })
        .whereType<Map<String, Object>>()
        .toList();

    items.sort((a, b) => (a['start'] as DateTime).compareTo(b['start'] as DateTime));
    final List<DateTime> laneEnds = [];
    final List<int> laneFor = [];
    for (final item in items) {
      final s = item['start'] as DateTime;
      final e = item['end'] as DateTime;
      int laneIndex = 0;
      for (; laneIndex < laneEnds.length; laneIndex++) {
        if (!s.isBefore(laneEnds[laneIndex])) break; // fits this lane
      }
      if (laneIndex == laneEnds.length) {
        laneEnds.add(e);
      } else {
        laneEnds[laneIndex] = e;
      }
      laneFor.add(laneIndex);
    }
    final int lanesUsed = laneEnds.length.clamp(1, 3);
    final result = <Map<String, Object>>[];
    for (var i = 0; i < items.length; i++) {
      result.add({'data': items[i]['data'] as Map<String, dynamic>, 'lane': laneFor[i] % 3, 'lanesUsed': lanesUsed});
    }
    return result;
  }

  // Calculate utilization percentage for a consultant for the visible day
  String _utilizationPercent(String rowLabel) {
    final appts = _appointmentsByConsultant[rowLabel] ?? [];
    if (appts.isEmpty) return '0.00%';
    final dayStart = _dayStart(selectedDate);
    final dayEnd = _dayEnd(selectedDate);
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
      e ??= s.add(const Duration(minutes: 30));
      final vs = s.isBefore(dayStart) ? dayStart : s;
      final ve = e.isAfter(dayEnd) ? dayEnd : e;
      if (ve.isAfter(vs)) booked += ve.difference(vs).inMinutes;
    }
    final total = dayEnd.difference(dayStart).inMinutes;
    final pct = (booked / total * 100).clamp(0, 100);
    return '${pct.toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments Scheduler'),
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          // Date picker row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('Selected Date: ' +
                    '${selectedDate.day.toString().padLeft(2, '0')}/'
                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                    '${selectedDate.year}'),
                const SizedBox(width: 16),
                ElevatedButton(
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
                  child: const Text('Select Date'),
                ),
                const SizedBox(width: 16),
                if (widget.branchId.isEmpty)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('branches').snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(width: 120, height: 24, child: LinearProgressIndicator(minHeight: 2)),
                        );
                      }
                      if (!snap.hasData || snap.data!.docs.isEmpty) {
                        return const Text('No branches');
                      }
                      final items = snap.data!.docs
                          .map((d) => DropdownMenuItem<String>(
                                value: d.id,
                                child: Text((d.data() as Map<String, dynamic>)['branchName'] ?? 'Branch'),
                              ))
                          .toList();
                      return DropdownButton<String>(
                        value: null,
                        hint: const Text('Select Branch'),
                        items: items,
                        onChanged: (val) {
                          if (val != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => AppointmentPage(branchId: val)),
                            );
                          }
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
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
                  return Center(child: Text('Error: \\${snapshot.error}'));
                }

                // Map Firestore data to _appointmentsByConsultant
                _appointmentsByConsultant = {};
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final consultant = (data['consultant'] ?? 'Unknown') as String;
                    (_appointmentsByConsultant[consultant] ??= []).add(data);
                  }
                }

                // Ensure we have the latest doctors/rooms data
                if (_rows.isEmpty) {
                  _fetchDoctorsAndRooms();
                }

                return Column(
                  children: [
                    // Timeline header
                    Container(
                      color: Colors.grey[200],
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 150,
                            child: Center(
                              child: Text('Consultants & Rooms', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ListView.builder(
                                controller: _hHeaderController,
                                scrollDirection: Axis.horizontal,
                                itemCount: _timeSlots.length,
                                itemBuilder: (context, index) {
                                  final slot = _timeSlots[index];
                                  return Container(
                                    width: slotWidth,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    alignment: Alignment.center,
                                    child: Text(slot, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                                        // Timeline grid + rows
                    Expanded(
                      child: _rows.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.medical_services, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No doctors or rooms configured for this branch',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Please add doctors in Doctor Management',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Consultant/Room names (sticky left) with utilization
                                SizedBox(
                                  width: 150,
                                  child: ListView.builder(
                                    controller: _vNamesController,
                                    itemCount: _rows.length,
                                    itemBuilder: (context, rowIdx) {
                                final rowLabel = _rows[rowIdx];
                                return Container(
                                  height: rowHeight,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                                    color: rowIdx % 2 == 0 ? Colors.pink[50] : Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(rowLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
                                      ),
                                      Text(_utilizationPercent(rowLabel), style: const TextStyle(fontSize: 11)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // Scrollable timeline body (horizontal + vertical)
                          Expanded(
                            child: Scrollbar(
                              controller: _hBodyController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _hBodyController,
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: _timeSlots.length * slotWidth,
                                  child: ListView.builder(
                                    controller: _vGridController,
                                    itemCount: _rows.length,
                                    itemBuilder: (context, rowIdx) {
                                      return _buildConsultantTimelineRow(_rows[rowIdx]);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            ),
                          ],
                        ),
                    ),
                    // Summary bar
                    Container(
                      color: Colors.grey[300],
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Total Guests: 30, Total Appointments: 37, Open Appointments: 28, Services Value: Rs767,000.00, Total Booked: 9.59%'),
                          Text('Muhammad Ashfaq'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 