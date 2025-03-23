import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:faculty_attendance_app/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Delay for a smoother splash experience
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.isAuthenticated) {
      // If already authenticated, go to home screen
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // Otherwise, go to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            const Icon(
              Icons.school,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            // App name
            const Text(
              'Faculty Attendance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            // Loading text
            const Text(
              'Loading...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}