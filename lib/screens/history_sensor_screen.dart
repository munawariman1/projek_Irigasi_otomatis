import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HistorySensorScreen extends StatelessWidget {
  const HistorySensorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyRef = FirebaseDatabase.instance.ref('history_sensor');

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Data Sensor')),
      body: StreamBuilder(
        stream: historyRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("Belum ada data sensor."));
          }

          final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final entries = data.entries.toList().reversed;

          return ListView(
            children: entries.map((e) {
              final item = Map<String, dynamic>.from(e.value);
              return ListTile(
                title: Text("Kelembapan: ${item['kelembapanTanah']}%"),
                subtitle: Text("Suhu: ${item['suhuTanah']}°C, pH: ${item['phTanah']}"),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
