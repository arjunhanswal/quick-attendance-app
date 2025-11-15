import 'package:flutter/material.dart';
import 'add_sewadar_search_page.dart';
import 'api_service.dart';
import 'bus_report_page.dart';

class BusAttendancePage extends StatefulWidget {
  const BusAttendancePage({super.key});

  @override
  State<BusAttendancePage> createState() => _BusAttendancePageState();
}

class _BusAttendancePageState extends State<BusAttendancePage> {
  List<Map<String, dynamic>> busList = [];
  Map<String, bool> attendance = {};

  /// Add sewadar
  Future<void> _addSewadar() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddSewadarSearchPage()),
    );

    if (selected == null) return;

    final sid = selected["sid"].toString();

    /// avoid duplicates
    final exists = busList.any((u) => u["sid"].toString() == sid);
    if (!exists) {
      setState(() {
        busList.add(selected);
        attendance[sid] = false;
      });
    }
  }

  /// Send attendance to API
  Future<void> _submitAttendance(String sid, bool isPresent) async {
    try {
      await ApiService.markBusRollCall(
        sid: int.tryParse(sid) ?? 0,
        dateTime: DateTime.now(),
        attendance: isPresent ? "Present" : "Absent",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Attendance saved: ${isPresent ? "Present" : "Absent"}")),
      );
    } catch (e) {
      debugPrint("❌ Failed to save attendance: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save attendance")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Attendance"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _addSewadar,
          ),
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusReportPage()),
              );
            },
          ),
        ],
      ),
      body: busList.isEmpty
          ? const Center(
              child: Text(
                "No sewadar added",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: busList.length,
              itemBuilder: (_, i) {
                final user = busList[i];
                final sid = user["sid"].toString();

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(user["sewadar_name"]),
                    subtitle: Text("Badge: ${user['badge_no']}"),

                    /// Switch to mark attendance
                    trailing: Switch(
                      value: attendance[sid] ?? false,
                      onChanged: (val) {
                        setState(() => attendance[sid] = val);
                        _submitAttendance(sid, val);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
