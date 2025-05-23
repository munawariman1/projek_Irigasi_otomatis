import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/firebase_service.dart';
import '../widgets/status_card.dart';
import '../widgets/sensor_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Irigasi Otomatis'),
        backgroundColor: Colors.green.shade700,
      ),
      body: StreamBuilder<SensorData?>(
        stream: firebaseService.getSensorDataStream(),
        builder: (context, snapshot) {
          print(
            "📡 Firebase snapshot: ${snapshot.connectionState} | hasData: ${snapshot.hasData}",
          );
          if (snapshot.hasError) {
            print("❌ Stream error: ${snapshot.error}");
            return const Center(child: Text("Gagal memuat data"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Data tidak tersedia"));
          }

          final data = snapshot.data!;
          // lanjut tampilkan StatusCard dan SensorChart seperti sebelumnya

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    StatusCard(
                      title: "pH Tanah",
                      value: data.ph.toStringAsFixed(1),
                      unit: "",
                      isWarning: data.ph < 5.5 || data.ph > 7.5,
                    ),

                    StatusCard(
                      title: "Kelembapan",
                      value: data.moisture.toStringAsFixed(1),
                      unit: "%",
                      isWarning: data.moisture < 30,
                    ),

                    StatusCard(
                      title: "Curah Hujan",
                      value: data.rainfall.toStringAsFixed(1),
                      unit: "mm",
                    ),
                    StatusCard(
                      title: "Suhu Tanah",
                      value: data.temperature.toStringAsFixed(1),
                      unit: "°C",
                    ),
                    StatusCard(
                      title: "Level Air",
                      value: "${data.waterLevel.toStringAsFixed(1)}%",
                      unit: "",
                      isWarning: data.waterLevel < 20,
                    ),
                    StatusCard(
                      title: "Kecepatan Angin",
                      value: data.windSpeed.toStringAsFixed(1),
                      unit: "m/s",
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SensorChart(sensorName: "pH Tanah", values: data.phHistory),
                SensorChart(
                  sensorName: "Kelembapan",
                  values: data.moistureHistory,
                ),
                SensorChart(
                  sensorName: "Curah Hujan",
                  values: data.rainfallHistory,
                ),
                SensorChart(
                  sensorName: "Suhu Tanah",
                  values: data.temperatureHistory,
                ),
                SensorChart(
                  sensorName: "Level Air",
                  values: data.waterLevelHistory,
                ),
                SensorChart(
                  sensorName: "Kecepatan Angin",
                  values: data.windSpeedHistory,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
