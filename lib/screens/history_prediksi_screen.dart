import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoryPrediksiScreen extends StatelessWidget {
  const HistoryPrediksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prediksiRef = FirebaseDatabase.instance.ref().child('history_prediksi');

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Prediksi Efisiensi')),
      body: StreamBuilder(
        stream: prediksiRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Belum ada prediksi."));
          }

          final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final entries = data.entries.toList().reversed;

          return ListView(
            children: entries.map((e) {
              final item = Map<String, dynamic>.from(e.value);
              return ListTile(
                title: Text("Efisiensi: ${item['efisiensi']} (${item['irigasiWaktu']} detik)"),
                subtitle: Text("Kelembapan: ${item['kelembapanTanah']}%, Waktu: ${item['waktu']}"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
