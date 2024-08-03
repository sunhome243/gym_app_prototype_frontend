import 'dart:io';
import 'package:flutter/foundation.dart';

class Config {
  static String get userServiceUrl {
    if (kReleaseMode) {
      return 'https://your-production-api.com';  // 실제 프로덕션 API URL로 교체하세요
    } else {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';  // Android 에뮬레이터용
      } else if (Platform.isIOS) {
        return 'http://localhost:8000';  // iOS 시뮬레이터용
      } else {
        return 'http://YOUR_MACHINE_IP:8000';  // YOUR_MACHINE_IP를 실제 IP 주소로 교체하세요
      }
    }
  }

  static String get workoutServiceUrl {
    if (kReleaseMode) {
      return 'https://your-production-api.com';
    } else {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8001';
      } else if (Platform.isIOS) {
        return 'http://localhost:8001';
      } else {
        return 'http://YOUR_MACHINE_IP:8001';
      }
    }
  }

  static String get statsServiceUrl {
    if (kReleaseMode) {
      return 'https://your-production-api.com';
    } else {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8002';
      } else if (Platform.isIOS) {
        return 'http://localhost:8002';
      } else {
        return 'http://YOUR_MACHINE_IP:8002';
      }
    }
  }
}