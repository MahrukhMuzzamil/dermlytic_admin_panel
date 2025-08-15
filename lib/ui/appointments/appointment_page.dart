import 'package:flutter/material.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/drawer.dart';
// import 'package:aesthetics_labs_admin/ui/general_widgets/doctor_utilization_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';
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
        return Color.fromRGBO(successColor.red, successColor.green, successColor.blue, 0.2);
      case 'In-progress':
        return Color.fromRGBO(warningColor.red, warningColor.green, warningColor.blue, 0.2);
      case 'Open & confirmed':
        return Color.fromRGBO(infoColor.red, infoColor.green, infoColor.blue, 0.2);
      case 'Cancelled':
        return Color.fromRGBO(errorColor.red, errorColor.green, errorColor.blue, 0.2);
      default:
        return neutralMedium;
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

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(spacingS),
          decoration: BoxDecoration(
            color: Color.fromRGBO(primaryColor.red, primaryColor.green, primaryColor.blue, 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: primaryColor),
        ),
        const SizedBox(width: spacingS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: smallFontStyle),
            Text(value, style: bodyFontStyleBold.copyWith(fontSize: 14)),
          ],
        ),
      ],
    );
  }

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
                    color: even ? Color.fromRGBO(neutralLight.red, neutralLight.green, neutralLight.blue, 0.3) : backgroundPrimary,
                    border: Border(
                      right: BorderSide(color: neutralMedium, width: 0.5),
                      top: BorderSide(color: neutralMedium, width: 0.5),
                      bottom: BorderSide(color: neutralMedium, width: 0.5),
                    ),
                  ),
                );
              }),
            ),
            // Modern now line
            if (isToday && now.isAfter(_dayStart(selectedDate)) && now.isBefore(_dayEnd(selectedDate)))
              Positioned(
                left: _leftFromTime(now),
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [errorColor, warningColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(errorColor.red, errorColor.green, errorColor.blue, 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: spacingS, vertical: spacingXS),
                    decoration: BoxDecoration(
                      color: color,
                      boxShadow: const [subtleShadow],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.darken(0.2),
                        width: 1,
                      ),
                    ),
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: neutralWhite,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 10,
                              color: color.darken(0.3),
                            ),
                          ),
                          const SizedBox(width: spacingXS),
                          Text(
                            userName.isEmpty ? 'Appointment' : userName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: neutralBlack,
                            ),
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
      backgroundColor: backgroundSecondary,
      appBar: AppBar(
        title: const Text('Appointments Scheduler', style: headingFontStyle),
        backgroundColor: primaryColor,
        foregroundColor: neutralWhite,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          // Modern date picker section
          Container(
            margin: const EdgeInsets.all(spacingM),
            padding: const EdgeInsets.all(spacingL),
            decoration: BoxDecoration(
              color: backgroundPrimary,
              borderRadius: cardRadius,
              boxShadow: const [cardShadow],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(spacingM),
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: buttonRadius,
                  ),
                  child: const Icon(Icons.calendar_today, color: neutralWhite, size: 20),
                ),
                const SizedBox(width: spacingM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selected Date', style: captionFontStyle),
                    Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                      style: subHeadingFontStyle,
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: primaryColor,
                              onPrimary: neutralWhite,
                              surface: backgroundPrimary,
                              onSurface: neutralBlack,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.edit_calendar, size: 18),
                  label: const Text('Change'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: neutralWhite,
                    shape: RoundedRectangleBorder(borderRadius: buttonRadius),
                    elevation: 0,
                  ),
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
                    // Modern timeline header
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: spacingM),
                      padding: const EdgeInsets.all(spacingM),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color.fromRGBO(primaryColor.red, primaryColor.green, primaryColor.blue, 0.1), Color.fromRGBO(secondaryColor.red, secondaryColor.green, secondaryColor.blue, 0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        border: Border.all(color: neutralMedium),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 150,
                            alignment: Alignment.center,
                            child: const Text('Consultants & Rooms', style: bodyFontStyleBold),
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
                          : Container(
                              margin: const EdgeInsets.symmetric(horizontal: spacingM),
                              decoration: BoxDecoration(
                                color: backgroundPrimary,
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                boxShadow: const [cardShadow],
                                border: Border.all(color: neutralMedium),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Modern consultant/room names section
                                  Container(
                                    width: 150,
                                    decoration: const BoxDecoration(
                                      border: Border(right: BorderSide(color: neutralMedium)),
                                    ),
                                    child: ListView.builder(
                                      controller: _vNamesController,
                                      itemCount: _rows.length,
                                      itemBuilder: (context, rowIdx) {
                                  final rowLabel = _rows[rowIdx];
                                  final isDoctor = _doctors.contains(rowLabel);
                                  return Container(
                                    height: rowHeight,
                                    padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: neutralMedium)),
                                      color: rowIdx % 2 == 0 ? neutralLight : backgroundPrimary,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            gradient: isDoctor ? primaryGradient : secondaryGradient,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            isDoctor ? Icons.person : Icons.meeting_room,
                                            color: neutralWhite,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: spacingS),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                rowLabel,
                                                style: bodyFontStyleBold.copyWith(fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${_utilizationPercent(rowLabel)} busy',
                                                style: smallFontStyle.copyWith(color: neutralDark),
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
                        ],
                      ),
                    ),
                  ),
                    // Modern summary bar
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color.fromRGBO(primaryColor.red, primaryColor.green, primaryColor.blue, 0.05), Color.fromRGBO(accentColor.red, accentColor.green, accentColor.blue, 0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: cardRadius,
                        border: Border.all(color: neutralMedium),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: spacingL,
                              runSpacing: spacingS,
                              children: [
                                _buildSummaryItem('Total Guests', '30', Icons.people),
                                _buildSummaryItem('Appointments', '37', Icons.event),
                                _buildSummaryItem('Open', '28', Icons.schedule),
                                _buildSummaryItem('Revenue', 'Rs767,000', Icons.attach_money),
                                _buildSummaryItem('Utilization', '9.59%', Icons.trending_up),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
                            decoration: BoxDecoration(
                              gradient: primaryGradient,
                              borderRadius: buttonRadius,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                const Text('Muhammad Ashfaq', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
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