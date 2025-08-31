// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   int totalUsers = 0;
//   int presentCount = 0;
//   int absentCount = 0;

//   DateTime selectedDate = DateTime.now();
//   List<Map<String, dynamic>> todaysAttendance = [];

//   @override
//   void initState() {
//     super.initState();
//     calculateStats();
//   }

//   Future<void> calculateStats() async {
//     final client = Supabase.instance.client;

//     // 🔹 1. Fetch total users
//     final userResponse = await client.from('users').select();
//     final allUsers = userResponse as List;
//     totalUsers = allUsers.length;

//     // 🔹 2. Fetch attendance for the selected date
//     final dateOnly =
//         DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

//     final nextDay = dateOnly.add(const Duration(days: 1));

//     final attendanceResponse = await client
//         .from('attendance')
//         .select()
//         .gte('timestamp', dateOnly.toIso8601String())
//         .lt('timestamp', nextDay.toIso8601String());

//     final dayAttendances = attendanceResponse as List;

//     presentCount = dayAttendances.length;
//     absentCount = totalUsers - presentCount;
//     todaysAttendance = dayAttendances.cast<Map<String, dynamic>>();

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2024),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() => selectedDate = picked);
//       calculateStats();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final formattedDate = DateFormat.yMMMMd().format(selectedDate);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Dashboard"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: calculateStats,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // 📅 Date Display & Picker
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Showing data for:",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 TextButton.icon(
//                   icon: const Icon(Icons.calendar_today),
//                   label: Text(DateFormat('EEE, MMM d').format(selectedDate)),
//                   onPressed: _pickDate,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),

//             // 📊 Cards
//             _buildStatCard('Total Sewadars', totalUsers, Colors.deepPurple),
//             const SizedBox(height: 10),
//             _buildStatCard('Present', presentCount, Colors.green),
//             const SizedBox(height: 10),
//             _buildStatCard('Absent', absentCount, Colors.red),
//             const SizedBox(height: 30),

//             // 📋 Attendance Preview
//             Text(
//               'Present on $formattedDate',
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 10),

//             ...todaysAttendance.map((record) {
//               // final name = record['name'];
//               // final time =
//               //     TimeOfDay.fromDateTime(DateTime.parse(record['timestamp']))
//               //         .format(context);

//               // // 🔹 Try to fetch user details from joined `users` table
//               // return ListTile(
//               //   leading: const Icon(Icons.person, color: Colors.green),
//               //   title: Text(record['name'] ?? 'User $name'),
//               //   subtitle: Text("Marked at: $time"),
//               // );
//               final userName = record['users'] != null
//                   ? record['users']['name'] ?? 'Unknown'
//                   : 'Unknown';

//               final time =
//                   TimeOfDay.fromDateTime(DateTime.parse(record['timestamp']))
//                       .format(context);

//               return ListTile(
//                 leading: const Icon(Icons.person, color: Colors.green),
//                 title: Text(userName),
//                 subtitle: Text("Marked at: $time"),
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(String label, int count, Color color) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label,
//                 style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600)),
//             const SizedBox(height: 10),
//             Text(count.toString(),
//                 style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white)),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalUsers = 0;
  int presentCount = 0;
  int absentCount = 0;

  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> todaysAttendance = [];

  @override
  void initState() {
    super.initState();
    calculateStats();
  }

  Future<void> calculateStats() async {
    final client = Supabase.instance.client;

    // 1️⃣ Fetch total users
    final userResponse = await client.from('users').select();
    final allUsers = userResponse as List;
    totalUsers = allUsers.length;

    // 2️⃣ Fetch attendance for the selected date with user details
    final dateOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final nextDay = dateOnly.add(const Duration(days: 1));

    final attendanceResponse = await client
        .from('attendance')
        .select('*, users!inner(*)') // join users table
        .gte('timestamp', dateOnly.toIso8601String())
        .lt('timestamp', nextDay.toIso8601String());

    final dayAttendances = attendanceResponse as List;

    presentCount = dayAttendances.length;
    absentCount = totalUsers - presentCount;
    todaysAttendance = dayAttendances.cast<Map<String, dynamic>>();

    if (mounted) setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      calculateStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMMd().format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: calculateStats,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 📅 Date Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Showing data for:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('EEE, MMM d').format(selectedDate)),
                  onPressed: _pickDate,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 📊 Stats Cards
            _buildStatCard('Total Sewadars', totalUsers, Colors.deepPurple),
            const SizedBox(height: 10),
            _buildStatCard('Present', presentCount, Colors.green),
            const SizedBox(height: 10),
            _buildStatCard('Absent', absentCount, Colors.red),
            const SizedBox(height: 30),

            // 📋 Attendance Preview
            Text(
              'Present on $formattedDate',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            ...todaysAttendance.map((record) {
              final user = record['users'];
              final userName = user?['name'] ?? 'Unknown';
              final userCenter = user?['center'] ?? 'Unknown';
              final userDept = user?['department'] ?? 'Unknown';
              final timestamp = DateTime.parse(record['timestamp']);
              final time = DateFormat.jm().format(timestamp);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.green),
                  title: Text(userName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Marked at: $time'),
                      Text('Center: $userCenter | Dept: $userDept'),
                    ],
                  ),
                ),
              );
            }).toList(),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(count.toString(),
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
