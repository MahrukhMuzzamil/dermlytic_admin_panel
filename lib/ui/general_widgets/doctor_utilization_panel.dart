// doctor_utilization_panel.dart
import 'package:flutter/material.dart';

class DoctorUtilizationPanel extends StatelessWidget {
  final Map<String, double> doctorUtilization;

  const DoctorUtilizationPanel({Key? key, required this.doctorUtilization}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Doctor Utilization', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...doctorUtilization.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key)),
                  Text('${entry.value.toStringAsFixed(1)}%'),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
//card the happening and the column and the next doctor