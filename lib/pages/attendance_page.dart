// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class AttendancePage extends StatefulWidget {
//   const AttendancePage({super.key});

//   @override
//   State<AttendancePage> createState() => _AttendancePageState();
// }

// class _AttendancePageState extends State<AttendancePage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   List<Map<String, dynamic>> _users = [];
//   List<Map<String, dynamic>> _filteredUsers = [];
//   List<Map<String, dynamic>> _todayAttendance = [];
//   Map<String, dynamic>? _selectedUser;
//   TimeOfDay? _selectedTime;
//   final _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     fetchUsers();
//     fetchTodayAttendance();

//     _searchController.addListener(() {
//       final query = _searchController.text.toLowerCase();
//       setState(() {
//         _filteredUsers = _users.where((u) {
//           return u['name'].toString().toLowerCase().contains(query) ||
//               u['userid'].toString().toLowerCase().contains(query);
//         }).toList();
//       });
//     });
//   }

//   Future<void> fetchUsers() async {
//     final response = await Supabase.instance.client
//         .from('users')
//         .select()
//         .order('name', ascending: true);

//     setState(() {
//       _users = (response as List).cast<Map<String, dynamic>>();
//       _filteredUsers = List.from(_users);
//     });
//   }

//   Future<void> fetchTodayAttendance() async {
//     final now = DateTime.now();
//     final start = DateTime(now.year, now.month, now.day);
//     final end = start.add(const Duration(days: 1));

//     final response = await Supabase.instance.client
//         .from('attendance')
//         .select('*, users!inner(*)') // join to get user details
//         .gte('timestamp', start.toIso8601String())
//         .lt('timestamp', end.toIso8601String());

//     setState(() {
//       _todayAttendance = (response as List).cast<Map<String, dynamic>>();
//     });
//   }

//   Future<void> _pickTime(BuildContext context) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null) setState(() => _selectedTime = picked);
//   }

//   Future<void> _submitAttendance() async {
//     if (_selectedUser == null) {
//       _showMsg('Please select a user');
//       return;
//     }

//     final now = DateTime.now();
//     final timestamp = _selectedTime != null
//         ? DateTime(now.year, now.month, now.day, _selectedTime!.hour,
//             _selectedTime!.minute)
//         : now;

//     final alreadyMarked = _todayAttendance
//         .any((record) => record['userid'] == _selectedUser!['userid']);
//     if (alreadyMarked) {
//       _showMsg('${_selectedUser!['name']} is already marked.');
//       return;
//     }

//     final weekStart = now.subtract(Duration(days: now.weekday % 7));

//     try {
//       await Supabase.instance.client.from('attendance').insert({
//         'userid': _selectedUser!['userid'],
//         'timestamp': timestamp.toIso8601String(),
//         'week_start': weekStart.toIso8601String(),
//       });
//       _showMsg('Attendance marked for ${_selectedUser!['name']}');
//       setState(() {
//         _selectedUser = null;
//         _selectedTime = null;
//         _searchController.clear();
//         _filteredUsers = List.from(_users);
//       });
//       fetchTodayAttendance();
//     } catch (e) {
//       _showMsg('Failed to mark attendance: $e');
//     }
//   }

//   Future<void> _deleteAttendance(String attendanceId) async {
//     try {
//       await Supabase.instance.client
//           .from('attendance')
//           .delete()
//           .eq('id', attendanceId);
//       _showMsg('Attendance deleted');
//       fetchTodayAttendance();
//     } catch (e) {
//       _showMsg('Failed to delete: $e');
//     }
//   }

//   void _showMsg(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   bool _isUserMarked(String userid) {
//     return _todayAttendance.any((record) => record['userid'] == userid);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Attendance'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(icon: Icon(Icons.person_add), text: "Mark Attendance"),
//             Tab(icon: Icon(Icons.today), text: "Today"),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           // Tab 1: Mark Attendance
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 TextField(
//                   controller: _searchController,
//                   decoration: const InputDecoration(
//                     hintText: 'Search user by name or ID',
//                     prefixIcon: Icon(Icons.search),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: _filteredUsers.length,
//                     itemBuilder: (context, index) {
//                       final user = _filteredUsers[index];
//                       final isSelected =
//                           _selectedUser?['userid'] == user['userid'];
//                       final isMarked = _isUserMarked(user['userid']);
//                       return Card(
//                         child: ListTile(
//                           title: Text(user['name'] ?? 'Unknown'),
//                           subtitle: Text(
//                               'ID: ${user['userid']} | Center: ${user['center'] ?? ''}'),
//                           tileColor:
//                               isSelected ? Colors.blue.withOpacity(0.1) : null,
//                           trailing: isMarked
//                               ? const Icon(Icons.check_circle,
//                                   color: Colors.green)
//                               : null,
//                           onTap: () => setState(() => _selectedUser = user),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _pickTime(context),
//                   child: Text(_selectedTime == null
//                       ? 'Select Time'
//                       : 'Time: ${_selectedTime!.format(context)}'),
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: _submitAttendance,
//                   child: const Text('Submit Attendance'),
//                   style: ElevatedButton.styleFrom(
//                       minimumSize: const Size.fromHeight(45)),
//                 ),
//               ],
//             ),
//           ),

//           // Tab 2: Today’s Attendance
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: _todayAttendance.isEmpty
//                 ? const Center(child: Text('No attendance today'))
//                 : ListView.builder(
//                     itemCount: _todayAttendance.length,
//                     itemBuilder: (context, index) {
//                       final record = _todayAttendance[index];
//                       final userName = record['users']?['name'] ?? 'Unknown';
//                       final time = TimeOfDay.fromDateTime(
//                               DateTime.parse(record['timestamp']))
//                           .format(context);

//                       return Card(
//                         child: ListTile(
//                           title: Text(userName),
//                           subtitle: Text('Marked at: $time'),
//                           leading: const Icon(Icons.check, color: Colors.green),
//                           trailing: IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () =>
//                                 _deleteAttendance(record['id'].toString()),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  List<Map<String, dynamic>> _todayAttendance = [];
  Map<String, dynamic>? _selectedUser;
  TimeOfDay? _selectedTime;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUsers();
    fetchTodayAttendance();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredUsers = _users.where((u) {
          return u['name'].toString().toLowerCase().contains(query) ||
              u['userid'].toString().toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  Future<void> fetchUsers() async {
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .order('name', ascending: true);

    setState(() {
      _users = (response as List).cast<Map<String, dynamic>>();
      _filteredUsers = List.from(_users);
    });
  }

  Future<void> fetchTodayAttendance() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final response = await Supabase.instance.client
        .from('attendance')
        .select('*, users!inner(*)') // join to get user details
        .gte('timestamp', start.toIso8601String())
        .lt('timestamp', end.toIso8601String());

    setState(() {
      _todayAttendance = (response as List).cast<Map<String, dynamic>>();
    });
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submitAttendance() async {
    if (_selectedUser == null) {
      _showMsg('Please select a user');
      return;
    }

    final now = DateTime.now();
    final timestamp = _selectedTime != null
        ? DateTime(now.year, now.month, now.day, _selectedTime!.hour,
            _selectedTime!.minute)
        : now;

    final alreadyMarked = _isUserMarked(_selectedUser!['userid']);
    if (alreadyMarked) {
      _showMsg('${_selectedUser!['name']} is already marked.');
      return;
    }

    final weekStart = now.subtract(Duration(days: now.weekday % 7));

    try {
      await Supabase.instance.client.from('attendance').insert({
        'userid': _selectedUser!['userid'],
        'timestamp': timestamp.toIso8601String(),
        'week_start': weekStart.toIso8601String(),
      });
      _showMsg('Attendance marked for ${_selectedUser!['name']}');
      setState(() {
        _selectedUser = null;
        _selectedTime = null;
        _searchController.clear();
        _filteredUsers = List.from(_users);
      });
      fetchTodayAttendance();
    } catch (e) {
      _showMsg('Failed to mark attendance: $e');
    }
  }

  Future<void> _deleteAttendance(String attendanceId) async {
    try {
      await Supabase.instance.client
          .from('attendance')
          .delete()
          .eq('id', attendanceId);
      _showMsg('Attendance deleted');
      fetchTodayAttendance();
    } catch (e) {
      _showMsg('Failed to delete: $e');
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _isUserMarked(String userid) {
    return _todayAttendance
        .any((record) => record['users']?['userid'] == userid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
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
                  decoration: const InputDecoration(
                    hintText: 'Search user by name or ID',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final isSelected =
                          _selectedUser?['userid'] == user['userid'];
                      final isMarked = _isUserMarked(user['userid']);

                      Color? bgColor;
                      if (isSelected) {
                        bgColor = Colors.blue.withOpacity(0.3); // selected user
                      } else if (isMarked) {
                        bgColor =
                            Colors.green.withOpacity(0.2); // already marked
                      }

                      return Card(
                        color: bgColor,
                        child: ListTile(
                          title: Text(user['name'] ?? 'Unknown'),
                          subtitle: Text(
                              'ID: ${user['user_id_card']} | Center: ${user['center'] ?? ''}'),
                          trailing: isMarked
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : null,
                          onTap: () => setState(() => _selectedUser = user),
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
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _submitAttendance,
                  child: const Text('Submit Attendance'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45)),
                ),
              ],
            ),
          ),

          // Tab 2: Today’s Attendance
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _todayAttendance.isEmpty
                ? const Center(child: Text('No attendance today'))
                : ListView.builder(
                    itemCount: _todayAttendance.length,
                    itemBuilder: (context, index) {
                      final record = _todayAttendance[index];
                      final userName = record['users']?['name'] ?? 'Unknown';
                      final time = TimeOfDay.fromDateTime(
                              DateTime.parse(record['timestamp']))
                          .format(context);

                      return Card(
                        child: ListTile(
                          title: Text(userName),
                          subtitle: Text('Marked at: $time'),
                          leading: const Icon(Icons.check, color: Colors.green),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteAttendance(record['id'].toString()),
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
