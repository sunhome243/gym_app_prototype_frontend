import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/select_user_type_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/api_services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Firebase 초기화 확인
  if (!kIsWeb && Firebase.apps.isEmpty) {
    print("Firebase not initialized. Attempting to initialize...");
    await Firebase.initializeApp();
  }

  FirebaseFunctions.instance;
  
  // Emulator 설정
  if (kDebugMode) {
    String host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  }

  final apiService = ApiService(() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken() ?? '';
    }
    return '';
  });
  final authService = AuthService(apiService);

  runApp(MyApp(apiService: apiService, authService: authService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final AuthService authService;

  const MyApp({super.key, required this.apiService, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => authService),
        Provider<ApiService>(create: (_) => apiService),
      ],
      child: MaterialApp(
        title: 'Gym App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/select_user_type': (context) => const SelectUserTypeScreen(),
          '/home': (context) => const HomeScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/sign_up') {
            final args = settings.arguments as Map<String, dynamic>?;
            final userType = args?['userType'] as String? ?? '';
            return MaterialPageRoute(
              builder: (context) => SignUpScreen(userType: userType),
            );
          }
          return null;
        },
      ),
    );
  }
}