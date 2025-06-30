import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ManualLogPage extends StatelessWidget {
  final DatabaseReference _manualLogRef = FirebaseDatabase.instance.ref('manualLog');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Log Penyiraman Manual")),
      body: StreamBuilder(
        stream: _manualLogRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final logMap = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            final logList = logMap.entries.toList()
              ..sort((a, b) => b.value['waktu'].compareTo(a.value['waktu']));
            return ListView.builder(
              itemCount: logList.length,
              itemBuilder: (context, index) {
                final item = logList[index].value;
                final waktu = DateTime.parse(item['waktu']).toLocal();
                final durasi = item['durasi'];
                return ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    "Penyiraman Manual",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Waktu: ${waktu.day}-${waktu.month}-${waktu.year} ${waktu.hour}:${waktu.minute}\nDurasi: $durasi detik",
                  ),
                );
              },
            );
          }
          return Center(child: Text("Belum ada log manual"));
        },
      ),
    );
  }
}
