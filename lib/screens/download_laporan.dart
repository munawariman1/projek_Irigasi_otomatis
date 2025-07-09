// export_laporan_screen.dart - Unduh laporan sensor dan prediksi
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ExportLaporanScreen extends StatefulWidget {
  const ExportLaporanScreen({super.key});

  @override
  State<ExportLaporanScreen> createState() => _ExportLaporanScreenState();
}

class _ExportLaporanScreenState extends State<ExportLaporanScreen> {
  bool isLoading = false;
  String status = "";

  Future<void> _exportData() async {
    setState(() {
      isLoading = true;
      status = "Mengambil data dari Firebase...";
    });

    try {
      final sensorSnapshot = await FirebaseDatabase.instance.ref('sensors').get();
      final prediksiSnapshot = await FirebaseDatabase.instance.ref('historyPrediksi').get();

      final sensorData = sensorSnapshot.value as Map<dynamic, dynamic>?;
      final prediksiData = prediksiSnapshot.value as Map<dynamic, dynamic>?;

      StringBuffer csvBuffer = StringBuffer();
      csvBuffer.writeln("Tipe,Waktu,Data");

      if (sensorData != null) {
        sensorData.forEach((key, value) {
          final v = Map<String, dynamic>.from(value);
          csvBuffer.writeln("Sensor,${v['timestamp'] ?? '-'},${v.toString()}");
        });
      }
      if (prediksiData != null) {
        prediksiData.forEach((key, value) {
          final v = Map<String, dynamic>.from(value);
          csvBuffer.writeln("Prediksi,${v['timestamp'] ?? '-'},${v.toString()}");
        });
      }

      setState(() => status = "Menyimpan file ke perangkat...");

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/laporan_irigasi.csv');
      await file.writeAsString(csvBuffer.toString());

      setState(() => status = "Membagikan file...");

      await Share.shareXFiles([XFile(file.path)], text: "Laporan Irigasi");
    } catch (e) {
      setState(() => status = "Terjadi kesalahan: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Unduh Laporan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: isLoading ? null : _exportData,
              icon: const Icon(Icons.download),
              label: const Text("Unduh Laporan CSV"),
            ),
            const SizedBox(height: 16),
            Text(status, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
