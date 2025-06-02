import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class HistoryPrediksiScreen extends StatelessWidget {
  const HistoryPrediksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyRef = FirebaseDatabase.instance.ref('historyPrediksi');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Prediksi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: historyRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Belum ada data prediksi."));
          }
          try {
            final data = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map,
            );
            final entries =
                data.entries.toList()..sort((a, b) {
                  final timeA = (a.value as Map)['timestamp']?.toString() ?? '';
                  final timeB = (b.value as Map)['timestamp']?.toString() ?? '';
                  return timeB.compareTo(timeA);
                });

            return ListView(
              padding: const EdgeInsets.all(16),
              children:
                  entries.map((e) {
                    final item = Map<String, dynamic>.from(e.value);
                    final rawValues =
                        item['raw_values'] is Map
                            ? Map<String, dynamic>.from(item['raw_values'])
                            : null;
                    final dataSensor =
                        item['data_sensor'] is List
                            ? List.from(item['data_sensor'])
                            : null;

                    // Format waktu
                    String waktu = item['timestamp']?.toString() ?? '';
                    if (waktu.isNotEmpty && waktu.contains(' ')) {
                      try {
                        waktu = DateFormat(
                          'yyyy-MM-dd HH:mm:ss',
                        ).format(DateTime.parse(waktu.replaceAll(' ', 'T')));
                      } catch (_) {}
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Prediksi: ${item['prediction']?.toString() ?? 'N/A'}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  waktu,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (rawValues != null) ...[
                              Text(
                                "Kelembapan: ${rawValues['kelembapan_tanah']}%, "
                                "Suhu: ${rawValues['suhu_tanah']}°C",
                              ),
                              Text(
                                "pH: ${rawValues['ph_tanah']}, "
                                "Hujan: ${rawValues['curah_hujan']}mm",
                              ),
                              Text(
                                "Angin: ${rawValues['kecepatan_angin']}m/s, "
                                "Level Air: ${rawValues['level_air']}cm",
                              ),
                            ] else if (dataSensor != null &&
                                dataSensor.length == 6) ...[
                              Text(
                                "Kelembapan: ${dataSensor[0]}%, Suhu: ${dataSensor[1]}°C",
                              ),
                              Text(
                                "pH: ${dataSensor[2]}, Hujan: ${dataSensor[3]}mm",
                              ),
                              Text(
                                "Angin: ${dataSensor[4]}m/s, Level Air: ${dataSensor[5]}cm",
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              "Processing time: ${item['processing_time']?.toString() ?? '-'} detik",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            );
          } catch (e) {
            return Center(child: Text('Error parsing data: $e'));
          }
        },
      ),
    );
  }
}
