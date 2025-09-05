import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> _sewadars = [];
  List<Map<String, dynamic>> _filteredSewadars = [];
  Map<String, dynamic>? _selectedSewadar;
  TimeOfDay? _selectedTime;
  final _searchController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchSewadars();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();

      setState(() {
        _filteredSewadars = _sewadars.where((u) {
          final name = (u['sewadar_name'] ?? '').toString().toLowerCase();
          final badge = (u['badge_no'] ?? '').toString().toLowerCase();

          if (query.isEmpty) return true;
          return name.contains(query) || badge.contains(query);
        }).toList();
      });
    });
  }

  Future<void> fetchSewadars() async {
    try {
      final response = await ApiService.getSewadars();
      final users = response.map<Map<String, dynamic>>((item) {
        return {
          "sid": item['sid']?.toString() ?? "",
          "sewadar_name": item['sewadar_name'] ?? "Unknown",
          "badge_no": item['badge_no'] ?? "",
        };
      }).toList();

      setState(() {
        _sewadars = users;
        _filteredSewadars = List.from(_sewadars);
        _loading = false;
      });
    } catch (e) {
      debugPrint("❌ Failed to fetch sewadars: $e");
      setState(() {
        _sewadars = [];
        _filteredSewadars = [];
        _loading = false;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submitAttendance() async {
    if (_selectedSewadar == null) {
      _showMsg("Please select a sewadar");
      return;
    }
    if (_selectedTime == null) {
      _showMsg("Please select a time");
      return;
    }

    final id = _selectedSewadar!['sid']?.toString();
    if (id == null || id.isEmpty) return;

    final now = DateTime.now();
    final timestamp = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      await ApiService.markAttendance(
        sid: id,
        attendance: "Present",
        time: timestamp,
      );

      _showMsg("✅ Attendance marked successfully");
      setState(() {
        _selectedSewadar = null;
        _selectedTime = null;
        _searchController.clear();
        _filteredSewadars = List.from(_sewadars);
      });
    } catch (e) {
      _showMsg("❌ Failed to mark attendance: $e");
    }
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search sewadar by name or badge number',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredSewadars.isEmpty
                      ? const Center(child: Text("No sewadar found"))
                      : ListView.builder(
                          itemCount: _filteredSewadars.length,
                          itemBuilder: (context, index) {
                            final u = _filteredSewadars[index];
                            return ListTile(
                              title: Text(
                                  u['sewadar_name']?.toString() ?? "Unknown"),
                              subtitle: Text(
                                  "Badge: ${u['badge_no']?.toString() ?? ''}"),
                              trailing: Radio<Map<String, dynamic>>(
                                value: u,
                                groupValue: _selectedSewadar,
                                onChanged: (value) {
                                  setState(() => _selectedSewadar = value);
                                },
                              ),
                              onTap: () {
                                setState(() => _selectedSewadar = u);
                              },
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _pickTime(context),
                        child: Text(_selectedTime == null
                            ? 'Select Time'
                            : 'Time: ${_selectedTime!.format(context)}'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _submitAttendance,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(45),
                        ),
                        child: const Text('Submit Attendance'),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
