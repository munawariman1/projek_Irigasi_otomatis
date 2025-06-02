import 'package:flutter/material.dart';
import '../models/sensor_data.dart';

class AlertBadge extends StatelessWidget {
  final SensorData data;
  final VoidCallback onTap;

  const AlertBadge({super.key, required this.data, required this.onTap});

  List<String> _getAbnormalSensors() {
    final List<String> abnormalSensors = [];

    if (data.ph < 5.5 || data.ph > 7.5) {
      abnormalSensors.add('pH Tanah');
    }
    if (data.kelembapan < 30) {
      abnormalSensors.add('Kelembapan');
    }
    if (data.suhu < 20 || data.suhu > 32) {
      abnormalSensors.add('Suhu');
    }
    if (data.levelAir < 10) {
      abnormalSensors.add('Level Air');
    }
    if (data.angin >= 5) {
      abnormalSensors.add('Kecepatan Angin');
    }

    return abnormalSensors;
  }

  @override
  Widget build(BuildContext context) {
    final abnormalSensors = _getAbnormalSensors();

    if (abnormalSensors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_active),
          onPressed: onTap,
          tooltip: '${abnormalSensors.length} sensor tidak normal',
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              '${abnormalSensors.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
