import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/attendance.dart';
import '../utils/hive_boxes.dart';

class AttendancePage extends StatefulWidget {
  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Box<UserModel> _userBox;
  late Box<AttendanceModel> _attendanceBox;

  List<UserModel> _users = [];
  UserModel? _selectedUser;
  TimeOfDay? _selectedTime;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userBox = Hive.box<UserModel>(Boxes.userBox);
    _attendanceBox = Hive.box<AttendanceModel>(Boxes.attendanceBox);
    _users = _userBox.values.toList();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _users = _userBox.values
            .where((u) =>
                u.name.toLowerCase().contains(query) ||
                u.userId.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  List<AttendanceModel> _getTodayAttendance() {
    final now = DateTime.now();
    return _attendanceBox.values.where((record) {
      return record.timestamp.year == now.year &&
          record.timestamp.month == now.month &&
          record.timestamp.day == now.day;
    }).toList();
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
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
      _showMsg('Please select a user');
      return;
    }

    final now = DateTime.now();
    final dateTime = _selectedTime != null
        ? DateTime(now.year, now.month, now.day, _selectedTime!.hour,
            _selectedTime!.minute)
        : now;

    final alreadyMarked = _getTodayAttendance()
        .any((record) => record.userId == _selectedUser!.userId);

    if (alreadyMarked) {
      _showMsg('${_selectedUser!.name} is already marked.');
      return;
    }

    final weekStart = now.subtract(Duration(days: now.weekday % 7));

    _attendanceBox.add(AttendanceModel(
      userId: _selectedUser!.userId,
      timestamp: dateTime,
      weekStart: weekStart,
    ));

    _showMsg('Attendance marked for ${_selectedUser!.name}');
    setState(() {
      _selectedUser = null;
      _selectedTime = null;
      _searchController.clear();
      _users = _userBox.values.toList();
    });
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _deleteAttendance(AttendanceModel record) {
    _attendanceBox.delete(record.key);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final todayRecords = _getTodayAttendance();

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.person_add), text: "Mark Attendance"),
            Tab(icon: Icon(Icons.today), text: "Today"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Mark Attendance
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search user by name or ID',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final isSelected = _selectedUser?.userId == user.userId;
                      return Card(
                        child: ListTile(
                          title: Text(user.name),
                          subtitle: Text(
                              'ID: ${user.userId} | Center: ${user.center}'),
                          tileColor:
                              isSelected ? Colors.blue.withOpacity(0.1) : null,
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedUser = user;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _pickTime(context),
                  child: Text(_selectedTime == null
                      ? 'Select Time'
                      : 'Time: ${_selectedTime!.format(context)}'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _submitAttendance,
                  child: Text('Submit Attendance'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(45)),
                ),
              ],
            ),
          ),

          // Tab 2: Today’s Attendance
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: todayRecords.isEmpty
                ? Center(child: Text('No attendance today'))
                : ListView.builder(
                    itemCount: todayRecords.length,
                    itemBuilder: (context, index) {
                      final record = todayRecords[index];
                      final user = _userBox.values.firstWhere(
                        (u) => u.userId == record.userId,
                        orElse: () => UserModel(
                            name: 'Unknown',
                            userId: '',
                            center: '',
                            department: ''),
                      );
                      final time = TimeOfDay.fromDateTime(record.timestamp)
                          .format(context);

                      return Card(
                        child: ListTile(
                          title: Text(user.name),
                          subtitle: Text('Marked at: $time'),
                          leading: Icon(Icons.check, color: Colors.green),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteAttendance(record),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
