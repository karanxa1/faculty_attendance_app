import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:faculty_attendance_app/config/api_config.dart';

class AuthService {
  String? _token;
  String? _role;
  
  String? get token => _token;
  String? get role => _role;
  bool get isAuthenticated => _token != null;
  bool get isFaculty => _role == 'faculty';

  // Initialize auth state from shared preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _role = prefs.getString('role');
  }

  // Login with username and password
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _role = data['role'];
        
        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('role', _role!);
        
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Logout and clear credentials
  Future<void> logout() async {
    _token = null;
    _role = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
  }

  // Refresh token if needed
  Future<bool> refreshToken() async {
    if (_token == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        
        // Update in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        
        return true;
      } else {
        // If refresh fails, logout
        await logout();
        return false;
      }
    } catch (e) {
      print('Token refresh error: $e');
      await logout();
      return false;
    }
  }
}