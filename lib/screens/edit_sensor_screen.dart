// edit_sensor_screen.dart - Admin kirim data simulasi sensor ke Firebase (push)

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EditSensorScreen extends StatefulWidget {
  const EditSensorScreen({super.key});

  @override
  State<EditSensorScreen> createState() => _EditSensorScreenState();
}

class _EditSensorScreenState extends State<EditSensorScreen> {
  final DatabaseReference sensorRef = FirebaseDatabase.instance.ref('sensors');
  final TextEditingController kelembapanController = TextEditingController();
  final TextEditingController suhuController = TextEditingController();
  final TextEditingController phController = TextEditingController();
  final TextEditingController curahHujanController = TextEditingController();
  final TextEditingController anginController = TextEditingController();
  final TextEditingController levelAirController = TextEditingController();

  void _submit() async {
    final Map<String, dynamic> data = {
      "kelembapanTanah": double.tryParse(kelembapanController.text) ?? 0,
      "suhuTanah": double.tryParse(suhuController.text) ?? 0,
      "phTanah": double.tryParse(phController.text) ?? 0,
      "curahHujan": double.tryParse(curahHujanController.text) ?? 0,
      "kecepatanAngin": double.tryParse(anginController.text) ?? 0,
      "levelAir": double.tryParse(levelAirController.text) ?? 0,
      "timestamp": DateTime.now().toIso8601String(),
    };

    await sensorRef.push().set(data); // PUSH ke Firebase

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Data sensor berhasil dikirim')),
    );

    kelembapanController.clear();
    suhuController.clear();
    phController.clear();
    curahHujanController.clear();
    anginController.clear();
    levelAirController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Simulasi Nilai Sensor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildField("Kelembapan Tanah", kelembapanController),
            _buildField("Suhu Tanah", suhuController),
            _buildField("pH Tanah", phController),
            _buildField("Curah Hujan", curahHujanController),
            _buildField("Kecepatan Angin", anginController),
            _buildField("Level Air", levelAirController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Kirim ke Firebase"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
