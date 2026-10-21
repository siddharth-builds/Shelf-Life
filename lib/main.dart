import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart'; // 1. Restored the Phase 2 login module import
import 'services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones(); // Initialize timezone data
  await NotificationService().initialize();
  runApp(const KnowExpiryApp());
}

class KnowExpiryApp extends StatelessWidget {
  const KnowExpiryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Know Expiry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // If an active authenticated session exists, direct to real-time list
          if (snapshot.hasData && snapshot.data != null) {
            return const DashboardScreen();
          }
          
          // 2. Restored entry gate fallback mapping
          return const LoginScreen();
        },
      ),
    );
  }
  void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize timezone and notification channels
  await NotificationService().initialize(); 
  
  runApp(const KnowExpiryApp());
}
}

