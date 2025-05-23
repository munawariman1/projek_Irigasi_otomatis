import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String sensorTitle = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: Text("Detail $sensorTitle")),
      body: Center(
        child: Text(
          "Data lengkap untuk $sensorTitle akan ditampilkan di sini.",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
