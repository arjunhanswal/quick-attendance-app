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
  // List<Map<String, dynamic>> todaysAttendance = [];
  List<Map<String, dynamic>> presentUsers = [];

  @override
  void initState() {
    super.initState();
    calculateStats();
  }

  // Future<void> calculateStats() async {
  //   try {
  //     final dateStr = DateFormat("yyyy-MM-dd").format(selectedDate);

  //     final response = await ApiService.post(
  //       "/dashboard?from=$dateStr&to=$dateStr",
  //       body: {},
  //     );

  //     final dashboard = Map<String, dynamic>.from(response ?? {});

  //     debugPrint("✅ Dashboard API response: ${jsonEncode(dashboard)}");

  //     setState(() {
  //       totalSewadars =
  //           dashboard['total_users'] is int ? dashboard['total_users'] : 0;
  //       presentCount =
  //           dashboard['present_count'] is int ? dashboard['present_count'] : 0;
  //       absentCount =
  //           dashboard['absent_count'] is int ? dashboard['absent_count'] : 0;
  //     });
  //   } catch (e, st) {
  //     debugPrint("❌ Error loading dashboard: $e\n$st");
  //   }
  // }
  Future<void> calculateStats() async {
    try {
      final dateStr = DateFormat("yyyy-MM-dd").format(selectedDate);

      final response = await ApiService.post(
        "/dashboard?from=$dateStr&to=$dateStr",
        body: {},
      );

      final dashboard = Map<String, dynamic>.from(response ?? {});

      debugPrint("✅ Dashboard API response: ${jsonEncode(dashboard)}");

      setState(() {
        totalSewadars =
            dashboard['total_users'] is int ? dashboard['total_users'] : 0;
        presentCount =
            dashboard['present_count'] is int ? dashboard['present_count'] : 0;

        // if backend doesn’t calculate absent properly, derive it here
        absentCount = totalSewadars - presentCount;

        // ✅ Always force presentUsers into a safe list of maps
        final rawPresentUsers = dashboard['present_users'];
        if (rawPresentUsers != null && rawPresentUsers is List) {
          presentUsers = rawPresentUsers
              .where((e) => e is Map) // ignore invalid entries
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        } else {
          presentUsers = <Map<String, dynamic>>[];
        }

        debugPrint("📋 presentUsers runtimeType: ${presentUsers.runtimeType}");
        debugPrint("📋 presentUsers length: ${presentUsers.length}");
      });
    } catch (e, st) {
      debugPrint("❌ Error loading dashboard: $e\n$st");
      setState(() {
        // fallback to safe state
        presentUsers = <Map<String, dynamic>>[];
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

    // Ensure presentUsers is always a List<Map<String, dynamic>>
    final safeUsers = (presentUsers is List)
        ? List<Map<String, dynamic>>.from(presentUsers)
        : <Map<String, dynamic>>[];

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
                const Text(
                  "Showing data for:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  key: const ValueKey("date_picker_button"),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('EEE, MMM d').format(selectedDate)),
                  onPressed: _pickDate,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 📊 Stats Cards
            _buildStatCard('Total Sewadars', totalSewadars, Colors.deepPurple),
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

            if (safeUsers.isEmpty)
              const Text("⚠️ No one marked present")
            else
              Column(
                children: presentUsers.map((record) {
                  final sid = record['sid']?.toString() ?? '-';
                  final attendance = record['attendance'] ?? 'Unknown';

                  // ✅ Decode the "data" JSON safely
                  Map<String, dynamic> extraData = {};
                  if (record['data'] != null && record['data'] is String) {
                    try {
                      extraData = jsonDecode(record['data']);
                    } catch (e) {
                      debugPrint("⚠️ Error decoding data for sid $sid: $e");
                    }
                  }

                  final name = extraData['sewadar_name'] ?? 'Unknown';
                  final badge = extraData['badge_no'] ?? '-';
                  final mobile = extraData['mobile_self'] ?? '-';

                  final timestamp = DateTime.tryParse(record['datetime'] ?? '');
                  final time = timestamp != null
                      ? DateFormat.jm().format(timestamp.toLocal())
                      : '';

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.green),
                      title: Text(name), // ✅ Show name instead of just ID
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Badge: $badge'),
                          if (time.isNotEmpty) Text('Marked at: $time'),
                          Text('Mobile: $mobile'),
                          Text('Status: $attendance'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
