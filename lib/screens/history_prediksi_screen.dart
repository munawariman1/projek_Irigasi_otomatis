import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoryPrediksiScreen extends StatelessWidget {
  const HistoryPrediksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('historyPrediksi').orderByChild('timestamp');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Prediksi"),
        backgroundColor: Colors.green.shade700,
      ),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan."));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Belum ada data prediksi."));
          }

          final Map data = snapshot.data!.snapshot.value as Map;
          final entries = data.entries.toList();

          // Urutkan berdasarkan timestamp secara descending
          entries.sort((a, b) {
            final atime = a.value['timestamp'] ?? '';
            final btime = b.value['timestamp'] ?? '';
            return btime.compareTo(atime);
          });

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final item = entries[index].value as Map;
              final kondisi = item['kondisi'] ?? 'Tidak diketahui';
              final air = item['kebutuhan_air_ml'] ?? 0;
              final waktu = item['timestamp'] ?? '';
              final pompa = item['pompa_menyala'] == 1;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(
                    kondisi == 'Sehat'
                        ? Icons.check_circle
                        : kondisi == 'Stres'
                            ? Icons.warning
                            : Icons.error,
                    color: kondisi == 'Sehat'
                        ? Colors.green
                        : kondisi == 'Stres'
                            ? Colors.orange
                            : Colors.red,
                    size: 30,
                  ),
                  title: Text("Kondisi: $kondisi"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Air dibutuhkan: $air mL"),
                      Text("Pompa: ${pompa ? 'MENYALA' : 'OFF'}"),
                      Text("Waktu: $waktu", style: const TextStyle(fontSize: 12)),
                    ],
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
