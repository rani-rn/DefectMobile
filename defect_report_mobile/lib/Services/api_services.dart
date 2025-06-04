import 'dart:convert';
import 'package:defect_report_mobile/Models/breakdown_model.dart';
import 'package:http/http.dart' as http;
import 'package:defect_report_mobile/Models/chart_data_model.dart';
import 'package:defect_report_mobile/Models/defect_report_model.dart';
import 'package:defect_report_mobile/Services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServices {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ApiAuth/login'),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      final expired =
          DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch;
      await prefs.setInt('token_expired', expired);

      return null;
    } else {
      return 'Invalid email or password';
    }
  }

  static Future<String?> register(String name, String email, String role,
      String password, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ApiAuth/register'),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'role': role,
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );
    if (response.statusCode == 200) {
      return null;
    } else if (response.statusCode == 400) {
      try {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['error'] ?? 'Failed';
      } catch (e) {
        return 'Error: ${e.toString()}';
      }
    } else {
      return 'Request failed with status: ${response.statusCode}';
    }
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/api/ApiProfile/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future<String?> changePassword(
      String currentPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return "No token found";

    final response = await http.post(
      Uri.parse('$baseUrl/api/ApiProfile/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<List<DefectReport>> getDefectReports() async {
    final response = await http.get(Uri.parse('$baseUrl/api/defect/all'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => DefectReport.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<Map<String, dynamic>> getReportById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/defect/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load report');
  }

  static Future<int> addDefect(String defectName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/defect/add-defect'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"defectName": defectName}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['defectId'];
    } else {
      throw Exception('Failed to add defect');
    }
  }

  static Future<bool> addDefectReport(DefectReport report) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/defect/add-report'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(report.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateDefectReport(DefectReport report) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/defect/update/${report.reportId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(report.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteReport(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/api/defect/delete/$id'));
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> getDropdownData() async {
    final response = await http.get(Uri.parse('$baseUrl/api/defect/dropdown'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dropdown data');
    }
  }

  static Future<List<BreakdownItem>> fetchBreakdown(
      String timePeriod, String label) async {
    final uri = Uri.parse(
        '$baseUrl/api/defect/mobile-breakdown?timePeriod=$timePeriod&label=$label');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => BreakdownItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load breakdown data');
    }
  }

  static Future<DefectChartResponse> fetchChartData(String period) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/defect/chart?timePeriod=$period'));

    if (response.statusCode == 200) {
      return DefectChartResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load chart data');
    }
  }
}
