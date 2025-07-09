import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class ManualControlPage extends StatefulWidget {
  @override
  _ManualControlPageState createState() => _ManualControlPageState();
}

class _ManualControlPageState extends State<ManualControlPage> {
  final DatabaseReference _pompaRef = FirebaseDatabase.instance.ref('pompa');
  final DatabaseReference _manualLogRef = FirebaseDatabase.instance.ref('manualLog');

  bool _isManualMode = false;
  bool _isPumpOn = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  double _selectedDuration = 30;

  @override
  void initState() {
    super.initState();

    _pompaRef.child('mode').onValue.listen((event) {
      final mode = event.snapshot.value as String?;
      setState(() {
        _isManualMode = mode == 'manual';
      });
    });

    _pompaRef.child('manual/status').onValue.listen((event) {
      final status = event.snapshot.value as bool?;
      setState(() {
        _isPumpOn = status ?? false;
      });
    });
  }

  void _setManualMode() {
    _pompaRef.child('mode').set('manual');
  }

  void _startManualPump(int seconds) {
    final startTime = DateTime.now().toIso8601String();

    _setManualMode();
    _pompaRef.child('manual').set({
      'status': true,
      'lastStart': startTime,
      'duration': seconds,
    });

    _manualLogRef.push().set({
      'waktu': startTime,
      'durasi': seconds,
    });

    setState(() {
      _remainingSeconds = seconds;
      _isPumpOn = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        _stopManualPump();
      }
    });
  }

  void _stopManualPump() {
    _pompaRef.child('manual/status').set(false);
    setState(() {
      _isPumpOn = false;
      _remainingSeconds = 0;
    });
    _timer?.cancel();
  }

  void _showDurationSlider() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Atur Durasi Penyiraman"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              min: 10,
              max: 300,
              divisions: 29,
              value: _selectedDuration,
              label: "${_selectedDuration.toInt()} detik",
              onChanged: (val) {
                setState(() {
                  _selectedDuration = val;
                });
              },
            ),
            Text(
              "Durasi: ${_selectedDuration.toInt()} detik",
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startManualPump(_selectedDuration.toInt());
            },
            child: const Text("Nyalakan"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kontrol Manual Pompa"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/manualLog');
            },
            tooltip: "Log Manual",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchListTile(
              title: const Text("Mode Manual Aktif"),
              value: _isManualMode,
              onChanged: (val) {
                if (val) _setManualMode();
              },
              activeColor: Colors.green,
            ),
            const SizedBox(height: 24),
            Icon(
              _isPumpOn ? Icons.water_drop : Icons.water_drop_outlined,
              color: _isPumpOn ? Colors.blue : Colors.grey,
              size: 80,
            ),
            const SizedBox(height: 12),
            Text(
              _isPumpOn
                  ? "Pompa Menyala\nSisa Waktu: $_remainingSeconds detik"
                  : "Pompa Tidak Aktif",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isPumpOn ? null : _showDurationSlider,
              icon: const Icon(Icons.play_arrow),
              label: const Text("Nyalakan Pompa"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isPumpOn ? _stopManualPump : null,
              icon: const Icon(Icons.stop),
              label: const Text("Matikan Pompa"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
