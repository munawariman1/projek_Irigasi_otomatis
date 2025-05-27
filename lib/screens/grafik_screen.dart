import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/sensor_data.dart';
import '../widgets/sensor_chart.dart';

class GrafikScreen extends StatelessWidget {
  const GrafikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafik Sensor'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<SensorData?>(
        stream: FirebaseService().getSensorDataStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat data"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Data tidak tersedia"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SensorChart(sensorName: "pH Tanah", values: data.phHistory),
                SensorChart(
                  sensorName: "Kelembapan Tanah",
                  values: data.kelembapanHistory,
                ),
                SensorChart(sensorName: "Suhu Tanah", values: data.suhuHistory),
                SensorChart(
                  sensorName: "Curah Hujan",
                  values: data.curahHujanHistory,
                ),
                SensorChart(
                  sensorName: "Level Air",
                  values: data.levelAirHistory,
                ),
                SensorChart(
                  sensorName: "Kecepatan Angin",
                  values: data.anginHistory,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
