// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'api_service.dart';
// import 'dart:convert';

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   int totalSewadars = 0;
//   int presentCount = 0;
//   int absentCount = 0;
//   DateTime selectedDate = DateTime.now();
//   List<Map<String, dynamic>> presentUsers = [];

//   @override
//   void initState() {
//     super.initState();
//     calculateStats();
//   }

//   Future<void> calculateStats() async {
//     try {
//       final dateStr = DateFormat("yyyy-MM-dd").format(selectedDate);

//       final response = await ApiService.post(
//         "/dashboard?from=$dateStr&to=$dateStr",
//         body: {},
//       );

//       final dashboard = Map<String, dynamic>.from(response ?? {});

//       setState(() {
//         totalSewadars =
//             dashboard['total_users'] is int ? dashboard['total_users'] : 0;
//         presentCount =
//             dashboard['present_count'] is int ? dashboard['present_count'] : 0;
//         absentCount = totalSewadars - presentCount;

//         final rawPresentUsers = dashboard['present_users'];
//         if (rawPresentUsers != null && rawPresentUsers is List) {
//           presentUsers = rawPresentUsers
//               .where((e) => e is Map)
//               .map((e) => Map<String, dynamic>.from(e as Map))
//               .toList();
//         } else {
//           presentUsers = [];
//         }
//       });
//     } catch (e) {
//       debugPrint("❌ Error loading dashboard: $e");
//       setState(() {
//         presentUsers = [];
//         totalSewadars = 0;
//         presentCount = 0;
//         absentCount = 0;
//       });
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
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: calculateStats,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // 📅 Date Row
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Showing data for: $formattedDate",
//                     style: const TextStyle(fontWeight: FontWeight.bold)),
//                 TextButton.icon(
//                   icon: const Icon(Icons.calendar_today),
//                   label: const Text("Change"),
//                   onPressed: _pickDate,
//                 ),
//               ],
//             ),
//           ),

//           // 📊 Stats in horizontal row
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Row(
//               children: [
//                 _buildStatCard("Total", totalSewadars, Colors.deepPurple),
//                 const SizedBox(width: 8),
//                 _buildStatCard("Present", presentCount, Colors.green),
//                 const SizedBox(width: 8),
//                 _buildStatCard("Absent", absentCount, Colors.red),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),

//           // 📋 Attendance header
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//             color: Colors.grey.shade300,
//             child: Row(
//               children: const [
//                 Expanded(
//                     flex: 2,
//                     child: Text("Name",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 13))),
//                 Expanded(
//                     flex: 1,
//                     child: Text("Badge",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 13))),
//                 Expanded(
//                     flex: 2,
//                     child: Text("Mobile",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 13))),
//                 Expanded(
//                     flex: 2,
//                     child: Text("Time",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 13))),
//                 Expanded(
//                     flex: 1,
//                     child: Text("Status",
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 13))),
//               ],
//             ),
//           ),

//           // 📋 Attendance list
//           Expanded(
//             child: presentUsers.isEmpty
//                 ? const Center(child: Text("⚠️ No one marked present"))
//                 : ListView.separated(
//                     itemCount: presentUsers.length,
//                     separatorBuilder: (_, __) => const Divider(height: 1),
//                     itemBuilder: (context, index) {
//                       final record = presentUsers[index];
//                       Map<String, dynamic> extraData = {};
//                       if (record['data'] != null && record['data'] is String) {
//                         try {
//                           extraData = jsonDecode(record['data']);
//                         } catch (_) {}
//                       }

//                       final name = extraData['sewadar_name'] ?? 'Unknown';
//                       final badge = extraData['badge_no'] ?? '-';
//                       final mobile = extraData['mobile_self'] ?? '-';
//                       final timestamp =
//                           DateTime.tryParse(record['datetime'] ?? '');
//                       final time = timestamp != null
//                           ? DateFormat('hh:mm a').format(timestamp.toLocal())
//                           : '';
//                       final status = record['attendance'] ?? 'Unknown';

//                       return Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 6),
//                         child: Row(
//                           children: [
//                             Expanded(
//                                 flex: 2,
//                                 child: Text(name,
//                                     style: const TextStyle(fontSize: 13))),
//                             Expanded(
//                                 flex: 1,
//                                 child: Text(badge,
//                                     style: const TextStyle(fontSize: 13))),
//                             Expanded(
//                                 flex: 2,
//                                 child: Text(mobile,
//                                     style: const TextStyle(fontSize: 13))),
//                             Expanded(
//                                 flex: 2,
//                                 child: Text(time,
//                                     style: const TextStyle(fontSize: 13))),
//                             Expanded(
//                                 flex: 1,
//                                 child: Text(status,
//                                     style: const TextStyle(fontSize: 13))),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String label, int count, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Text(label,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600)),
//             const SizedBox(height: 6),
//             Text(count.toString(),
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalSewadars = 0;
  int presentCount = 0;
  int absentCount = 0;
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> presentUsers = [];

  @override
  void initState() {
    super.initState();
    calculateStats();
  }

  Future<void> calculateStats() async {
    try {
      final dateStr = DateFormat("yyyy-MM-dd").format(selectedDate);

      final response = await ApiService.post(
        "/dashboard?from=$dateStr&to=$dateStr",
        body: {},
      );

      final dashboard = Map<String, dynamic>.from(response ?? {});

      setState(() {
        totalSewadars =
            dashboard['total_users'] is int ? dashboard['total_users'] : 0;
        presentCount =
            dashboard['present_count'] is int ? dashboard['present_count'] : 0;

        if (dashboard.containsKey('absent_count')) {
          absentCount =
              dashboard['absent_count'] is int ? dashboard['absent_count'] : 0;
        } else {
          // fallback only if API does not provide
          absentCount = totalSewadars - presentCount;
          if (absentCount < 0) absentCount = 0;
        }
        print(dashboard);
        final rawPresentUsers = dashboard['present_users'];
        if (rawPresentUsers != null && rawPresentUsers is List) {
          presentUsers = rawPresentUsers
              .where((e) => e is Map)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        } else {
          presentUsers = [];
        }
      });
    } catch (e) {
      debugPrint("❌ Error loading dashboard: $e");
      setState(() {
        presentUsers = [];
        totalSewadars = 0;
        presentCount = 0;
        absentCount = 0;
      });
    }
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
      body: Column(
        children: [
          // 📅 Date Row
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Showing data for: $formattedDate",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text("Change"),
                  onPressed: _pickDate,
                ),
              ],
            ),
          ),

          // 📊 Stats in horizontal row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                _buildStatCard("Total", totalSewadars, Colors.deepPurple),
                const SizedBox(width: 8),
                _buildStatCard("Present", presentCount, Colors.green),
                const SizedBox(width: 8),
                _buildStatCard("Absent", absentCount, Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 📋 Attendance header (mobile column removed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.grey.shade300,
            child: Row(
              children: const [
                Expanded(
                    flex: 2,
                    child: Text("Name",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(
                    flex: 1,
                    child: Text("Badge",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(
                    flex: 2,
                    child: Text("Time",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(
                    flex: 1,
                    child: Text("Status",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13))),
              ],
            ),
          ),

          // 📋 Attendance list
          Expanded(
            child: presentUsers.isEmpty
                ? const Center(child: Text("⚠️ No one marked present"))
                : ListView.separated(
                    itemCount: presentUsers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final record = presentUsers[index];
                      Map<String, dynamic> extraData = {};
                      if (record['data'] != null && record['data'] is String) {
                        try {
                          extraData = jsonDecode(record['data']);
                        } catch (_) {}
                      }

                      final name = extraData['sewadar_name'] ?? 'Unknown';
                      final badge = extraData['badge_no'] ?? '-';

                      // ✅ Convert UTC -> Local (IST on your device)
                      DateTime? localTime;
                      try {
                        final inputFormat = DateFormat(
                            "yyyy-MM-dd HH:mm:ss"); // match your string
                        localTime = inputFormat
                            .parse(record['datetime'], true)
                            .toLocal();
                      } catch (e) {
                        print("Parse error: $e");
                      }

                      final formattedTime = localTime != null
                          ? DateFormat('hh:mm a, dd MMM').format(localTime)
                          : "Invalid time";

                      final status = record['attendance'] ?? 'Unknown';

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(name,
                                    style: const TextStyle(fontSize: 13))),
                            Expanded(
                                flex: 1,
                                child: Text(badge,
                                    style: const TextStyle(fontSize: 13))),
                            Expanded(
                                flex: 2,
                                child: Text(formattedTime,
                                    style: const TextStyle(fontSize: 13))),
                            Expanded(
                                flex: 1,
                                child: Text(status,
                                    style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(count.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
