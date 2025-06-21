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
  DateTime? _startDate;
  DateTime? _endDate;

  List<AttendanceModel> getFilteredRecords() {
    final box = Hive.box<AttendanceModel>(Boxes.attendanceBox);
    final records = box.values.where((record) {
      if (_startDate != null && _endDate != null) {
        return record.timestamp
                .isAfter(_startDate!.subtract(Duration(days: 1))) &&
            record.timestamp.isBefore(_endDate!.add(Duration(days: 1)));
      }
      return true;
    }).toList();
    records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return records;
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _endDate = picked;
      });
    }
  }

  Map<String, List<AttendanceModel>> groupByWeek(
      List<AttendanceModel> records) {
    Map<String, List<AttendanceModel>> grouped = {};

    for (var record in records) {
      // Week starts on Sunday
      DateTime weekStart = record.timestamp
          .subtract(Duration(days: record.timestamp.weekday % 7));
      String weekLabel = DateFormat('yyyy-MM-dd').format(weekStart);

      if (!grouped.containsKey(weekLabel)) {
        grouped[weekLabel] = [];
      }
      grouped[weekLabel]!.add(record);
    }

    return grouped;
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

    final directory = await getTemporaryDirectory(); // temporary so share works
    final path =
        '${directory.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    String csv = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csv);

    // 🔥 Share directly
    await Share.shareXFiles([XFile(file.path)],
        text: 'Here is the exported attendance report CSV');

    // ✅ Also optional: show local path in SnackBar
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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickDate(context),
                icon: Icon(Icons.date_range),
                label: Text(_startDate == null
                    ? "Pick Date"
                    : "Filter: ${DateFormat('dd MMM yyyy').format(_startDate!)}"),
              ),
              ElevatedButton.icon(
                onPressed: () => _exportToCSV(records),
                icon: Icon(Icons.download),
                label: Text("Export CSV"),
              ),
            ],
          ),
          SizedBox(height: 10),
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
