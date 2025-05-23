import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final bool isWarning;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isWarning ? Colors.red.shade100 : Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 20,
                color: isWarning ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
