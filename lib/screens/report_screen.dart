import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:faculty_attendance_app/models/class_model.dart';
import 'package:faculty_attendance_app/services/api_service.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late ClassModel classModel;
  bool isLoading = false;
  bool hasData = false;
  String errorMessage = '';
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime toDate = DateTime.now();
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
  Map<String, dynamic> reportData = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get class data from route arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    classModel = args['class'] as ClassModel;
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2020),
      lastDate: toDate,
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: fromDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      hasData = false;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getAttendanceReport(
        classModel.id,
        dateFormatter.format(fromDate),
        dateFormatter.format(toDate),
      );

      setState(() {
        reportData = data;
        isLoading = false;
        hasData = true;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report: ${classModel.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date range selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date Range',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('From Date:'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectFromDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(dateFormatter.format(fromDate)),
                                      const Icon(Icons.calendar_today, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('To Date:'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectToDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(dateFormatter.format(toDate)),
                                      const Icon(Icons.calendar_today, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _generateReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Generate Report'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Error message
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            // Report data
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (hasData)
              Expanded(
                child: _buildReportView(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportView() {
    if (reportData.isEmpty) {
      return const Center(child: Text('No data available for selected date range'));
    }

    // Check the structure of the report data and build the appropriate view
    if (reportData is List) {
      return ListView.builder(
        itemCount: reportData.length,
        itemBuilder: (context, index) {
          final record = reportData[index];
          if (record is Map && record.containsKey('date') && record.containsKey('attendance')) {
            final dates = record['date'] as List;
            final attendances = record['attendance'] as List;

            if (dates.isEmpty) {
              return const ListTile(
                title: Text('No attendance records found'),
              );
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text('Student ${index + 1}'),
                children: List.generate(
                  dates.length,
                  (i) => ListTile(
                    title: Text(dates[i].toString()),
                    trailing: Text(
                      attendances[i].toString().contains('Present')
                          ? 'Present'
                          : 'Absent',
                      style: TextStyle(
                        color: attendances[i].toString().contains('Present')
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
          return const ListTile(
            title: Text('Invalid data format'),
          );
        },
      );
    }

    // Default fallback view
    return const Center(child: Text('Unable to display report data'));
  }
}