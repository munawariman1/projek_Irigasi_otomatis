// Halaman HomeScreen dengan status kondisi tanaman dan waktu terakhir diperbarui
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projek_irigasi_otomatis/screens/login_screen.dart';
import 'package:projek_irigasi_otomatis/widgets/manual_control_page.dart';
import '../services/firebase_service.dart';
import '../models/sensor_data.dart';
import '../widgets/status_card.dart';
import '../widgets/alert_badge.dart';
import '../widgets/alert_dialog.dart';
import 'grafik_screen.dart';
import 'history_prediksi_screen.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final firebaseService = FirebaseService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut(); // Hapus sesi Google
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  Future<Map<String, dynamic>> getLastPrediction() async {
  final snapshot = await FirebaseDatabase.instance.ref('historyPrediksi').get();
  if (snapshot.exists) {
    final Map data = snapshot.value as Map;
    final last = data.entries.toList()
      ..sort((a, b) => b.value['timestamp'].compareTo(a.value['timestamp']));
    final latest = last.first.value as Map;
    return {
      'kondisi': latest['kondisi'] ?? 'Tidak Tersedia',
      'air_ml': latest['kebutuhan_air_ml'] ?? 0
    };
  }
  return {'kondisi': 'Tidak Tersedia', 'air_ml': 0};
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          const GrafikScreen(),
          const HistoryPrediksiScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: const Color.fromARGB(255, 0, 59, 3),
        unselectedItemColor: const Color.fromARGB(255, 27, 104, 3),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Grafik',
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
        final timestamp = DateFormat(
          'dd MMM yyyy HH:mm',
        ).format(data.timestamp);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Dashboard Monitoring"),
            backgroundColor: const Color.fromARGB(255, 35, 141, 3),
            foregroundColor: Colors.black87,
            actions: [
              AlertBadge(
                data: data,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => SensorAlertDialog(data: data),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                 Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 242, 255, 238),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: getLastPrediction(),
                        builder: (context, snapshot) {
                          final dataPrediksi = snapshot.data;
                          final kondisi = dataPrediksi?['kondisi'] ?? 'Tidak Tersedia';
                          final airML = dataPrediksi?['air_ml'] ?? 0;
                          final airLiter = (airML / 1000).toStringAsFixed(2);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kondisi Tanaman: $kondisi",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Kebutuhan air: $airML mL ($airLiter liter)",
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Terakhir diperbarui: $timestamp",
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),


                  // Mode Manual Switch Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(215, 255, 255, 255),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color.fromARGB(
                          255,
                          23,
                          167,
                          4,
                        ).withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.settings,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Mode Manual',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: false,
                              onChanged: (bool value) {
                                // TODO: Implement mode manual logic
                                Navigator.pushNamed(context, '/manualControl');
                              },
                              activeColor: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aktifkan mode pompa manual',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sensor Cards
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                        isWarning: data.kelembapan < 45 || data.kelembapan > 85,
                      ),
                      StatusCard(
                        title: "Curah Hujan",
                        value: data.curahHujan.toStringAsFixed(1),
                        unit: "mm",
                      ),
                      StatusCard(
                        title: "Air",
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
                        title: "Angin",
                        value: data.angin.toStringAsFixed(1),
                        unit: "m/s",
                        isWarning: data.angin >= 50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
