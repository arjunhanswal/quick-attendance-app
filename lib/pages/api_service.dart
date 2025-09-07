import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = "https://arhans.codebhai.online/api";

  /// 📋 Get all active sewadar
  static Future<List<Map<String, dynamic>>> getSewadars() async {
    final response = await http.post(
      Uri.parse("$baseUrl/sewadar/all"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data.map<Map<String, dynamic>>((item) {
          try {
            // Step 1: Extract raw data
            String rawData = item["data"] ?? "{}";

            // Step 2: Decode nested JSON once
            Map<String, dynamic> parsedData = {};
            try {
              parsedData = jsonDecode(rawData);
            } catch (e) {
              debugPrint("⚠️ Failed to decode data: $rawData");
            }

            // Step 3: Ensure values are strings
            parsedData = parsedData.map((key, value) =>
                MapEntry(key.toString(), value?.toString() ?? ""));

            // Step 4: Merge with main fields
            return {
              "sid": item["sid"],
              "created_at": item["created_at"]?.toString() ?? "",
              "created_by": item["created_by"]?.toString() ?? "",
              "status": item["status"]?.toString() ?? "",
              ...parsedData,
            };
          } catch (e) {
            debugPrint("❌ Parsing error: $e");
            return {
              "sid": item["sid"],
              "created_at": item["created_at"]?.toString() ?? "",
              "created_by": item["created_by"]?.toString() ?? "",
              "status": item["status"]?.toString() ?? "",
              "raw_data": item["data"].toString(),
            };
          }
        }).toList();
      }
      return [];
    } else {
      throw Exception("Failed to load sewadars: ${response.body}");
    }
  }

  /// 🔍 Get sewadar by ID
  static Future<Map<String, dynamic>> getSewadarById(int id) async {
    final response = await http.post(Uri.parse("$baseUrl/sewadar/$id"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load sewadar with id=$id");
    }
  }

  /// ➕ Create new sewadar
  static Future<void> addSewadar({
    required Map<String, dynamic> data,
    required int createdBy,
  }) async {
    final body = jsonEncode({
      "data": data, // ✅ your full sewadar details as JSON string
      "created_by": createdBy,
      "status": 1, // default active
    });

    final response = await http.post(
      Uri.parse("$baseUrl/sewadar"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add sewadar: ${response.body}");
    }
  }

  static Future<void> updateSewadar(
      String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sewadar/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"data": data}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update Sewadar: ${response.body}');
    }
  }

  /// 🗑️ Soft delete sewadar
  static Future<void> deleteSewadar(String id) async {
    final url = Uri.parse("$baseUrl/sewadar/$id");
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception("Failed to delete sewadar $id: ${response.body}");
    }
  }

  static Future<List<dynamic>> getDepartments() async {
    final url = Uri.parse('$baseUrl/departments/all');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch departments: ${response.body}');
    }
  }

  static Future<void> addDepartment(String name) async {
    final url = Uri.parse('$baseUrl/departments');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add department: ${response.body}');
    }
  }

  static Future<void> deleteDepartment(int id) async {
    final url = Uri.parse('$baseUrl/departments/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete department: ${response.body}');
    }
  }

  static Future<void> markAttendance({
    required String sid,
    required String attendance,
    required DateTime time,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/attendance"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sid": int.tryParse(sid) ?? sid, // API expects number
        "attendance": attendance,
        "timestamp": time.toIso8601String(), // 👈 send ISO format
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to mark attendance: ${response.body}");
    }
  }

  static Future<dynamic> getdashboardDetails(String endpoint,
      {Map<String, dynamic>? body}) async {
    final url = Uri.parse("$baseUrl$endpoint");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body != null ? jsonEncode(body) : null,
      );

      debugPrint("📡 POST $url");
      debugPrint("📨 Request Body: $body");
      debugPrint("📥 Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to POST $endpoint: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ POST error $endpoint: $e");
      rethrow;
    }
  }

  // 🔹 Login Function
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // will contain success + user/message
    } else {
      throw Exception("Failed to login: ${response.statusCode}");
    }
  }
}
