import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/flask_service.dart';
import '../models/sensor_data.dart';
import '../widgets/status_card.dart';
import 'grafik_screen.dart';
import 'history_sensor_screen.dart';
import 'history_prediksi_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final firebaseService = FirebaseService();
  final flaskService = FlaskService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          const GrafikScreen(),
          const HistorySensorScreen(),
          const HistoryPrediksiScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: const Color.fromARGB(173, 184, 248, 165),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Grafik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History Sensor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'History Prediksi',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return StreamBuilder<SensorData?>(
      stream: firebaseService.getSensorDataStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}", textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Mengambil data sensor..."),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sensors_off, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text("Tidak ada data sensor"),
              ],
            ),
          );
        }

        final data = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Dashboard Monitoring"),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Trigger rebuild
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        title: "Level Air",
                        value: data.levelAir.toStringAsFixed(1),
                        unit: "cm",
                        isWarning: data.levelAir < 10,
                      ),
                      StatusCard(
                        title: "Suhu",
                        value: data.suhu.toStringAsFixed(1),
                        unit: "°C",
                        isWarning: data.suhu < 20 || data.suhu > 32,
                      ),
                      StatusCard(
                        title: "Kecepatan Angin",
                        value: data.angin.toStringAsFixed(1),
                        unit: "m/s",
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final result = await flaskService.predict(data);
                        if (!mounted) return;

                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("Hasil Prediksi"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Efisiensi: ${result.efisiensi}"),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Durasi Irigasi: ${result.durasiIrigasi} menit",
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Tutup"),
                                  ),
                                ],
                              ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.analytics),
                    label: const Text("Prediksi Irigasi"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
