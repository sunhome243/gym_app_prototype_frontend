# Firebase란

**Firebase**는 Google이 제공하는 모바일 및 웹 애플리케이션 개발을 위한 플랫폼입니다. 개발자들이 손쉽게 고품질의 애플리케이션을 개발하고 확장할 수 있도록 다양한 기능과 서비스를 제공합니다. Firebase는 백엔드 인프라를 직접 구축할 필요 없이 실시간 데이터베이스, 인증, 호스팅, 스토리지, 분석 등 여러 기능을 통합적으로 활용할 수 있는 강력한 도구입니다. IOS, Android, Web, Unity, Flutter 등 다양한 플랫폼 및 언어 환경에서 사용할 수 있습니다.

## 왜 Firebase를 사용하는가?

- **생산성 향상**  
  Firebase는 개발자가 반복적인 작업에 소요하는 시간을 줄이고 핵심 기능 개발에 집중할 수 있도록 돕습니다. 통합된 SDK와 간편한 API를 통해 빠르게 애플리케이션을 개발하고 배포할 수 있습니다.

- **실시간 데이터 처리**  
  Firebase의 실시간 데이터베이스는 클라우드 기반의 NoSQL 데이터베이스로, 사용자 간 데이터 동기화가 실시간으로 이루어집니다. 이를 통해 채팅 애플리케이션, 실시간 협업 도구 등 즉각적인 데이터 업데이트가 필요한 애플리케이션을 쉽게 구현할 수 있습니다.

- **안정적인 백엔드 서비스**  
  Firebase는 Google 클라우드 인프라를 기반으로 하여 높은 안정성과 확장성을 제공합니다. 개발자는 서버 관리의 복잡성을 덜고, 비즈니스 로직과 사용자 경험에 집중할 수 있습니다. 백엔드를 아예 사용하지 않을 수도 있고 백엔드를 따로 구축하여 사용할 수도 있습니다. 따로 구축할 경우 Firebase Admin SDK를 사용하면 손쉽게 백엔드와 Firebase를 사용하는 프론트엔드를 연결할 수 있습니다.

## 주요 기능

- **Firebase Realtime Database**  
  JSON 형식의 실시간 데이터베이스로, 데이터가 변경될 때마다 클라이언트에 즉시 업데이트를 전달합니다.

- **Firebase Cloud Firestore**  
  확장성이 뛰어난 클라우드 기반 NoSQL 데이터베이스로, 복잡한 쿼리와 트랜잭션을 지원합니다.

- **Firebase Cloud Messaging (FCM)**  
  애플리케이션 사용자에게 푸시 알림을 전송할 수 있는 기능을 제공합니다. 이를 통해 사용자 참여도를 높일 수 있습니다.

- **Firebase Hosting**  
  정적 웹 사이트와 콘텐츠를 신속하게 배포할 수 있는 고성능 호스팅 서비스를 제공합니다.

- **Firebase Cloud Functions**  
  서버리스 환경에서 동작하는 백엔드 코드를 작성하고, Firebase 이벤트에 반응하는 함수들을 실행할 수 있습니다. JS나 Python을 구동할 수 있는 scalable Node.js 환경을 제공합니다.

- **Firebase Analytics**  
  사용자 행동을 분석하고 애플리케이션의 사용 패턴을 이해하는 데 도움이 되는 무료 분석 서비스를 제공합니다.

- **Firebase Crashlytics**  
  애플리케이션의 충돌 보고서를 수집 및 분석하여 문제를 신속하게 파악하고 해결할 수 있습니다.

- **Firebase Data Connect**  
  아직 베타 버전인 Data Connect는 PSQL 데이터베이스를 지원하며 손쉬운 query 관리 등 PSQL 데이터베이스 및 테이블 관리를 손쉽게 해줍니다.

- **Firebase Authentication**  
  이메일, 비밀번호, 소셜 로그인(Google, Facebook, Twitter 등)을 통해 사용자를 손쉽게 인증할 수 있는 기능을 제공합니다. 특히 JWT를 활용한 기능들을 매우 간편하게 구축할 수 있습니다. Custom Claim을 추가하여 기능별로 다양한 조건들과 verification들을 관리하기 쉬우며, 구글, 깃허브, 페이스북 로그인 등 다양한 소셜 로그인 기능도 지원합니다.

## 예시 코드

다음은 Dart 언어를 사용하는 Flutter의 Auth Service 예시입니다.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService;
  
  AuthService(this._apiService);

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName('$firstName $lastName');
      // Create user in backend
      await _apiService.createUser({
        'uid': userCredential.user!.uid,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'role': userType.toLowerCase(),
      });
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign up: $e');
      }
      rethrow;
    }
  }

  Future<UserCredential> signIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign in: $e');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> getIdToken() async {
    return await _auth.currentUser?.getIdToken() ?? '';
  }

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> getCurrentUserInfo() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user currently signed in');
    }
    String? idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to get ID token');
    }
    Map<String, dynamic> decodedToken;
    try {
      decodedToken = JwtDecoder.decode(idToken);
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding JWT: $e');
      }
      throw Exception('Failed to decode ID token');
    }
    String role = decodedToken['role'] as String? ?? 'unknown';
    return {
      'uid': user.uid,
      'email': user.email ?? '',
      'first_name': decodedToken['first_name'] as String? ?? user.displayName?.split(' ').first ?? '',
      'last_name': decodedToken['last_name'] as String? ?? user.displayName?.split(' ').last ?? '',
      'role': role.toLowerCase(),
    };
  }
}
```

로그인 화면에서는 이 auth service의 함수를 활용하여 손쉽게 로그인이 가능합니다.

```dart
Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await _auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Map<String, dynamic> userInfo = await _auth.getCurrentUserInfo();
      String userRole = userInfo['role'];
      Widget homeScreen;
      if (userRole == 'trainer') {
        homeScreen = const TrainerHomeScreen();
      } else if (userRole == 'member') {
        homeScreen = const MemberHomeScreen();
      } else {
        throw Exception('Invalid user role');
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => homeScreen),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

Firebase는 auth emulator도 지원하는데, 실제 데이터베이스를 사용하지 않고도 JWT를 활용한 기능들이 작동하는지 확인할 수 있습니다. sign up, login, logout, JWT decode 등 다양한 authentication 코드를 직접 짜지 않고도 Firebase의 서비스를 사용하면 빠르고 간편하게 auth 서비스를 구축할 수 있습니다.