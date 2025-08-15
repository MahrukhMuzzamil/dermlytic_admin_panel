import 'package:aesthetics_labs_admin/controllers/branch_controller.dart';
import 'package:aesthetics_labs_admin/models/branch_model.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/base_layout.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_app_bar.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_filled_button.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/booking_service.dart';

class ViewBookings extends StatefulWidget {
  const ViewBookings({super.key, this.isLatest});
  final bool? isLatest;

  @override
  State<ViewBookings> createState() => _ViewBookingsState();
}

class _ViewBookingsState extends State<ViewBookings> {
  CollectionReference bookings = FirebaseFirestore.instance.collection('bookings');
  late BranchModel selectedBranch;
  BranchController branchController = Get.find(tag: "branchController");
  DateTime? selectedDate; // Store the selected date
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  @override
  void initState() {
    super.initState();
    selectedBranch = branchController.branches[0];
    selectedDate = DateTime.now(); // Initialize selectedDate with current date
  }

  CollectionReference<BookingService> getBookingStream() {
    return bookings.doc(selectedBranch.branchId).collection('bookings').withConverter<BookingService>(
          fromFirestore: (snapshots, _) => BookingService.fromJson(snapshots.data()!, documentId: snapshots.id),
          toFirestore: (snapshots, _) => snapshots.toJson(),
        );
  }

  getBookingStreamFirebase() {
    if (phoneController.text.isNotEmpty) {
      print("phone number not empty");
      return getBookingStream()
          .where('userId', isEqualTo: phoneController.text)
          .where('bookingStart', isGreaterThanOrEqualTo: _startOfDay(selectedDate!).toIso8601String()) // Filter by start of selected date
          .where('bookingStart', isLessThanOrEqualTo: _endOfDay(selectedDate!).toIso8601String()) // Filter by end of selected date
          .snapshots();
    }
    return getBookingStream()
        .where('bookingStart', isGreaterThanOrEqualTo: _startOfDay(selectedDate!).toIso8601String()) // Filter by start of selected date
        .where('bookingStart', isLessThanOrEqualTo: _endOfDay(selectedDate!).toIso8601String()) // Filter by end of selected date
        .snapshots();
  }

  // update value of booking Service in firebase based on the id
  Future<void> updateBookingService(BookingService bookingService) {
    return bookings.doc(selectedBranch.branchId).collection('bookings').doc(bookingService.serviceId).set(bookingService.toJson());
  }

  void _filterData() {
    setState(() {
      // This will trigger a rebuild and apply the current filters
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(titleText: widget.isLatest == true ? "Upcoming Bookings" : "Appointment History", leading: widget.isLatest == true ? const SizedBox() : null),
      body: BaseLayout(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // DatePicker to select date
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: 250,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomTextField(
                              controller: phoneController,
                              title: "Phone",
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _selectDate(context);
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              selectedDate != null 
                                ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                : "Select Date"
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              labelText: "Select Branch",
                              prefixIcon: const Icon(Icons.pin_drop_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            value: selectedBranch,
                            items: branchController.branches.map((branch) {
                              return DropdownMenuItem(
                                value: branch,
                                child: Text(
                                  branch.branchName.toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (BranchModel? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedBranch = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: CustomFilledButton(
                            title: "Apply",
                            onPress: () {
                              _filterData();
                            },
                            width: 120,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              StreamBuilder(
                stream: getBookingStreamFirebase(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No data available.');
                  } else {
                    return buildCalendarView(snapshot.data!.docs); // Render the calendar view
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  final interval = 30;

  Widget buildCalendarView(List<DocumentSnapshot> docs) {
    // Generate time slots
    const startTime = TimeOfDay(hour: 12, minute: 0);
    const endTime = TimeOfDay(hour: 22, minute: 0);
    List<TimeOfDay> timeSlots = [];
    for (var i = startTime; i.hour < endTime.hour || (i.hour == endTime.hour && i.minute < endTime.minute); i = _addInterval(i, interval)) {
      timeSlots.add(i);
    }

    Map<String, List<BookingService>> roomBookings = {};
    for (var doc in docs) {
      // print(doc.data());
      BookingService booking;
      var bookingData = doc.data();
      if (bookingData != null) {
        booking = bookingData as BookingService;
        if (roomBookings.containsKey(booking.roomId)) {
          roomBookings[booking.roomId]!.add(booking);
        } else {
          roomBookings[booking.roomId] = [booking];
        }
      } else {
        // Handle the case where bookingData is null
      }
    }
    // print("booking length ${roomBookings["1"]!.length},  roomBookings: $roomBookings");

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Total Appointments: ${docs.length}', 
            style: const TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Colors.blue
            )
          ),
        ),
        Container(
          height: 400, // Fixed height to prevent overflow
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch}),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                color: primaryColor.withOpacity(.1),
                padding: const EdgeInsets.all(20.0),
                width: timeSlots.length * 100.0,
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(),
                    columnWidths: {for (var i = 0; i < timeSlots.length; i++) i: const FlexColumnWidth(1)},
                    children: [
                      TableRow(
                        children: [TableCell(child: Container(padding: const EdgeInsets.all(8.0), child: const Text('Room/Time')))] +
                            timeSlots.map((ts) => TableCell(child: Container(padding: const EdgeInsets.all(8.0), child: Text(ts.format(context))))).toList(),
                      ),
                      ...roomBookings.entries.map((entry) => buildAppointmentRow(entry.key, entry.value, timeSlots)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow buildAppointmentRow(String roomId, List<BookingService> bookings, List<TimeOfDay> timeSlots) {
    return TableRow(
      children: [
        TableCell(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(roomId),
          ),
        ),
        for (var timeSlot in timeSlots)
          TableCell(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: findBookingForTimeSlot(bookings, timeSlot),
            ),
          ),
      ],
    );
  }

  // Widget findBookingForTimeSlot(List<BookingService> bookings, TimeOfDay timeSlot) {
  //   for (var booking in bookings) {
  //     if (timeSlot.hour == booking.bookingStart.hour && timeSlot.minute == booking.bookingStart.minute) {
  //       return AppointmentSlot(bookingData: booking, selectedBranch: selectedBranch);
  //     }
  //   }
  //   return SizedBox(); // Return empty widget if no booking matches the time slot
  // }

  Widget findBookingForTimeSlot(List<BookingService> bookings, TimeOfDay timeSlot) {
    for (var booking in bookings) {
      print("booking: $booking, timeSlot: $timeSlot");
      if (timeSlot.hour == booking.bookingStart.hour && timeSlot.minute == booking.bookingStart.minute) {
        return AppointmentSlot(bookingData: booking, selectedBranch: selectedBranch);
      }
    }
    return const SizedBox(); // Return empty widget if no booking matches the time slot
  }

  TimeOfDay _addInterval(TimeOfDay time, int interval) {
    final newMinute = time.minute + interval;
    final hour = time.hour + newMinute ~/ 60;
    final minute = newMinute % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Function to get the start of the selected date
  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0);
  }

  // Function to get the end of the selected date
  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}

Future<void> updateBookingService(BookingService bookingService, BranchModel selectedBranch) {
  print("${bookingService.toJson()}");
  CollectionReference bookings = FirebaseFirestore.instance.collection('bookings');

  return bookings.doc(selectedBranch.branchId).collection('bookings').doc(bookingService.serviceId).set(
        bookingService.toJson(),
        SetOptions(merge: true),
      );
}

class AppointmentSlot extends StatelessWidget {
  const AppointmentSlot({super.key, this.bookingData, this.selectedBranch});
  final BookingService? bookingData;
  final BranchModel? selectedBranch;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // SHow a drop down with options to update the status of the appointment pengind, booked, confirmed, done
        // Show a dialog to update the status of the appointment
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Update Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Service:        ${bookingData?.serviceName}"),
                      Text("UserName:   ${bookingData?.userName}"),
                      Text("Phone:          ${bookingData?.userPhoneNumber}"),
                    ],
                  ),
                  const Divider(),
                  ListTile(
                    tileColor: bookingData?.status == "pending" ? Colors.grey[700] : null,
                    title: const Text(
                      'Pending',
                    ),
                    onTap: () {
                      bookingData!.status = "pending";
                      updateBookingService(bookingData!, selectedBranch!);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    tileColor: bookingData?.status == "booked" ? Colors.grey[700] : null,
                    title: const Text('Booked'),
                    onTap: () {
                      bookingData!.status = "booked";
                      updateBookingService(bookingData!, selectedBranch!);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    tileColor: bookingData?.status == "confirmed" ? Colors.grey[700] : null,
                    title: const Text('Confirmed'),
                    onTap: () {
                      bookingData!.status = "confirmed";
                      updateBookingService(bookingData!, selectedBranch!);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    tileColor: bookingData?.status == "done" ? Colors.grey[700] : null,
                    title: const Text('Done'),
                    onTap: () {
                      bookingData!.status = "done";
                      updateBookingService(bookingData!, selectedBranch!);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        height: 50, // Adjust the height as
        width: 100,
        color: Colors.grey[300], // Color for the appointment slot
        child: Center(
          child: Text(bookingData?.serviceName ?? ""), // Placeholder for appointment details
        ),
      ),
    );
  }
}
