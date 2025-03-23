import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:faculty_attendance_app/services/auth_service.dart';
import 'package:faculty_attendance_app/services/api_service.dart';
import 'package:faculty_attendance_app/screens/splash_screen.dart';
import 'package:faculty_attendance_app/screens/login_screen.dart';
import 'package:faculty_attendance_app/screens/home_screen.dart';
import 'package:faculty_attendance_app/screens/class_screen.dart';
import 'package:faculty_attendance_app/screens/attendance_screen.dart';
import 'package:faculty_attendance_app/screens/report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final authService = AuthService();
  await authService.init();
  
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  
  const MyApp({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        ProxyProvider<AuthService, ApiService>(
          update: (context, auth, _) => ApiService(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Faculty Attendance App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/class': (context) => const ClassScreen(),
          '/attendance': (context) => const AttendanceScreen(),
          '/report': (context) => const ReportScreen(),
        },
      ),
    );
  }
}