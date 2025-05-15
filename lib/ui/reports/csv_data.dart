import 'package:aesthetics_labs_admin/models/booking_service.dart';
import 'package:aesthetics_labs_admin/styles/styles.dart';
import 'package:aesthetics_labs_admin/ui/general_widgets/base_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsData extends StatelessWidget {
  final List<BookingService> bookings;

  const ReportsData({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final totalRevenue = bookings.fold(0, (sum, booking) => sum + (booking.servicePrice ?? 0));
    final serviceCount = <String, int>{};

    for (var booking in bookings) {
      serviceCount[booking.serviceName] = (serviceCount[booking.serviceName] ?? 0) + 1;
    }

    final topServices = (serviceCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(5).toList();

    return BaseLayout(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Reports'),
          backgroundColor: primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTopServicesCard(topServices),
                  const SizedBox(width: 16),
                  _buildSummaryCard(totalRevenue, bookings.length),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildBookingsList(bookings)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int totalRevenue, int totalBookings) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: SizedBox(
        height: 280,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Revenue: Rs ${NumberFormat('#,##0').format(totalRevenue)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Total Bookings: $totalBookings', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopServicesCard(List<MapEntry<String, int>> topServices) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: SizedBox(
        height: 280,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Top 5 Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (var entry in topServices)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('${entry.key}: ${entry.value} bookings', style: const TextStyle(fontSize: 16)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<BookingService> bookings) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Bookings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  // final booking = bookings[index];
                  // return ListTile(
                  //   title: Text(booking.serviceName),
                  //   leading: Text('Client Name: ${booking.userName}'),
                  //   subtitle: Text('${DateFormat.yMMMd().add_jm().format(booking.bookingStart)} - ${DateFormat.yMMMd().add_jm().format(booking.bookingEnd)}'),
                  //   trailing: Text('\$${NumberFormat('#,##0').format(booking.servicePrice ?? 0)}'),
                  // );
                  return _bookingTile(bookings[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // bookingTile
  Widget _bookingTile(BookingService booking) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor),
          borderRadius: BorderRadius.circular(10),
          // color: primaryColor,
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client Name: ${booking.userName}'),
            Text(booking.serviceName),
            Text('${booking.bookingStart} - ${booking.bookingEnd}, (Room ID: ${booking.roomId})'),
            // service price
            Text('Service Price: ${booking.servicePrice}'),
            // service duration
            Text('Service Duration: ${booking.serviceDuration}'),
            // status
            const Text('Status: Closed'),
          ],
        ));
  }
}
