import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_sensor_screen.dart';
import 'screens/history_prediksi_screen.dart';
import 'utils/theme.dart';
import 'widgets/manual_control_page.dart';
import 'widgets/manual_log_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized");
  } catch (e) {
    print("❌ Firebase initialization error: $e");
  }

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Irigasi Otomatis',
      theme: AppTheme.theme,
      home: const SplashScreen(), // Start with splash screen
      onGenerateRoute: (settings) {
        // Handle navigation after splash
        if (settings.name == '/home') {
          return PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        }
        return null;
      },
      routes: {
        '/history_sensor': (context) => const HistorySensorScreen(),
        '/history_prediksi': (context) => const HistoryPrediksiScreen(),
        '/manualControl': (context) => ManualControlPage(),
        '/manualLog': (context) => ManualLogPage(),
      },
    );
  }
}
