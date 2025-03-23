import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:faculty_attendance_app/models/class_model.dart';
import 'package:faculty_attendance_app/models/student_model.dart';
import 'package:faculty_attendance_app/services/api_service.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late ClassModel classModel;
  List<StudentModel> students = [];
  bool isLoading = true;
  bool isSubmitting = false;
  String errorMessage = '';
  DateTime selectedDate = DateTime.now();
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get class data from route arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    classModel = args['class'] as ClassModel;
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final loadedStudents = await apiService.getStudents(classModel.id);
      setState(() {
        students = loadedStudents;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students to mark attendance for')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = '';
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final presentStudentIds = students
          .where((student) => student.isPresent)
          .map((student) => student.id)
          .toList();

      final success = await apiService.submitAttendance(
        classModel.id,
        dateFormatter.format(selectedDate),
        presentStudentIds,
      );

      setState(() {
        isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance submitted successfully')),
        );
        // Navigate back to class screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage')),
      );
    }
  }

  void _toggleStudentPresence(int index) {
    setState(() {
      students[index].isPresent = !students[index].isPresent;
    });
  }

  void _markAllPresent() {
    setState(() {
      for (var student in students) {
        student.isPresent = true;
      }
    });
  }

  void _markAllAbsent() {
    setState(() {
      for (var student in students) {
        student.isPresent = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance: ${classModel.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selection bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${dateFormatter.format(selectedDate)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Change Date'),
                ),
              ],
            ),
          ),
          // Quick actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _markAllPresent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark All Present'),
                ),
                ElevatedButton(
                  onPressed: _markAllAbsent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark All Absent'),
                ),
              ],
            ),
          ),
          // Error message
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          // Student list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : students.isEmpty
                    ? const Center(child: Text('No students found'))
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(student.name.substring(0, 1)),
                            ),
                            title: Text(student.name),
                            subtitle: Text('Roll Number: ${student.rollNumber}'),
                            trailing: Switch(
                              value: student.isPresent,
                              onChanged: (_) => _toggleStudentPresence(index),
                              activeColor: Colors.green,
                            ),
                            onTap: () => _toggleStudentPresence(index),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSubmitting ? null : _submitAttendance,
        icon: const Icon(Icons.save),
        label: isSubmitting
            ? const Text('Submitting...')
            : const Text('Submit Attendance'),
      ),
    );
  }
}