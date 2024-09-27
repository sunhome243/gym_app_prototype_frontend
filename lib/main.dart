import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/sign_up_screen.dart';
import 'screens/login/select_user_type_screen.dart';
import 'screens/member_home_screen.dart';
import 'screens/trainer_home_screen.dart';
import 'services/auth_service.dart';
import 'services/api_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();

    if (kDebugMode) {
      String host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    }

    final apiService = ApiService(() async {
      User? user = FirebaseAuth.instance.currentUser;
      return user != null ? (await user.getIdToken() ?? '') : '';
    });

    final authService = AuthService(apiService);

    await setupFCM(apiService);

    runApp(MyApp(apiService: apiService, authService: authService));
  } catch (e) {
    print("Error during initialization: $e");
  }
}

Future<void> setupFCM(ApiService apiService) async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      String? token = await messaging.getToken();
      if (token != null) {
        try {
          await apiService.addFCMToken(token);
        } catch (e) {
          print("Error sending FCM token to server: $e");
        }
      }

      messaging.onTokenRefresh.listen((String token) async {
        try {
          await apiService.addFCMToken(token);
        } catch (e) {
          print("Error sending refreshed FCM token to server: $e");
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  } catch (e) {
    print("Error setting up FCM: $e");
  }
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
        home: const AuthWrapper(),
        routes: {
          '/select_user_type': (context) => const SelectUserTypeScreen(),
          '/member_home': (context) => const MemberHomeScreen(),
          '/trainer_home': (context) => const TrainerHomeScreen(),
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return FutureBuilder<Map<String, dynamic>>(
            future: authService.getCurrentUserInfo(),
            builder: (context, userInfoSnapshot) {
              if (userInfoSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userInfoSnapshot.hasData) {
                final userRole = userInfoSnapshot.data!['role'];
                if (userRole == 'member') {
                  return const MemberHomeScreen();
                } else if (userRole == 'trainer') {
                  return const TrainerHomeScreen();
                }
              }
              // If we can't determine the role, log out the user and show the login screen
              authService.signOut();
              return const LoginScreen();
            },
          );
        }
        return const LoginScreen(); // Show login screen if user is not logged in
      },
    );
  }
}
