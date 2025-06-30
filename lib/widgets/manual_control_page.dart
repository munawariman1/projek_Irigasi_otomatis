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

  Future<void> _showDurationDialog() async {
    final controller = TextEditingController();
    int? seconds;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Masukkan Durasi Penyiraman (detik)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Contoh: 60',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                seconds = int.tryParse(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text('Mulai'),
          ),
        ],
      ),
    );

    if (seconds != null && seconds! > 0) {
      _startManualPump(seconds!);
    }
  }

  void _startManualPump(int seconds) {
    // Set mode manual dan status pompa ON beserta log waktu dan durasi
    final startTime = DateTime.now().toIso8601String();

    _setManualMode();
    _pompaRef.child('manual').set({
      'status': true,
      'lastStart': startTime,
      'duration': seconds,
    });

    // Simpan ke manualLog
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kontrol Manual Pompa"),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.pushNamed(context, '/manualLog');
            },
            tooltip: 'Lihat Log Manual',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchListTile(
              title: Text("Mode Manual (Override)"),
              value: _isManualMode,
              onChanged: (val) {
                if (val) _setManualMode();
                // Jika ingin mengembalikan ke otomatis, bisa tambahkan aksi di sini.
              },
            ),
            SizedBox(height: 32),
            Icon(
              _isPumpOn ? Icons.water : Icons.water_outlined,
              size: 80,
              color: _isPumpOn ? Colors.blue : Colors.grey,
            ),
            SizedBox(height: 16),
            if (_isPumpOn)
              Text(
                "Penyiraman Berjalan\nSisa waktu: $_remainingSeconds detik",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isPumpOn ? null : _showDurationDialog,
              child: Text("Nyalakan Pompa (Manual)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isPumpOn ? _stopManualPump : null,
              child: Text("Matikan Pompa"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
