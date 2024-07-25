import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

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

    String baseUrl = Config.userServiceUrl;  // Assuming this is your backend URL

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
          response = await http.post(url, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: jsonEncode(body));
          break;
        case 'PATCH':
          response = await http.patch(url, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method');
      }

      if (response.statusCode == 301 || response.statusCode == 302 || response.statusCode == 307) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
  // 추가된 로그
          url = Uri.parse(redirectUrl);
          response = await http.post(url, headers: headers, body: jsonEncode(body));
        } else {
          print('Redirect URL is null');  // 추가된 로그
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

  // Add other API methods as needed...
}