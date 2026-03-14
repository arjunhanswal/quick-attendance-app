import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart';

class AttendanceNew extends StatefulWidget {
  const AttendanceNew({Key? key}) : super(key: key);

  @override
  State<AttendanceNew> createState() => _AttendanceNewState();
}

class _AttendanceNewState extends State<AttendanceNew> {
  List<Map<String, dynamic>> _sewadars = [];
  List<Map<String, dynamic>> _filtered = [];

  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchSewadars();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ---------------- FETCH DATA ----------------

  Future<void> fetchSewadars() async {
    setState(() => _loading = true);

    try {
      final response = await ApiService.getSewadars();

      final users = response.map<Map<String, dynamic>>((item) {
        return {
          "sid": item['sid']?.toString() ?? "",
          "name": item['sewadar_name'] ?? "Unknown",
          "badge": item['badge_no'] ?? "",
        };
      }).toList();

      _sewadars = users;
      _filtered = users;
    } catch (e) {
      debugPrint("Error: $e");
    }

    setState(() => _loading = false);
  }

  // ---------------- FAST SEARCH ----------------

  void searchUser(String text) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = text.toLowerCase();

      setState(() {
        _filtered = _sewadars.where((user) {
          final name = user['name'].toString().toLowerCase();
          final badge = user['badge'].toString().toLowerCase();

          return name.contains(query) || badge.contains(query);
        }).toList();
      });
    });
  }

  // ---------------- DATE TIME PICKER ----------------

  Future<DateTime?> pickDateTime() async {
    DateTime now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  // ---------------- CHECKIN ----------------

  Future<void> handleCheckIn(String sid) async {
    final dt = await pickDateTime();
    if (dt == null) return;

    try {
      await ApiService.checkin(
        sid: sid,
        check_in_time: dt,
        checkIndate: dt,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Check In Saved")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ $e")),
      );
    }
  }

  // ---------------- CHECKOUT ----------------

  Future<void> handleCheckOut(String sid) async {
    final dt = await pickDateTime();
    if (dt == null) return;

    try {
      await ApiService.checkout(
        sid: sid,
        checkOutTime: dt,
        checkIndate: dt,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Check Out Saved")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ $e")),
      );
    }
  }

  // ---------------- FAST LIST ITEM ----------------

  Widget buildItem(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Badge: ${user['badge']}"),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () => handleCheckIn(user['sid']),
              child: const Text("IN"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => handleCheckOut(user['sid']),
              child: const Text("OUT"),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchSewadars,
              child: Column(
                children: [
                  // SEARCH

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: searchUser,
                      decoration: InputDecoration(
                        hintText: "Search Sewadar",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // FAST LIST

                  Expanded(
                    child: ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        return buildItem(_filtered[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
