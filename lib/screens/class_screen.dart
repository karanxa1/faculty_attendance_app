import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:faculty_attendance_app/models/class_model.dart';
import 'package:faculty_attendance_app/services/api_service.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({Key? key}) : super(key: key);

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  late ClassModel classModel;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get class data from route arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    classModel = args['class'] as ClassModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class: ${classModel.name}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Class: ${classModel.name}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Students: ${classModel.strength}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/attendance',
                      arguments: {'class': classModel},
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Take Attendance'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/report',
                      arguments: {'class': classModel},
                    );
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('View Reports'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}