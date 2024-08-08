import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
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

  Future<UserCredential> signIn(
      {required String email, required String password}) async {
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
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _apiService.removeFCMToken(token).catchError((e) {
        print('Error removing FCM token: $e');
        // Continue with sign out even if FCM token removal fails
      });
    }
  } catch (e) {
    print('Error getting FCM token: $e');
    // Continue with sign out even if there's an error with FCM
  }
  
  await FirebaseAuth.instance.signOut();
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
      'first_name': decodedToken['first_name'] as String? ??
          user.displayName?.split(' ').first ??
          '',
      'last_name': decodedToken['last_name'] as String? ??
          user.displayName?.split(' ').last ??
          '',
      'role': role.toLowerCase(),
    };
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } catch (e) {
      if (kDebugMode) {
        print('Error changing password: $e');
      }
      rethrow;
    }
  }

}
