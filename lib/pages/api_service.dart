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

  /// ✏️ Update sewadar
  static Future<void> updateSewadar(
    int id, {
    String? name,
    String? email,
    int? deptId0,
    int? deptId1,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/sewadar/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        if (name != null) "name": name,
        if (email != null) "email": email,
        if (deptId0 != null) "dept_id0": deptId0,
        if (deptId1 != null) "dept_id1": deptId1,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update sewadar with id=$id");
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

  // --------------------------
  // 📊 Dashboard API
  // --------------------------
  static Future<dynamic> getDashboard({String? date}) async {
    final endpoint = date != null ? "/dashboard?date=$date" : "/dashboard";
    return await _getRequest(endpoint);
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

  static Future<void> addAttendance({
    required int sid,
    required String attendance,
  }) async {
    final body = jsonEncode({
      "sid": sid,
      "attendance": attendance,
    });

    final response = await http.post(
      Uri.parse("$baseUrl/attendance"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      print("✅ Attendance saved for sid=$sid");
    } else {
      throw Exception("❌ Failed to save attendance: ${response.body}");
    }
  }

  // --------------------------
  // Generic HTTP Methods
  // --------------------------
  static Future<dynamic> _getRequest(String endpoint) async {
    final response = await http.get(Uri.parse("$baseUrl$endpoint"));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("GET $endpoint failed: ${response.body}");
  }

  static Future<dynamic> _postRequest(
      String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201)
      return jsonDecode(response.body);
    throw Exception("POST $endpoint failed: ${response.body}");
  }

  static Future<dynamic> _putRequest(
      String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("PUT $endpoint failed: ${response.body}");
  }

  static Future<dynamic> _deleteRequest(String endpoint) async {
    final response = await http.delete(Uri.parse("$baseUrl$endpoint"));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("DELETE $endpoint failed: ${response.body}");
  }
}
