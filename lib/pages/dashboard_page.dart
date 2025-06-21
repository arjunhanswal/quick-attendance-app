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
  int presentToday = 0;
  int absentToday = 0;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<UserModel>(Boxes.userBox);
    attendanceBox = Hive.box<AttendanceModel>(Boxes.attendanceBox);
    calculateStats();
  }

  void calculateStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayAttendances = attendanceBox.values.where((record) {
      final recordDate = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      return recordDate == today;
    }).toList();

    setState(() {
      totalUsers = userBox.length;
      presentToday = todayAttendances.length;
      absentToday = totalUsers - presentToday;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCard('Total Sewadars', totalUsers, Colors.deepPurple),
            SizedBox(height: 10),
            _buildStatCard('Present Today', presentToday, Colors.green),
            SizedBox(height: 10),
            _buildStatCard('Absent Today', absentToday, Colors.red),
            SizedBox(height: 30),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionTile('Attendance', Icons.check, '/attendance'),
                _buildActionTile('Report', Icons.bar_chart, '/report'),
                _buildActionTile('Add Sewadar', Icons.person_add, '/add-user'),
                _buildActionTile('Sewadar List', Icons.people, '/user-list'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
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

  Widget _buildActionTile(String label, IconData icon, String route) {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context, route);
        calculateStats(); // Refresh stats when returning
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 150,
          height: 100,
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30),
              SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
