import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/flask_service.dart';
import '../models/sensor_data.dart';
import '../widgets/status_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final flaskService = FlaskService();

    return Scaffold(
      appBar: AppBar(title: const Text("Monitoring & Prediksi Irigasi")),
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

          return Column(
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
                    value: data.kelembapan.toStringAsFixed(1),
                    unit: "%",
                    isWarning: data.kelembapan < 30,
                  ),
                  StatusCard(
                    title: "Curah Hujan",
                    value: data.curahHujan.toStringAsFixed(1),
                    unit: "mm",
                  ),
                  StatusCard(
                    title: "Suhu Tanah",
                    value: data.suhu.toStringAsFixed(1),
                    unit: "°C",
                  ),
                  StatusCard(
                    title: "Level Air",
                    value: "${data.levelAir.toStringAsFixed(1)}%",
                    unit: "",
                    isWarning: data.levelAir < 20,
                  ),
                  StatusCard(
                    title: "Kecepatan Angin",
                    value: data.angin.toStringAsFixed(1),
                    unit: "m/s",
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await flaskService.predictEfisiensi(data);
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: const Text("Hasil Prediksi"),
                            content: Text(
                              "Efisiensi: ${result['efisiensiAir']}\n"
                              "Waktu Penyiraman: ${result['irigasiWaktu']} detik",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ Gagal prediksi: $e")),
                    );
                  }
                },
                child: const Text("🔍 Prediksi Efisiensi Air"),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed:
                        () => Navigator.pushNamed(context, '/history_sensor'),
                    child: const Text("📜 History Sensor"),
                  ),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.pushNamed(context, '/history_prediksi'),
                    child: const Text("📊 History Prediksi"),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
