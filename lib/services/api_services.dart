import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'schemas.dart';

class ApiService {
  final Future<String> Function() getIdToken;

  ApiService(this.getIdToken);

  Future<dynamic> _request(String serviceName, String path, String method,
      {Map<String, dynamic>? body}) async {
    final idToken = await getIdToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };

    String baseUrl;
    switch (serviceName) {
      case 'user':
        baseUrl = Config.userServiceUrl;
        break;
      case 'workout':
        baseUrl = Config.workoutServiceUrl;
        break;
      case 'stats':
        baseUrl = Config.statsServiceUrl;
        break;
      default:
        throw Exception('Unknown service: $serviceName');
    }

    Uri url = Uri.parse('$baseUrl/api/$path');
    if (kDebugMode) {
      print('Sending $method request to $url');
      print('Headers: $headers');
      if (body != null) {
        print('Request body: ${jsonEncode(body)}');
      }
    }

    http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response =
              await http.post(url, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          response =
              await http.put(url, headers: headers, body: jsonEncode(body));
          break;
        case 'PATCH':
          response =
              await http.patch(url, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      if (response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 307) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          print('Redirecting to: $redirectUrl'); // 추가된 로그
          url = Uri.parse(redirectUrl);
          response =
              await http.post(url, headers: headers, body: jsonEncode(body));
        } else {
          print('Redirect URL is null'); // 추가된 로그
        }
      }

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to perform request: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in API request: $e');
      }
      rethrow;
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    await _request('user', 'users', 'POST', body: userData);
  }

  Future<Map<String, dynamic>> getMemberInfo() async {
    return await _request('user', 'members/me/', 'GET');
  }

  Future<List<SessionWithSets>> getSessions() async {
    try {
      final userId = await getUserId();
      print('Fetching sessions for user ID: $userId'); // Debug print

      final response = await _request('workout', 'get_sessions/$userId', 'GET');
      print('Raw API response: $response'); // Debug print

      if (response is List) {
        final sessions = response.map((session) => SessionWithSets.fromJson(session)).toList();
        print('Parsed ${sessions.length} sessions'); // Debug print
        return sessions;
      } else {
        print('Unexpected response format: ${response.runtimeType}'); // Debug print
        throw Exception('Unexpected response format: ${response.runtimeType}');
      }
    } catch (e) {
      print('Error in getSessions: $e'); // Enhanced error logging
      if (e is FormatException) {
        print('JSON parsing error: ${e.source}');
      }
      rethrow;
    }
  }

  Future<String> getUserId() async {
    try {
      final memberInfo = await getMemberInfo();
      return memberInfo['uid'] as String;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user ID: $e');
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getMyMappings() async {
    final response = await _request('user', 'my-mappings/', 'GET');
    return response as List<dynamic>;
  }

  Future<void> requestTrainerMemberMapping(String trainerEmail, int initialSessions) async {
    try {
      final response = await _request('user', 'trainer-member-mapping/request', 'POST', body: {
        'other_email': trainerEmail,
        'initial_sessions': initialSessions,
      });
      
      print("API Response: $response"); // 디버그 로그
      
      if (response['id'] != null) {
        print("Mapping request successful"); // 디버그 로그
        return; // 성공적으로 처리됨
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      print("Error in requestTrainerMemberMapping: $e"); // 디버그 로그
      rethrow; // 예외를 다시 던져서 호출자가 처리할 수 있도록 함
    }
  }

  Future<void> updateTrainerMemberMappingStatus(int mappingId, String newStatus) async {
  await _request('user', 'trainer-member-mapping/$mappingId/status', 'PATCH', body: {
    'new_status': newStatus,
    });
  }

  Future<void> removeTrainerMemberMapping(String otherEmail) async {
    await _request('user', 'trainer-member-mapping/$otherEmail', 'DELETE');
  }
}
