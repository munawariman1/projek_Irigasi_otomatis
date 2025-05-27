import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/sensor_data.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  List<String> _getAbnormalSensors(SensorData data) {
    final List<String> abnormalSensors = [];

    if (data.ph < 5.5 || data.ph > 7.5) {
      abnormalSensors.add('pH Tanah (${data.ph})');
    }
    if (data.kelembapan < 30) {
      abnormalSensors.add('Kelembapan (${data.kelembapan}%)');
    }
    if (data.suhu < 20 || data.suhu > 32) {
      abnormalSensors.add('Suhu (${data.suhu}°C)');
    }
    if (data.levelAir < 10) {
      abnormalSensors.add('Level Air (${data.levelAir}cm)');
    }

    return abnormalSensors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Sensor'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: StreamBuilder<SensorData?>(
        stream: FirebaseService().getSensorDataStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Tidak ada data sensor'));
          }

          final abnormalSensors = _getAbnormalSensors(snapshot.data!);

          if (abnormalSensors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Semua sensor dalam kondisi normal',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: abnormalSensors.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Peringatan!',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Sensor ${abnormalSensors[index]} dalam kondisi tidak normal',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
