import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:faculty_attendance_app/models/class_model.dart';
import 'package:faculty_attendance_app/services/api_service.dart';
import 'package:faculty_attendance_app/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ClassModel> classes = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final loadedClasses = await apiService.getClasses();
      setState(() {
        classes = loadedClasses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _navigateToAttendance(ClassModel classModel) {
    Navigator.of(context).pushNamed(
      '/attendance',
      arguments: {'class': classModel},
    );
  }

  void _navigateToReport(ClassModel classModel) {
    Navigator.of(context).pushNamed(
      '/report',
      arguments: {'class': classModel},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClasses,
            tooltip: 'Refresh Classes',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $errorMessage',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadClasses,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : classes.isEmpty
                  ? const Center(child: Text('No classes found'))
                  : ListView.builder(
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final classModel = classes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(classModel.name.substring(0, 1)),
                            ),
                            title: Text(classModel.name),
                            subtitle: Text('Strength: ${classModel.strength}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      _navigateToAttendance(classModel),
                                  tooltip: 'Take Attendance',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.bar_chart,
                                      color: Colors.green),
                                  onPressed: () =>
                                      _navigateToReport(classModel),
                                  tooltip: 'View Report',
                                ),
                              ],
                            ),
                            onTap: () => _navigateToAttendance(classModel),
                          ),
                        );
                      },
                    ),
    );
  }
}