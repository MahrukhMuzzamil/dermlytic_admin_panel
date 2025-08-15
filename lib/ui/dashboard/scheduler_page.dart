
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/branch_model.dart';
import '../general_widgets/drawer.dart';
// import '../booking_management/add_new_booking.dart';
// import 'package:firebase_core/firebase_core.dart';
import '../../styles/styles.dart';

// Removed standalone main() to avoid duplicate runApp in app

class SchedulerPage extends StatefulWidget {
  const SchedulerPage({super.key});

  @override
  State<SchedulerPage> createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  // New state for doctors, rooms, and branches
  List<UserModel> _doctors = [];
  List<String> _rooms = [];
  UserModel? _selectedDoctor;
  String? _selectedRoom;
  BranchModel? _selectedBranch;
  List<BranchModel> _branches = [];
  bool _loading = true;
  // New: status filter and counts
  final List<String> _statusOptions = const ['Open & confirmed', 'In-progress', 'Serviced', 'Cancelled'];
  String? _selectedStatusFilter; // null = All
  Map<String, int> _statusCounts = const {};
  int _uniqueGuests = 0;
  num _totalRevenue = 0;

  // Add this map to assign a color to each doctor
  final Map<String, Color> _doctorColors = {};
  final List<Color> _availableColors = [
    Colors.pink,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.red,
    Colors.brown,
    Colors.cyan,
    Colors.indigo,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lime,
    Colors.lightBlue,
    Colors.lightGreen,
  ];

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    setState(() { _loading = true; });
    final branchSnaps = await FirebaseFirestore.instance.collection('branches').get();
    final branches = branchSnaps.docs.map((doc) => BranchModel.fromMap(doc.data(), documentId: doc.id)).toList();
    setState(() {
      _branches = branches;
      _selectedBranch = branches.isNotEmpty ? branches[0] : null;
      _loading = false;
    });
    if (_selectedBranch != null) {
      await _fetchDoctorsAndRooms();
    }
  }

  Future<void> _fetchDoctorsAndRooms() async {
    setState(() { _loading = true; });
    if (_selectedBranch == null) {
      setState(() {
        _doctors = [];
        _rooms = [];
        _selectedDoctor = null;
        _selectedRoom = null;
        _loading = false;
      });
      return;
    }
    // Fetch doctors for the selected branch
    final doctorSnaps = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'doctor')
      .where('branchId', isEqualTo: _selectedBranch!.branchId)
      .get();
    final doctors = doctorSnaps.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    // Generate room list
    final rooms = <String>[];
    final roomCount = _selectedBranch?.roomsCount ?? 1;
    for (int i = 1; i <= roomCount; i++) {
      rooms.add('Room $i');
    }
    setState(() {
      _doctors = doctors;
      _selectedDoctor = doctors.isNotEmpty ? doctors[0] : null;
      _rooms = rooms;
      _selectedRoom = rooms.isNotEmpty ? rooms[0] : null;
      _loading = false;
    });
    _assignDoctorColors();
  }

  // Assign a color to each doctor
  void _assignDoctorColors() {
    _doctorColors.clear();
    for (int i = 0; i < _doctors.length; i++) {
      _doctorColors[_doctors[i].userID] = _availableColors[i % _availableColors.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_branches.isEmpty) {
      return const Center(child: Text('No clinics found. Please add branches to the database.'));
    }
    // Do not block the dashboard if there are no doctors; we can still show bars and bookings
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultant Scheduler'),
        backgroundColor: primaryColor,
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          // Top search bar, date picker, branch, doctor and room dropdowns
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Search bar
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}), // Trigger rebuild on search text change
                    decoration: InputDecoration(
                      hintText: 'Name, Phone, Email, Code',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Date picker
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _selectedDate.toString().substring(0, 10),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                // Status filter
                DropdownButton<String?>(
                  value: _selectedStatusFilter,
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('All Statuses')),
                    ..._statusOptions.map((s) => DropdownMenuItem<String?>(value: s, child: Text(s))),
                  ],
                  onChanged: (val) => setState(() => _selectedStatusFilter = val),
                ),
                const SizedBox(width: 16),
                // Branch dropdown
                DropdownButton<BranchModel>(
                  value: _selectedBranch,
                  items: _branches.map((branch) => DropdownMenuItem(
                    value: branch,
                    child: Text(branch.branchName),
                  )).toList(),
                  onChanged: (val) async {
                    setState(() { _selectedBranch = val; });
                    await _fetchDoctorsAndRooms();
                  },
                  hint: const Text('Select Clinic'),
                ),
                if (_doctors.isNotEmpty) ...[
                const SizedBox(width: 16),
                DropdownButton<UserModel>(
                  value: _selectedDoctor,
                  items: _doctors.map((doc) => DropdownMenuItem(
                    value: doc,
                    child: Text(doc.name),
                  )).toList(),
                  onChanged: (val) {
                    setState(() { _selectedDoctor = val; });
                  },
                  hint: const Text('Select Doctor'),
                ),
                ],
                if (_rooms.isNotEmpty) ...[
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedRoom,
                  items: _rooms.map((room) => DropdownMenuItem(
                    value: room,
                    child: Text(room),
                  )).toList(),
                  onChanged: (val) {
                    setState(() { _selectedRoom = val; });
                  },
                  hint: const Text('Select Room'),
                ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // Timeline calendar
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                .collection('bookings')
                .doc(_selectedBranch?.branchId)
                .collection('bookings')
                .where('start', isGreaterThanOrEqualTo: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day))
                .where('start', isLessThanOrEqualTo: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59, 999))
                .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Debug print
                print('Fetched appointments:');
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    print(doc.data());
                  }
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No appointments for this day.'));
                }
                // Compute status counts and filter
                final statusCounts = <String, int>{};
                final Set<String> uniqueGuests = {};
                num totalRevenue = 0;
                final searchText = _searchController.text.toLowerCase().trim();
                final docs = snapshot.data!.docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final matchesStatus = _selectedStatusFilter == null || data['status'] == _selectedStatusFilter;
                  
                  // Search filter
                  bool matchesSearch = true;
                  if (searchText.isNotEmpty) {
                    final userName = (data['userName'] ?? '').toString().toLowerCase();
                    final phone = (data['userPhoneNumber'] ?? '').toString().toLowerCase();
                    final email = (data['email'] ?? '').toString().toLowerCase();
                    final code = (data['code'] ?? '').toString().toLowerCase();
                    
                    matchesSearch = userName.contains(searchText) ||
                        phone.contains(searchText) ||
                        email.contains(searchText) ||
                        code.contains(searchText);
                  }
                  
                  return matchesStatus && matchesSearch;
                }).toList();
                for (final d in snapshot.data!.docs) {
                  final m = d.data() as Map<String, dynamic>;
                  final s = m['status'] as String? ?? 'Open & confirmed';
                  statusCounts[s] = (statusCounts[s] ?? 0) + 1;
                  if (m['userPhoneNumber'] is String) uniqueGuests.add(m['userPhoneNumber'] as String);
                  if (m['price'] is num) totalRevenue += (m['price'] as num);
                }
                _statusCounts = statusCounts;
                _uniqueGuests = uniqueGuests.length;
                _totalRevenue = totalRevenue;

                final appointments = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final doctorId = data['consultant'] as String?; // using consultant as resource key
                  final start = data['start'];
                  final end = data['end'];
                  DateTime startDt = start is Timestamp ? start.toDate() : (start as DateTime);
                  DateTime endDt = end is Timestamp ? end.toDate() : (end as DateTime? ?? startDt.add(const Duration(minutes: 30)));
                  final subject = data['userName'] ?? 'Appointment';
                  final status = data['status'] as String? ?? 'Open & confirmed';
                  final color = _statusColor(status);
                  return Appointment(
                    startTime: startDt,
                    endTime: endDt,
                    subject: subject,
                    color: color,
                    notes: 'Consultant: ${data['consultant'] ?? ''}\nRoom: ${data['roomId'] ?? ''}\nStatus: $status',
                    resourceIds: doctorId != null ? [doctorId] : [],
                  );
                }).toList();
                return Column(
                  children: [
                    // Status bar card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: _buildStatusBarCard(_statusCounts),
                    ),
                    const Divider(height: 1),
                    // Calendar
                    Expanded(
                      child: SfCalendar(
                  view: CalendarView.timelineDay,
                  dataSource: _CalendarDataSource(appointments),
                  initialDisplayDate: _selectedDate,
                  timeSlotViewSettings: const TimeSlotViewSettings(
                    startHour: 8,
                    endHour: 22,
                    timeInterval: Duration(minutes: 30),
                    timeFormat: 'h:mm a',
                    dateFormat: 'EEE, MMM d',
                  ),
                  todayHighlightColor: Colors.blueAccent,
                  headerHeight: 40,
                  headerStyle: const CalendarHeaderStyle(
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  onTap: (calendarTapDetails) {
                    if (calendarTapDetails.appointments != null && calendarTapDetails.appointments!.isNotEmpty) {
                      final Appointment tappedAppointment = calendarTapDetails.appointments!.first;
                            _showStatusSheet(tappedAppointment);
                    }
                  },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Summary bar at the bottom
          Container(
            color: tertiaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _summaryText('Total: ${_statusCounts.values.fold<int>(0, (p, c) => p + c)}'),
                const SizedBox(width: 12),
                ..._statusOptions.map((s) => _pill(s, _statusCounts[s] ?? 0)).toList(),
                const Spacer(),
                _kpis(_statusCounts, _uniqueGuests, _totalRevenue),
              ],
            ),
          ),
        ],
      ),
      // Removed FAB per request
    );
  }

  // Legacy inline booking dialog removed; FAB opens full AddNewBooking dialog

  // Legacy save function removed in favor of AddNewBooking screen

  // Bottom sheet with quick status actions
  void _showStatusSheet(Appointment appt) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
              const SizedBox(height: 8),
              Text(appt.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              ..._statusOptions.map((s) => ListTile(
                    leading: Icon(Icons.circle, color: _statusColor(s), size: 14),
                    title: Text(s),
                    onTap: () async {
                      // naive update by matching name + start time
                      final q = await FirebaseFirestore.instance
                          .collection('bookings')
                          .where('userName', isEqualTo: appt.subject)
                          .where('start', isEqualTo: appt.startTime)
                          .limit(1)
                          .get();
                      if (q.docs.isNotEmpty) {
                        await q.docs.first.reference.update({'status': s});
                      }
                      if (mounted) Navigator.pop(context);
                    },
                  )),
                    const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryText(String text) => Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Text(text, style: const TextStyle(fontSize: 13)),
      );

  // Color per status (to also tint appointments)
  Color _statusColor(String status) {
    switch (status) {
      case 'Serviced':
        return Colors.green.shade400;
      case 'In-progress':
        return lightGrey;
      case 'Open & confirmed':
        return primaryColor;
      case 'Cancelled':
        return Colors.pink.shade300;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _pill(String label, int count) {
    final color = _statusColor(label);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color.darken(), fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(count.toString(), style: TextStyle(color: color.darken())),
        ],
      ),
    );
  }

  // Zenoti-like bar card (custom lightweight implementation)
  Widget _buildStatusBarCard(Map<String, int> counts) {
    final total = counts.values.fold<int>(0, (p, c) => p + c);
    final maxVal = (counts.values.isEmpty ? 1 : counts.values.reduce((a,b)=>a>b?a:b));
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 160,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final chartHeight = constraints.maxHeight - 30; // bottom labels area
                    return Column(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _statusOptions.map((s) {
                              final v = counts[s] ?? 0;
                              final h = maxVal == 0 ? 0.0 : (v / maxVal) * chartHeight;
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  height: h,
                                  decoration: BoxDecoration(
                                    color: _statusColor(s),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: _statusOptions.map((s) => Expanded(
                            child: Text(
                              s.split(' ').first,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                          )).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: $total', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._statusOptions.map((s) => Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: _statusColor(s), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    SizedBox(width: 110, child: Text(s)),
                    const SizedBox(width: 8),
                    Text((counts[s] ?? 0).toString()),
                  ],
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Bar chart + KPI widget row
  Widget _kpis(Map<String, int> counts, int uniqueGuests, num totalRevenue) {
    final total = counts.values.fold<int>(0, (p, c) => p + c);
    return Row(children: [
      // Fallback mini “bar” view without fl_chart
      SizedBox(
        width: 220,
        height: 100,
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _statusOptions.map((s) {
                  final c = counts[s] ?? 0;
                  final max = (counts.values.isEmpty ? 1 : counts.values.reduce((a, b) => a > b ? a : b));
                  final h = max == 0 ? 0.0 : (c / max) * 90;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: h,
                      color: _statusColor(s),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _statusOptions.map((s) => Container(width: 6, height: 6, color: _statusColor(s))).toList(),
            )
          ],
        ),
      ),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('Appointments: $total'),
        Text('Unique Guests: $uniqueGuests'),
        Text('Revenue: Rs ${totalRevenue.toStringAsFixed(0)}'),
      ]),
    ]);
  }

}

class _CalendarDataSource extends CalendarDataSource {
  _CalendarDataSource(List<Appointment> source) {
    appointments = source;
  }
} 