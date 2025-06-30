import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sensor_data.dart';

class SensorAlertDialog extends StatelessWidget {
  final SensorData data;

  const SensorAlertDialog({super.key, required this.data});

  List<Map<String, dynamic>> _getAbnormalSensors() {
    final List<Map<String, dynamic>> abnormalSensors = [];
    final formatter = DateFormat('HH:mm:ss dd-MM-yyyy');
    final timestamp = formatter.format(data.timestamp);
    if (data.ph < 6.0 || data.ph > 7.0) {
      abnormalSensors.add({
        'name': 'pH Tanah',
        'value': data.ph.toStringAsFixed(1),
        'unit': '',
        'message': data.ph < 6.0 ? 'Terlalu asam' : 'Terlalu basa',
        'time': timestamp,
      });
    }
    if (data.kelembapan < 60 || data.kelembapan > 80) {
      abnormalSensors.add({
        'name': 'Kelembapan',
        'value': data.kelembapan.toStringAsFixed(1),
        'unit': '%',
        'message': data.kelembapan < 60 ? 'Terlalu kering' : 'Terlalu lembab',
        'time': timestamp,
      });
    }
    if (data.suhu < 25 || data.suhu > 35) {
      abnormalSensors.add({
        'name': 'Suhu',
        'value': data.suhu.toStringAsFixed(1),
        'unit': '°C',
        'message': data.suhu < 25 ? 'Terlalu dingin' : 'Terlalu panas',
        'time': timestamp,
      });
    }
    if (data.curahHujan > 50) {
      abnormalSensors.add({
        'name': 'Curah Hujan',
        'value': data.curahHujan.toStringAsFixed(1),
        'unit': 'mm',
        'message': 'Curah hujan tinggi',
        'time': timestamp,
      });
    }
    if (data.levelAir < 10) {
      abnormalSensors.add({
        'name': 'Level Air',
        'value': data.levelAir.toStringAsFixed(1),
        'unit': 'cm',
        'message': 'Level air rendah',
        'time': timestamp,
      });
    }
    if (data.angin > 30) {
      abnormalSensors.add({
        'name': 'Angin',
        'value': data.angin.toStringAsFixed(1),
        'unit': 'm/s',
        'message': 'Kecepatan angin tinggi',
        'time': timestamp,
      });
    }

    return abnormalSensors;
  }

  @override
  Widget build(BuildContext context) {
    final abnormalSensors = _getAbnormalSensors();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Peringatan Sensor',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...abnormalSensors.map((sensor) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sensor['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          sensor['time'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${sensor['value']}${sensor['unit']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${sensor['message']})',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
