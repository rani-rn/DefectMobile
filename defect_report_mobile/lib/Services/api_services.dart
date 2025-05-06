import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:defect_report_mobile/Models/chart_data_model.dart';
import 'package:defect_report_mobile/Models/defect_report_model.dart';
import 'package:defect_report_mobile/Services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServices {
  static final String baseUrl = ApiConfig.baseUrl;


  static Future<String?> login (String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ApiAuth/login'),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({'email':email, 'password':password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return null;
    } else {
      return 'Invalid email or password';
    }
  }

  static Future<String?> register(String name, String email, String role, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ApiAuth/register'),
      headers: {'Content-type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'role': role,
        'password': password
      }),
    );
    if (response.statusCode == 200){
      return null;
    } else {
      return jsonDecode(response.body)['error'] ?? 'Failed';
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
    final response = await http.delete(Uri.parse('$baseUrl/api/defect/delete/$id'));
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

  static Future<Map<String, dynamic>> fetchChartData({
    int? lineProductionId,
    String timePeriod = 'daily',
  }) async {
    final uri = Uri.parse('$baseUrl/api/defect/chart').replace(queryParameters: {
      if (lineProductionId != null)
        'lineProductionId': lineProductionId.toString(),
      'timePeriod': timePeriod,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        "chartData": (data['chartData'] as List)
            .map((e) => DefectChartData.fromJson(e))
            .toList(),
        "daily": data["daily"],
        "weekly": data["weekly"],
        "monthly": data["monthly"],
        "annual": data["annual"],
      };
    } else {
      throw Exception('Failed to load chart data');
    }
  }
}
