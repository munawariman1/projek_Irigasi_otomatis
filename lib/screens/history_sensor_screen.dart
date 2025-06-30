import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../models/history_sensors.dart';

class HistorySensorScreen extends StatelessWidget {
  const HistorySensorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyRef = FirebaseDatabase.instance.ref('historySensor');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Sensor'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 35, 141, 3),
        foregroundColor: Colors.black87,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: historyRef.limitToLast(100).onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Mengambil data...'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada riwayat data sensor'),
                ],
              ),
            );
          }
          try {
            final dynamic rawData = snapshot.data!.snapshot.value;
            List<HistorySensor> historyList = [];

            print('Raw data from Firebase: $rawData'); // Debug print

            if (rawData != null) {
              if (rawData is Map) {
                // Convert to Map<String, dynamic>
                final Map<String, dynamic> dataMap = Map<String, dynamic>.from(
                  rawData,
                );

                // Proses setiap data sensor
                dataMap.forEach((key, value) {
                  if (value is Map) {
                    try {
                      print('Processing entry: $key -> $value'); // Debug print
                      // Tambahkan timestamp jika tidak ada
                      if (!value.containsKey('timestamp')) {
                        value['timestamp'] = DateTime.now().toIso8601String();
                      }
                      historyList.add(
                        HistorySensor.fromJson(
                          Map<String, dynamic>.from(value),
                        ),
                      );
                    } catch (e) {
                      print('Error processing entry $key: $e');
                    }
                  }
                });
              } else {
                print('Data structure is not a Map: ${rawData.runtimeType}');
              }
            }

            // Sort by timestamp (newest first)
            historyList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

            if (historyList.isEmpty) {
              return const Center(child: Text('Belum ada data sensor'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historyList.length,
                itemBuilder: (context, index) {
                  final history = historyList[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat(
                                      'EEEE',
                                      'id_ID',
                                    ).format(history.timestamp),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    DateFormat(
                                      'dd MMM yyyy HH:mm',
                                      'id_ID',
                                    ).format(history.timestamp),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildSensorRow(
                              context,
                              'pH Tanah',
                              history.ph.toStringAsFixed(1),
                              '',
                              history.ph < 5.5 || history.ph > 7.5,
                            ),
                            _buildSensorRow(
                              context,
                              'Kelembapan',
                              history.kelembapan.toStringAsFixed(1),
                              '%',
                              history.kelembapan < 30,
                            ),
                            _buildSensorRow(
                              context,
                              'Suhu',
                              history.suhu.toStringAsFixed(1),
                              '°C',
                              history.suhu < 20 || history.suhu > 32,
                            ),
                            _buildSensorRow(
                              context,
                              'Curah Hujan',
                              history.curahHujan.toStringAsFixed(1),
                              'mm',
                              false,
                            ),
                            _buildSensorRow(
                              context,
                              'Level Air',
                              history.levelAir.toStringAsFixed(1),
                              'cm',
                              history.levelAir < 10,
                            ),
                            _buildSensorRow(
                              context,
                              'Kecepatan Angin',
                              history.angin.toStringAsFixed(1),
                              'm/s',
                              history.angin >= 5,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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

  Widget _buildSensorRow(
    BuildContext context,
    String label,
    String value,
    String unit,
    bool isWarning, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Row(
            children: [
              Text(
                '$value$unit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isWarning ? Colors.red : Colors.black87,
                ),
              ),
              if (isWarning) ...[
                const SizedBox(width: 4),
                const Icon(Icons.warning_rounded, color: Colors.red, size: 16),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
