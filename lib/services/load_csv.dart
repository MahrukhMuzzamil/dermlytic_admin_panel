import 'package:aesthetics_labs_admin/models/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<List<List<dynamic>>> loadCsv(String path) async {
  try {
    final csvString = await rootBundle.loadString(path);
    final csvList = const CsvToListConverter().convert(csvString);
    // print('Loaded CSV from $path , data\n $csvList');
    return csvList;
  } catch (e) {
    print('Error loading CSV from $path: $e');
    return [];
  }
}

Future<List<BookingService>> processCsvData() async {
  final salesData = await loadCsv('assets/sales_data.csv');
  final appointmentData = await loadCsv('assets/appointment_data.csv');

  if (salesData.isEmpty || appointmentData.isEmpty) {
    print('One or more CSV files are empty.');
    return [];
  }

  final salesHeaders = salesData.first;
  final appointmentHeaders = appointmentData.first;

  List<BookingService> bookings = [];
  Map<String, int> roomCounter = {};

  DateFormat dateFormat = DateFormat('MM/dd/yyyy hh:mm a');

  for (var i = 1; i < salesData.length; i++) {
    var row = salesData[i];

    var invoiceNoIndex = salesHeaders.indexOf('Invoice No');
    var serviceNameIndex = salesHeaders.indexOf('Item Name');
    var collectedIndex = salesHeaders.indexOf('Collected');
    var redeemedIndex = salesHeaders.indexOf('Redeemed');

    if (row.length <= invoiceNoIndex || row.length <= serviceNameIndex || row.length <= collectedIndex || row.length <= redeemedIndex) {
      print('Skipping row due to incorrect format: $row');
      continue;
    }

    var invoiceNo = row[invoiceNoIndex];
    if (invoiceNo == null) {
      print('Skipping row due to null invoice number: $row');
      continue;
    }

    var serviceName = row[serviceNameIndex];
    var servicePriceCollected = row[collectedIndex];
    var servicePriceRedeemed = row[redeemedIndex];
    var servicePrice = servicePriceCollected ?? servicePriceRedeemed;

    if (servicePrice == null) {
      print('Skipping row due to null service price: $row');
      continue;
    }

    var appointmentRow = appointmentData.firstWhere(
      (appointment) => appointment[appointmentHeaders.indexOf('Invoice No')] == invoiceNo,
      orElse: () => [],
    );

    if (appointmentRow.isEmpty) {
      // print('No appointment found for Invoice No: $invoiceNo');
      continue;
    }

    var bookingStartStr = appointmentRow[appointmentHeaders.indexOf('Start Time')];
    var bookingEndStr = appointmentRow[appointmentHeaders.indexOf('End Time')];
    DateTime bookingStart;
    DateTime bookingEnd;

    try {
      bookingStart = dateFormat.parse(bookingStartStr);
      bookingEnd = dateFormat.parse(bookingEndStr);
    } catch (e) {
      print('Error parsing dates for row: $row');
      continue;
    }

    var clientName = appointmentRow[appointmentHeaders.indexOf('Client Name')];

    // Handle room ID increment for same time slots
    String timeSlotKey = '${bookingStart.toIso8601String()}-${bookingEnd.toIso8601String()}';
    if (!roomCounter.containsKey(timeSlotKey)) {
      roomCounter[timeSlotKey] = 1;
    } else {
      roomCounter[timeSlotKey] = roomCounter[timeSlotKey]! + 1;
    }
    // print("price ${servicePrice}, ${double.tryParse(servicePrice)?.toInt()}");
    int price = double.tryParse(servicePrice)?.toInt() ?? 0;
    if (price == 0) {
      continue;
    }
    // need to check if 6 bookings are done for same day ignore that
    // List<BookingService> bookings = [];
    // for current booking start check day, lets say 24 april 2024, if there are already 5 bookings in bookings list for 24, april 2024 ignore that entry
    int count = 0;
    for (var booking in bookings) {
      if (booking.bookingStart.day == bookingStart.day) {
        count++;
      }
    }
    if (count >= 9) {
      continue;
    }

    // if date is less than arpil 1, 2024 ignore that
    if (bookingStart.isBefore(DateTime(2024, 4, 1))) {
      continue;
    }
    // if roomCounter[timeSlotKey].toString() is greater than 4 ignore that
    if (roomCounter[timeSlotKey]! > 4) {
      continue;
    }

    bookings.add(BookingService(
      userId: null,
      userName: clientName,
      userEmail: null,
      userPhoneNumber: null,
      serviceId: null,
      serviceName: serviceName,
      serviceDuration: bookingEnd.difference(bookingStart).inMinutes,
      servicePrice: double.tryParse(servicePrice)?.toInt(),
      bookingStart: bookingStart,
      bookingEnd: bookingEnd,
      roomId: roomCounter[timeSlotKey].toString(),
      status: 'Pending', // Adjust status as needed
    ));
  }

  return bookings;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bookings = await processCsvData();
  runApp(MyApp(bookings: bookings));
}

class MyApp extends StatelessWidget {
  final List<BookingService> bookings;

  const MyApp({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Bookings')),
        body: ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return ListTile(
              title: Text(booking.serviceName),
              subtitle: Text('${booking.bookingStart} - ${booking.bookingEnd} (Room ID: ${booking.roomId})'),
            );
          },
        ),
      ),
    );
  }
}
