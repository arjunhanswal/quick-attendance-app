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

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
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
      appBar: AppBar(title: Text("Attendance Report")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickDateRange(context),
                icon: Icon(Icons.date_range),
                label: Text(_startDate == null
                    ? "Pick Date"
                    : "Filter: ${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM').format(_endDate!)}"),
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
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                final user = userBox.values.firstWhere(
                  (u) => u.userId == record.userId,
                  orElse: () => UserModel(
                      name: 'Unknown', userId: '', center: '', department: ''),
                );
                final timeStr = DateFormat('HH:mm').format(record.timestamp);
                final dateStr =
                    DateFormat('yyyy-MM-dd').format(record.timestamp);
                return ListTile(
                  title: Text('${user.name} • $timeStr'),
                  subtitle: Text('ID: ${user.userId}, Date: $dateStr'),
                  trailing: Text(user.center),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
