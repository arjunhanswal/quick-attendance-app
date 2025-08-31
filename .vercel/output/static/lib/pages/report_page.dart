// // import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:csv/csv.dart';

// class ReportPage extends StatefulWidget {
//   const ReportPage({super.key});

//   @override
//   State<ReportPage> createState() => _ReportPageState();
// }

// class _ReportPageState extends State<ReportPage> {
//   Set<DateTime> _selectedDates = {};
//   List<Map<String, dynamic>> _attendanceRecords = [];
//   List<Map<String, dynamic>> _users = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchUsers();
//     fetchAttendance();
//   }

//   Future<void> fetchUsers() async {
//     final response = await Supabase.instance.client.from('users').select();
//     setState(() {
//       _users = (response as List).cast<Map<String, dynamic>>();
//     });
//   }

//   Future<void> fetchAttendance() async {
//     final response = await Supabase.instance.client
//         .from('attendance')
//         .select('*, users(*)'); // optional join to get user info
//     setState(() {
//       _attendanceRecords = (response as List).cast<Map<String, dynamic>>();
//     });
//   }

//   List<Map<String, dynamic>> getFilteredRecords() {
//     if (_selectedDates.isEmpty) return _attendanceRecords;

//     return _attendanceRecords.where((record) {
//       final date = DateTime.parse(record['timestamp']);
//       final dateOnly = DateTime(date.year, date.month, date.day);
//       return _selectedDates.contains(dateOnly);
//     }).toList()
//       ..sort((a, b) =>
//           DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));
//   }

//   Future<void> _pickDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2023),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       final pickedDateOnly = DateTime(picked.year, picked.month, picked.day);
//       setState(() {
//         if (_selectedDates.contains(pickedDateOnly)) {
//           _selectedDates.remove(pickedDateOnly);
//         } else {
//           _selectedDates.add(pickedDateOnly);
//         }
//       });
//     }
//   }

//   Future<void> _exportToCSV(List<Map<String, dynamic>> records) async {
//     List<List<String>> csvData = [
//       ['Name', 'User ID', 'Center', 'Department', 'Timestamp']
//     ];

//     for (var record in records) {
//       final user = record['users'] ?? {};
//       csvData.add([
//         user['name'] ?? 'Unknown',
//         user['userId'] ?? '',
//         user['center'] ?? '',
//         user['department'] ?? '',
//         DateFormat('yyyy-MM-dd HH:mm')
//             .format(DateTime.parse(record['timestamp'])),
//       ]);
//     }

//     final directory = await getTemporaryDirectory();
//     final path =
//         '${directory.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.csv';
//     final file = File(path);
//     String csv = const ListToCsvConverter().convert(csvData);
//     await file.writeAsString(csv);

//     await Share.shareXFiles([XFile(file.path)],
//         text: 'Here is the exported attendance report CSV');

//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       content: Text('Exported and ready to share!'),
//       duration: Duration(seconds: 2),
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final records = getFilteredRecords();

//     return Scaffold(
//       appBar: AppBar(title: const Text("Attendance Report")),
//       body: Column(
//         children: [
//           const SizedBox(height: 10),

//           // 🔘 Filter Buttons
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Row(
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () => _pickDate(context),
//                   icon: const Icon(Icons.date_range),
//                   label: const Text("Select Date"),
//                 ),
//                 const SizedBox(width: 10),
//                 ElevatedButton.icon(
//                   onPressed: () => _exportToCSV(records),
//                   icon: const Icon(Icons.download),
//                   label: const Text("Export CSV"),
//                 ),
//                 const Spacer(),
//                 if (_selectedDates.isNotEmpty)
//                   TextButton(
//                     onPressed: () {
//                       setState(() {
//                         _selectedDates.clear();
//                       });
//                     },
//                     child: const Text("Clear"),
//                   ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 10),

//           // 📅 Selected Dates Chips
//           if (_selectedDates.isNotEmpty)
//             Wrap(
//               spacing: 8,
//               runSpacing: 4,
//               children: _selectedDates.map((date) {
//                 return Chip(
//                   label: Text(DateFormat('dd MMM').format(date)),
//                   deleteIcon: const Icon(Icons.close),
//                   onDeleted: () {
//                     setState(() {
//                       _selectedDates.remove(date);
//                     });
//                   },
//                 );
//               }).toList(),
//             ),

//           const SizedBox(height: 10),

//           // 📊 Attendance Table
//           Expanded(
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: SingleChildScrollView(
//                 child: DataTable(
//                   columns: const [
//                     DataColumn(label: Text('Name')),
//                     DataColumn(label: Text('User ID')),
//                     DataColumn(label: Text('Center')),
//                     DataColumn(label: Text('Department')),
//                     DataColumn(label: Text('Date')),
//                     DataColumn(label: Text('Time')),
//                   ],
//                   rows: records.map((record) {
//                     final user = record['users'] ?? {};
//                     final timestamp = DateTime.parse(record['timestamp']);
//                     final dateStr = DateFormat('yyyy-MM-dd').format(timestamp);
//                     final timeStr = DateFormat('HH:mm').format(timestamp);

//                     return DataRow(cells: [
//                       DataCell(Text(user['name'] ?? 'Unknown')),
//                       DataCell(Text(user['userId'] ?? '')),
//                       DataCell(Text(user['center'] ?? '')),
//                       DataCell(Text(user['department'] ?? '')),
//                       DataCell(Text(dateStr)),
//                       DataCell(Text(timeStr)),
//                     ]);
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coming Soon'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.construction,
              size: 80,
              color: Colors.orange,
            ),
            SizedBox(height: 20),
            Text(
              'This feature is coming soon!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Stay tuned for updates.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
