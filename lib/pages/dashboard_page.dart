import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/attendance.dart';
import '../utils/hive_boxes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Box<UserModel> userBox;
  late Box<AttendanceModel> attendanceBox;

  int totalUsers = 0;
  int presentCount = 0;
  int absentCount = 0;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<UserModel>(Boxes.userBox);
    attendanceBox = Hive.box<AttendanceModel>(Boxes.attendanceBox);
    calculateStats();
  }

  void calculateStats() {
    final dateOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    final dayAttendances = attendanceBox.values.where((record) {
      final recordDate = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      return recordDate == dateOnly;
    }).toList();

    setState(() {
      totalUsers = userBox.length;
      presentCount = dayAttendances.length;
      absentCount = totalUsers - presentCount;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      calculateStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMMd().format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: calculateStats,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 📅 Date Display & Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Showing data for:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: Icon(Icons.calendar_today),
                  label: Text(DateFormat('EEE, MMM d').format(selectedDate)),
                  onPressed: _pickDate,
                ),
              ],
            ),
            SizedBox(height: 10),

            // 📊 Cards
            _buildStatCard('Total Sewadars', totalUsers, Colors.deepPurple),
            SizedBox(height: 10),
            _buildStatCard('Present', presentCount, Colors.green),
            SizedBox(height: 10),
            _buildStatCard('Absent', absentCount, Colors.red),
            SizedBox(height: 30),

            // 📋 Attendance Preview
            Text(
              'Present on ${formattedDate}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            ...attendanceBox.values
                .where((record) =>
                    record.timestamp.year == selectedDate.year &&
                    record.timestamp.month == selectedDate.month &&
                    record.timestamp.day == selectedDate.day)
                .map((record) {
              final user = userBox.values.firstWhere(
                (u) => u.userId == record.userId,
                orElse: () => UserModel(
                  name: 'Unknown',
                  userId: '',
                  center: '',
                  department: '',
                ),
              );
              final time =
                  TimeOfDay.fromDateTime(record.timestamp).format(context);
              return ListTile(
                leading: Icon(Icons.person, color: Colors.green),
                title: Text(user.name),
                subtitle: Text("Marked at: $time"),
              );
            }).toList()
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            Text(count.toString(),
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
