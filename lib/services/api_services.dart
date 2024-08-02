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
          if (kDebugMode) {
            print('Redirecting to: $redirectUrl');
          }
          url = Uri.parse(redirectUrl);
          response =
              await http.post(url, headers: headers, body: jsonEncode(body));
        } else {
          if (kDebugMode) {
            print('Redirect URL is null');
          }
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
      if (kDebugMode) {
        print('Fetching sessions for user ID: $userId');
      }

      final response = await _request('workout', 'get_sessions/$userId', 'GET');
      if (kDebugMode) {
        print('Raw API response: $response');
      }

      if (response is List) {
        final sessions = response.map((session) => SessionWithSets.fromJson(session)).toList();
        if (kDebugMode) {
          print('Parsed ${sessions.length} sessions');
        }
        return sessions;
      } else {
        if (kDebugMode) {
          print('Unexpected response format: ${response.runtimeType}');
        }
        throw Exception('Unexpected response format: ${response.runtimeType}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getSessions: $e');
      }
      if (e is FormatException) {
        if (kDebugMode) {
          print('JSON parsing error: ${e.source}');
        }
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

  Future<List<Map<String, dynamic>>> getMyMappings() async {
    final response = await _request('user', 'my-mappings/', 'GET');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> requestTrainerMemberMapping(String trainerEmail, int initialSessions) async {
    try {
      final response = await _request('user', 'trainer-member-mapping/request', 'POST', body: {
        'other_email': trainerEmail,
        'initial_sessions': initialSessions,
      });
      
      if (kDebugMode) {
        print("API Response: $response");
      }
      
      if (response['id'] != null) {
        if (kDebugMode) {
          print("Mapping request successful");
        }
        return;
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in requestTrainerMemberMapping: $e");
      }
      rethrow;
    }
  }

  Future<void> updateTrainerMemberMappingStatus(int mappingId, String newStatus) async {
    await _request('user', 'trainer-member-mapping/$mappingId/status', 'PATCH', body: {
      'new_status': newStatus,
    });
  }

  Future<int> getRemainingSessionsForMember(String uid) async {
    final response = await _request('user', 'trainer-member-mapping/$uid/sessions', 'GET');
    return response['remaining_sessions'] as int;
  }

  Future<void> removeTrainerMemberMapping(String otherEmail) async {
    await _request('user', 'trainer-member-mapping/$otherEmail', 'DELETE');
  }

  Future<void> requestMoreSessions(String trainerUid, int additionalSessions) async {
    try {
      final response = await _request('user', 'request-more-sessions/$trainerUid', 'POST', body: {
        'additional_sessions': additionalSessions,
      });
      
      if (kDebugMode) {
        print("API Response: $response");
      }
      
      if (response['message'] != null) {
        if (kDebugMode) {
          print("Session request successful");
        }
        return;
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in requestMoreSessions: $e");
      }
      rethrow;
    }
  }

Future<void> addFCMToken(String token) async {
  await _request('user', 'add-fcm-token', 'POST', body: {'token': token});
}

Future<void> removeFCMToken(String token) async {
  await _request('user', 'remove-fcm-token', 'POST', body: {'token': token});
}
  
}