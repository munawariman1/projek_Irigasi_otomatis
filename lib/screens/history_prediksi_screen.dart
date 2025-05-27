import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoryPrediksiScreen extends StatelessWidget {
  const HistoryPrediksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyRef = FirebaseDatabase.instance.ref('history_prediksi');

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Prediksi Efisiensi')),
      body: StreamBuilder(
        stream: historyRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Belum ada data prediksi."));
          }

          final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final entries = data.entries.toList().reversed;

          return ListView(
            children: entries.map((e) {
              final item = Map<String, dynamic>.from(e.value);
              return ListTile(
                title: Text("Efisiensi: ${item['efisiensi']} | Durasi: ${item['irigasiWaktu']} detik"),
                subtitle: Text(
                  "Kelembapan: ${item['kelembapanTanah']}%, Suhu: ${item['suhuTanah']}°C, "
                  "pH: ${item['phTanah']}, Hujan: ${item['curahHujan']}mm, "
                  "Angin: ${item['kecepatanAngin']} m/s\nWaktu: ${item['waktu']}"
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}