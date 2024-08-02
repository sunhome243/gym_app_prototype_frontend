import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/select_user_type_screen.dart';
import 'screens/member_home_screen.dart';
import 'services/auth_service.dart';
import 'services/api_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Firebase 초기화 확인
  if (!kIsWeb && Firebase.apps.isEmpty) {
    print("Firebase not initialized. Attempting to initialize...");
    await Firebase.initializeApp();
  }

  // Emulator 설정
  if (kDebugMode) {
    String host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  }

  final apiService = ApiService(() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await user.getIdToken() ?? '';
    }
    return '';
  });

  final authService = AuthService(apiService);

  // FCM 설정
  await setupFCM(apiService);

  runApp(MyApp(apiService: apiService, authService: authService));
}

Future<void> setupFCM(ApiService apiService) async {
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
    
    // 토큰 가져오기 및 서버에 전송
    String? token = await messaging.getToken();
    if (token != null) {
      await apiService.addFCMToken(token);
    }

    // 토큰 리프레시 리스너 설정
    messaging.onTokenRefresh.listen((String token) async {
      await apiService.addFCMToken(token);
    });

    // 포그라운드 메시지 처리
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // 여기에 로컬 알림 표시 로직 추가
      }
    });
  } else {
    print('User declined or has not accepted permission');
  }
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final AuthService authService;

  const MyApp({Key? key, required this.apiService, required this.authService}) : super(key: key);

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
          '/home': (context) => const MemberHomeScreen(),
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