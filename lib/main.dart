import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_prediksi_screen.dart';
import 'utils/theme.dart';
import 'widgets/manual_control_page.dart';
import 'widgets/manual_log_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔔 Background FCM: ${message.notification?.title}");
}

Future setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();
  await messaging.subscribeToTopic("all"); 
  String? token = await messaging.getToken();
  print("🔔 Token FCM: $token");

  if (token != null) {
    DatabaseReference ref = FirebaseDatabase.instance.ref("fcmTokens/device1");
    await ref.set(token);
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("📬 Notifikasi masuk: ${message.notification!.title}");
      flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Notifikasi',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await setupFCM();
  } catch (e) {
    print("❌ Firebase error: $e");
  }

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
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
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
        '/history_prediksi': (context) => const HistoryPrediksiScreen(),
        '/manualControl': (context) => ManualControlPage(),
        '/manualLog': (context) => ManualLogPage(),
      },
    );
  }
}
