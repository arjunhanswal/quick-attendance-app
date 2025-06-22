import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../models/attendance.dart';
import '../models/user.dart';
import '../utils/hive_boxes.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  Set<DateTime> _selectedDates = {};

  List<AttendanceModel> getFilteredRecords() {
    final box = Hive.box<AttendanceModel>(Boxes.attendanceBox);
    if (_selectedDates.isEmpty) return box.values.toList();

    return box.values.where((record) {
      final date = DateTime(
          record.timestamp.year, record.timestamp.month, record.timestamp.day);
      return _selectedDates.contains(date);
    }).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final pickedDateOnly = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        if (_selectedDates.contains(pickedDateOnly)) {
          _selectedDates.remove(pickedDateOnly);
        } else {
          _selectedDates.add(pickedDateOnly);
        }
      });
    }
  }

  Future<void> _exportToCSV(List<AttendanceModel> records) async {
    final userBox = Hive.box<UserModel>(Boxes.userBox);
    List<List<String>> csvData = [
      ['Name', 'User ID', 'Center', 'Department', 'Timestamp']
    ];

    for (var record in records) {
      final user = userBox.values.firstWhere(
        (u) => u.userId == record.userId,
        orElse: () =>
            UserModel(name: 'Unknown', userId: '', center: '', department: ''),
      );

      csvData.add([
        user.name,
        user.userId,
        user.center,
        user.department,
        DateFormat('yyyy-MM-dd HH:mm').format(record.timestamp),
      ]);
    }

    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    String csv = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)],
        text: 'Here is the exported attendance report CSV');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Exported and ready to share!'),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final records = getFilteredRecords();
    final userBox = Hive.box<UserModel>(Boxes.userBox);

    return Scaffold(
      appBar: AppBar(title: Text("Attendance Report")),
      body: Column(
        children: [
          SizedBox(height: 10),

          // 🔘 Filter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: Icon(Icons.date_range),
                  label: Text("Select Date"),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _exportToCSV(records),
                  icon: Icon(Icons.download),
                  label: Text("Export CSV"),
                ),
                Spacer(),
                if (_selectedDates.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDates.clear();
                      });
                    },
                    child: Text("Clear"),
                  ),
              ],
            ),
          ),

          SizedBox(height: 10),

          // 📅 Selected Dates Chips
          if (_selectedDates.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _selectedDates.map((date) {
                return Chip(
                  label: Text(DateFormat('dd MMM').format(date)),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _selectedDates.remove(date);
                    });
                  },
                );
              }).toList(),
            ),

          SizedBox(height: 10),

          // 📊 Attendance Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('User ID')),
                    DataColumn(label: Text('Center')),
                    DataColumn(label: Text('Department')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Time')),
                  ],
                  rows: records.map((record) {
                    final user = userBox.values.firstWhere(
                      (u) => u.userId == record.userId,
                      orElse: () => UserModel(
                          name: 'Unknown',
                          userId: '',
                          center: '',
                          department: ''),
                    );

                    final dateStr =
                        DateFormat('yyyy-MM-dd').format(record.timestamp);
                    final timeStr =
                        DateFormat('HH:mm').format(record.timestamp);

                    return DataRow(cells: [
                      DataCell(Text(user.name)),
                      DataCell(Text(user.userId)),
                      DataCell(Text(user.center)),
                      DataCell(Text(user.department)),
                      DataCell(Text(dateStr)),
                      DataCell(Text(timeStr)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
