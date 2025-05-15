// import 'package:aesthetics_labs_admin/ui/general_widgets/base_layout.dart';
// import 'package:aesthetics_labs_admin/ui/general_widgets/custom_app_bar.dart';
// import 'package:booking_calendar/booking_calendar.dart';
// import 'package:flutter/material.dart';

// class BookingCalendarView extends StatelessWidget {
//   const BookingCalendarView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: customAppBar(
//         titleText: "Bookings Calendar",
//       ),
//       body: BaseLayout(
//           child: Column(
//         children: [CalendarView()],
//       )),
//     );
//   }
// }

// class CalendarView extends StatefulWidget {
//   CalendarView({super.key});
//   @override
//   State<CalendarView> createState() => _CalendarViewState();
// }

// class _CalendarViewState extends State<CalendarView> {
//   final startTime = const TimeOfDay(hour: 9, minute: 0);
//   // Start time
//   final endTime = const TimeOfDay(hour: 21, minute: 0);
//   // End time
//   final interval = 30;
//   TimeOfDay _addInterval(TimeOfDay time) {
//     final newMinute = time.minute + interval;
//     final hour = time.hour + newMinute ~/ 60;
//     final minute = newMinute % 60;
//     return TimeOfDay(hour: hour, minute: minute);
//   }

//   // Interval in minutesminute == null || (minute >= 0 && minute < minutesPerHour
//   List<TimeOfDay> _getTimeSlots() {
//     List<TimeOfDay> timeSlots = [];
//     for (var i = startTime; i.hour < endTime.hour || (i.hour == endTime.hour && i.minute < endTime.minute); i = _addInterval(i)) {
//       timeSlots.add(i);
//     }
//     return timeSlots;
//   }

//   late List<TimeOfDay> timeSlots = _getTimeSlots();

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print(timeSlots);
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         color: Colors.red,
//         width: timeSlots.length * 300,
//         padding: EdgeInsets.all(8.0),
//         child: SingleChildScrollView(
//           child: Table(
//             border: TableBorder.all(),
//             columnWidths: {
//               for (var i = 0; i < timeSlots.length; i++) i: const FlexColumnWidth(1), // Flex to occupy equal space
//             },
//             children: [
//               TableRow(
//                 children: [
//                   TableCell(
//                     child: Container(
//                       padding: const EdgeInsets.all(8.0),
//                       child: const Text('Time'),
//                     ),
//                   ),
//                   for (var timeSlot in timeSlots)
//                     TableCell(
//                       child: Container(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text('${timeSlot.hour}:${timeSlot.minute.toString().padLeft(2, '0')}'),
//                       ),
//                     ),
//                 ],
//               ),
//               // Add more TableRow widgets for additional rows of appointments
//               TableRow(
//                 children: [
//                   TableCell(
//                     child: Container(
//                       padding: const EdgeInsets.all(8.0),
//                       child: const Text('Row 1'), // Row 1 Label
//                     ),
//                   ),
//                   for (var _ in timeSlots)
//                     TableCell(
//                       child: Container(
//                         padding: const EdgeInsets.all(8.0),
//                         child: const AppointmentSlot(), // Appointment Slot Widget
//                       ),
//                     ),
//                 ],
//               ),
//               // Add more TableRow widgets for additional rows of appointments
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class AppointmentSlot extends StatelessWidget {
//   const AppointmentSlot({super.key, this.bookingData});
//   final BookingService? bookingData;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 50, // Adjust the height as
//       width: 100,
//       color: Colors.grey[300], // Color for the appointment slot
//       child: Center(
//         child: Text(bookingData?.serviceName ?? ""), // Placeholder for appointment details
//       ),
//     );
//   }
// }
