import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/attendance.dart';
import '../utils/hive_boxes.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Box<UserModel> _userBox;
  late Box<AttendanceModel> _attendanceBox;

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  UserModel? _selectedUser;
  TimeOfDay? _selectedTime;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userBox = Hive.box<UserModel>(Boxes.userBox);
    _attendanceBox = Hive.box<AttendanceModel>(Boxes.attendanceBox);
    _allUsers = _userBox.values.toList();
    _filteredUsers = _allUsers;

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredUsers = _allUsers.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.userId.toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  List<AttendanceModel> _getTodayAttendance() {
    final today = DateTime.now();
    return _attendanceBox.values.where((record) {
      return record.timestamp.year == today.year &&
          record.timestamp.month == today.month &&
          record.timestamp.day == today.day;
    }).toList();
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitAttendance() {
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a user')),
      );
      return;
    }

    final now = DateTime.now();
    final selectedDateTime = _selectedTime != null
        ? DateTime(now.year, now.month, now.day, _selectedTime!.hour,
            _selectedTime!.minute)
        : now;

    final weekStart = now.subtract(Duration(days: now.weekday % 7));

    _attendanceBox.add(AttendanceModel(
      userId: _selectedUser!.userId,
      timestamp: selectedDateTime,
      weekStart: weekStart,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attendance recorded for ${_selectedUser!.name}')),
    );

    // Clear selection
    setState(() {
      _selectedUser = null;
      _selectedTime = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name or ID',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 10),
            // 🧑‍🦱 User list
            Expanded(
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle:
                        Text('ID: ${user.userId}, Center: ${user.center}'),
                    trailing: _selectedUser?.userId == user.userId
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedUser = user;
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            // ⏰ Time Picker
            ElevatedButton(
              onPressed: () => _pickTime(context),
              child: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : 'Time: ${_selectedTime!.format(context)}',
              ),
            ),
            SizedBox(height: 10),
            // ✅ Submit Button
            ElevatedButton(
              onPressed: _submitAttendance,
              child: Text('Submit Attendance'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(45)),
            ),
            SizedBox(height: 20),
            Text('Today\'s Attendance',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: _getTodayAttendance().map((record) {
                  final user = _userBox.values.firstWhere(
                    (u) => u.userId == record.userId,
                    orElse: () => UserModel(
                        name: 'Unknown',
                        userId: '',
                        center: '',
                        department: ''),
                  );
                  final time =
                      TimeOfDay.fromDateTime(record.timestamp).format(context);
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text('Marked at: $time'),
                    leading: Icon(Icons.check, color: Colors.green),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
