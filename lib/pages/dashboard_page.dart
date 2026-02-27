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

      final response = await ApiService.getdashboardDetails(
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
      body: Column(children: [
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
                          fontWeight: FontWeight.bold, fontSize: 15))),
              Expanded(
                  flex: 1,
                  child: Text("Badge",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15))),
              Expanded(
                  flex: 1,
                  child: Text("In Time",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15))),
              Expanded(
                  flex: 1,
                  child: Text("Out Time",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15))),
            ],
          ),
        ),

        // 📋 Attendance list
        // 📋 Attendance list
        Expanded(
          child: presentUsers.isEmpty
              ? const Center(child: Text("⚠️ No one marked present"))
              : ListView.builder(
                  itemCount: presentUsers.length,
                  itemBuilder: (context, index) {
                    final record = presentUsers[index];

                    Map<String, dynamic> userData = {};

                    // Parse DATA JSON
                    try {
                      if (record['data'] != null) {
                        userData = jsonDecode(record['data']);
                      }
                    } catch (e) {
                      debugPrint("JSON parse error $e");
                    }

                    final name = userData['sewadar_name'] ?? "Unknown";

                    final badge = userData['badge_no'] ?? "-";

                    String inFormatted = "-";
                    String outFormatted = "-";

                    try {
                      if (record['check_in_time'] != null) {
                        final inLocal = DateFormat("yyyy-MM-dd HH:mm:ss")
                            .parse(record['check_in_time'], true)
                            .toLocal();

                        inFormatted = DateFormat('hh:mm a').format(inLocal);
                      }

                      if (record['check_out_time'] != null) {
                        final outLocal = DateFormat("yyyy-MM-dd HH:mm:ss")
                            .parse(record['check_out_time'], true)
                            .toLocal();

                        outFormatted = DateFormat('hh:mm a').format(outLocal);
                      }
                    } catch (e) {
                      debugPrint("Time parse error $e");
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300))),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(capitalizeName(name))),
                          Expanded(flex: 1, child: Text(badge)),
                          Expanded(flex: 1, child: Text(inFormatted)),
                          Expanded(flex: 1, child: Text(outFormatted)),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ]),
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

String capitalizeName(String fullName) {
  if (fullName.isEmpty) return fullName;
  return fullName
      .split(' ')
      .map((word) => word.isNotEmpty
          ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
          : '')
      .join(' ');
}
