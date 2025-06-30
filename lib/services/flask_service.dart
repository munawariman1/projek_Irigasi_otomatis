import 'package:firebase_database/firebase_database.dart';
import 'package:projek_irigasi_otomatis/models/prediction_result.dart';
import 'package:flutter/material.dart';

class PrediksiStreamWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('historyPrediksi').limitToLast(1).onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = (snapshot.data!.snapshot.value as Map).values.first as Map;
          final hasil = PredictionResult.fromJson(Map<String, dynamic>.from(data));
          return Column(
            children: [
              Text('Prediksi: ${hasil.prediction}'),
              Text('Probabilitas: ${hasil.probabilitas}'),
              Text('Durasi Penyiraman: ${hasil.durasiPenyiraman} detik'),
              Text('Waktu: ${hasil.timestamp}'),
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
