import 'package:flutter/material.dart';
import 'dart:ui';
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
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
      ),
    );
  }

  Widget _buildDashboard() {
    return StreamBuilder<SensorData?>(
      stream: firebaseService.getSensorDataStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Mengambil data sensor...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("Data tidak tersedia"));
        }

        final data = snapshot.data!;
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 80,
                    toolbarHeight: 60,
                    floating: true,
                    pinned: true,
                    stretch: true,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.95),
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 45,
                        height: 45,
                        fit: BoxFit.contain,
                      ),
                    ),
                    title: Row(
                      children: const [
                        SizedBox(width: 8),
                        Text(
                          "Irigasi Pintar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.85),
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.95),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      StreamBuilder<SensorData?>(
                        stream: firebaseService.getSensorDataStream(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const SizedBox.shrink();
                          }

                          final data = snapshot.data!;
                          final hasAbnormalReadings =
                              data.ph < 5.5 ||
                              data.ph > 7.5 ||
                              data.kelembapan < 30 ||
                              data.suhu < 20 ||
                              data.suhu > 32 ||
                              data.levelAir < 10;

                          if (!hasAbnormalReadings) {
                            return const SizedBox.shrink();
                          }

                          return IconButton(
                            icon: const Icon(
                              Icons.notification_important,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/notifications');
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
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
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Icon(
                                              Icons.analytics,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text("Hasil Prediksi"),
                                          ],
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildPredictionItem(
                                              context,
                                              "Efisiensi",
                                              result.efisiensi,
                                            ),
                                            const SizedBox(height: 12),
                                            _buildPredictionItem(
                                              context,
                                              "Durasi Irigasi",
                                              "${result.durasiIrigasi} menit",
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
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
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.analytics),
                            label: const Text(
                              "Prediksi Irigasi",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPredictionItem(
    BuildContext context,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
