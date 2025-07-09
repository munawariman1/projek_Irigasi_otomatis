import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/history_sensors.dart';
import '../widgets/sensor_chart.dart';

class GrafikScreen extends StatelessWidget {
  const GrafikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyRef = FirebaseDatabase.instance.ref('sensors')
        .limitToLast(12); // Limit to last 24 entries

    return Scaffold(
      appBar: AppBar(
        title: const Text('grafik sensor'),
        backgroundColor: const Color.fromARGB(255, 35, 141, 3),
        foregroundColor: Colors.black87,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: historyRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data grafik...'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.show_chart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada data untuk ditampilkan'),
                ],
              ),
            );
          }
          try {
            final dynamic rawData = snapshot.data!.snapshot.value;
            List<SensorLog> historyList = [];

            if (rawData != null && rawData is Map) {
              final Map<String, dynamic> dataMap = Map<String, dynamic>.from(
                rawData,
              );

              dataMap.forEach((key, value) {
                if (value is Map) {
                  try {
                    // Tambahkan timestamp jika tidak ada
                    if (!value.containsKey('timestamp')) {
                      value['timestamp'] = DateTime.now().toIso8601String();
                    }
                    historyList.add(
                      SensorLog.fromJson(Map<String, dynamic>.from(value)),
                    );
                  } catch (e) {
                    print('Grafik - Error processing entry $key: $e');
                  }
                }
              });
            }

            // Sort by timestamp (oldest to newest)
            historyList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

            // Take only last 24 entries if we have more
            if (historyList.length > 24) {
              historyList = historyList.sublist(historyList.length - 24);
            }

            if (historyList.isEmpty) {
              return const Center(
                child: Text('Belum ada data untuk ditampilkan'),
              );
            }

            // Extract values for each sensor type
            final List<double> phValues = [];
            final List<double> kelembapanValues = [];
            final List<double> suhuValues = [];
            final List<double> curahHujanValues = [];
            final List<double> levelAirValues = [];
            final List<double> anginValues = [];

            for (var sensor in historyList) {
              phValues.add(sensor.ph);
              kelembapanValues.add(sensor.kelembapan);
              suhuValues.add(sensor.suhu);
              curahHujanValues.add(sensor.curahHujan);
              levelAirValues.add(sensor.levelAir);
              anginValues.add(sensor.angin);
            }

            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SensorChart(
                      sensorName: "pH Tanah",
                      values: phValues,
                      timestamps: historyList.map((e) => e.timestamp).toList(),
                    ),
                    SensorChart(
                      sensorName: "Kelembapan",
                      values: kelembapanValues,
                      timestamps: historyList.map((e) => e.timestamp).toList(),
                    ),
                    SensorChart(
                      sensorName: "Suhu",
                      values: suhuValues,
                      timestamps: historyList.map((e) => e.timestamp).toList(),
                    ),
                    SensorChart(
                      sensorName: "Curah Hujan",
                      values: curahHujanValues,
                      timestamps: historyList.map((e) => e.timestamp).toList(),
                    ),
                    SensorChart(
                      sensorName: "Level Air",
                      values: levelAirValues,
                      timestamps: historyList.map((e) => e.timestamp).toList(),
                    ),
                    SensorChart(
                      sensorName: "Kecepatan Angin",
                      values: anginValues,
                      timestamps: historyList.map((e) => e.timestamp).toList(),
                    ),
                  ],
                ),
              ),
            );
          } catch (e) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error memproses data: $e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
