import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:faculty_attendance_app/config/api_config.dart';
import 'package:faculty_attendance_app/models/class_model.dart';
import 'package:faculty_attendance_app/models/student_model.dart';
import 'package:faculty_attendance_app/services/auth_service.dart';

class ApiService {
  final AuthService _authService;

  ApiService(this._authService);

  // Helper method to create headers with authentication token
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_authService.token ?? ""}',
    };
  }

  // Fetch all classes available to the faculty
  Future<List<ClassModel>> getClasses() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/classes'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ClassModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await _authService.logout();
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to load classes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching classes: $e');
    }
  }

  // Fetch students for a specific class
  Future<List<StudentModel>> getStudents(String classId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/classes/$classId/students'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StudentModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching students: $e');
    }
  }

  // Submit attendance for a class
  Future<bool> submitAttendance(String classId, String date, List<String> presentStudentIds) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/attendance'),
        headers: _getHeaders(),
        body: json.encode({
          'classId': classId,
          'date': date,
          'presentStudents': presentStudentIds,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to submit attendance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting attendance: $e');
    }
  }

  // Get attendance report for a class within a date range
  Future<Map<String, dynamic>> getAttendanceReport(String classId, String fromDate, String toDate) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/attendance/$classId?fromDate=$fromDate&toDate=$toDate'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await _authService.logout();
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to get attendance report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching attendance report: $e');
    }
  }