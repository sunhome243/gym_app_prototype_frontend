import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'api_services.dart';
import 'dart:convert';

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
      // Create user in Firebase
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName('$firstName $lastName');

      // Store user type locally
      await _storeUserType(userType);

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
    await _clearUserType();
  }

  Future<String> getIdToken() async {
    return await _auth.currentUser?.getIdToken() ?? '';
  }

  User? get currentUser => _auth.currentUser;

  Future<void> _storeUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', userType);
  }

  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType');
  }

  Future<void> _clearUserType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userType');
  }
}