import 'package:flutter/material.dart';
import '../models/sensor_data.dart';

class AlertBadge extends StatelessWidget {
  final SensorData data;
  final VoidCallback onTap;

  const AlertBadge({super.key, required this.data, required this.onTap});

  List<String> _getAbnormalSensors() {
    final List<String> abnormalSensors = [];
    if (data.ph < 6.0 || data.ph > 7.0) {
      abnormalSensors.add('pH Tanah');
    }
    if (data.kelembapan < 60 || data.kelembapan > 80) {
      abnormalSensors.add('Kelembapan');
    }
    if (data.suhu < 25 || data.suhu > 35) {
      abnormalSensors.add('Suhu');
    }
    if (data.curahHujan > 50) {
      abnormalSensors.add('Curah Hujan');
    }
    if (data.levelAir < 10) {
      abnormalSensors.add('Level Air');
    }
    if (data.angin > 30) {
      abnormalSensors.add('Kecepatan Angin');
    }

    return abnormalSensors;
  }

  @override
  Widget build(BuildContext context) {
    final abnormalSensors = _getAbnormalSensors();
    final badgeColor = abnormalSensors.isNotEmpty
        ? Colors.red
        : Colors.grey; // Merah jika ada abnormal, abu-abu jika tidak

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.black),
          onPressed: onTap,
          tooltip: abnormalSensors.isNotEmpty
              ? '${abnormalSensors.length} sensor tidak normal'
              : 'Semua sensor normal',
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: badgeColor,
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
