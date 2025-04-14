import 'dart:convert';
import 'package:defect_report_mobile/Models/defect_report_model.dart';
import 'package:http/http.dart' as http;
import 'package:defect_report_mobile/Services/api_config.dart';

class ApiServices {
  static final String baseUrl = ApiConfig.baseUrl;

  static Future<List<DefectReport>> getDefectReports() async {
    final response = await http.get(Uri.parse(baseUrl + '/all'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => DefectReport.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<Map<String, dynamic>> getReportById(int id) async {
    final response = await http.get(Uri.parse(baseUrl + '$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load report');
  }

  static Future<bool> addDefectReport(DefectReport report) async {
    final response = await http.post(
      Uri.parse(baseUrl + '/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(report.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateDefectReport(DefectReport report) async {
    final response = await http.post(
      Uri.parse(baseUrl + '/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(report.toJson()),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteReport(int id) async {
    final response = await http.delete(Uri.parse(baseUrl + '/delete/$id'));
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> getDropdownData() async {
    final response = await http.get(Uri.parse(baseUrl + '/dropdown'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dropdown data');
    }
  }

  static Future<Map<String, dynamic>> getChartData({
    int? lineProductionId,
    String timePeriod = 'daily',
  }) async {
    String query = '?timePeriod=$timePeriod';
    if (lineProductionId != null) {
      query += '&lineProductionId=$lineProductionId';
    }

    final response = await http.get(Uri.parse('$baseUrl/chart$query'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load chart data');
  }
}
