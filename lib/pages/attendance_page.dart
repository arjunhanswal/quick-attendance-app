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

  List<Map<String, dynamic>> _sewadars = [];
  List<Map<String, dynamic>> _filteredSewadars = [];
  List<Map<String, dynamic>> _todayAttendance = [];
  Map<String, dynamic>? _selectedSewadar;
  TimeOfDay? _selectedTime;
  final _searchController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchSewadars();
    fetchTodayAttendance();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredSewadars = _sewadars.where((u) {
          final name = (u['name'] ?? '').toString().toLowerCase();
          final badge = (u['badge_number'] ?? '').toString().toLowerCase();
          return name.contains(query) || badge.contains(query);
        }).toList();
      });
    });
  }

  Future<void> fetchSewadars() async {
    try {
      final response = await Supabase.instance.client
          .from('sewadars')
          .select()
          .order('name', ascending: true);

      if (response is List) {
        setState(() {
          _sewadars = response.cast<Map<String, dynamic>>();
          _filteredSewadars = List.from(_sewadars);
        });
      } else {
        setState(() {
          _sewadars = [];
          _filteredSewadars = [];
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch sewadars: $e');
      setState(() {
        _sewadars = [];
        _filteredSewadars = [];
      });
    }
  }

  Future<void> fetchTodayAttendance() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    try {
      final response = await Supabase.instance.client
          .from('attendance')
          .select(
              'id, timestamp, sewadars(id, name, badge_number, department_sukhliya)')
          .gte('timestamp', start.toIso8601String())
          .lt('timestamp', end.toIso8601String());

      if (response is List) {
        setState(() {
          _todayAttendance = response.cast<Map<String, dynamic>>();
          _loading = false;
        });
      } else {
        setState(() {
          _todayAttendance = [];
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch today attendance: $e');
      _showMsg('Failed to fetch attendance: $e');
      setState(() => _loading = false);
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
      _showMsg('Please select a sewadar');
      return;
    }

    final now = DateTime.now();
    final timestamp = _selectedTime != null
        ? DateTime(now.year, now.month, now.day, _selectedTime!.hour,
            _selectedTime!.minute)
        : now;

    final sewadarId = _selectedSewadar?['id']?.toString() ?? '';
    final alreadyMarked = _isMarked(sewadarId);

    if (alreadyMarked) {
      _showMsg('${_selectedSewadar?['name'] ?? "Sewadar"} is already marked.');
      return;
    }

    final weekStart = now.subtract(Duration(days: now.weekday % 7));

    try {
      await Supabase.instance.client.from('attendance').insert({
        'userid': sewadarId, // 👈 use correct FK column name
        'timestamp': timestamp.toIso8601String(),
        'week_start': weekStart.toIso8601String(),
      });
      _showMsg(
          'Attendance marked for ${_selectedSewadar?['name'] ?? "Sewadar"}');
      setState(() {
        _selectedSewadar = null;
        _selectedTime = null;
        _searchController.clear();
        _filteredSewadars = List.from(_sewadars);
      });
      fetchTodayAttendance();
    } catch (e) {
      _showMsg('Failed to mark attendance: $e');
    }
  }

  Future<void> _deleteAttendance(String? attendanceId) async {
    if (attendanceId == null) return;
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _isMarked(String sewadarId) {
    if (sewadarId.isEmpty) return false;
    return _todayAttendance
        .any((record) => record['sewadars']?['id']?.toString() == sewadarId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        automaticallyImplyLeading: false,
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
                    hintText: 'Search sewadar by name or badge number',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _filteredSewadars.isEmpty
                      ? const Center(child: Text("No sewadar found"))
                      : ListView.builder(
                          itemCount: _filteredSewadars.length,
                          itemBuilder: (context, index) {
                            final sewadar = _filteredSewadars[index];
                            final id = sewadar['id']?.toString() ?? '';
                            final isSelected =
                                _selectedSewadar?['id']?.toString() == id;
                            final isMarked = _isMarked(id);

                            Color? bgColor;
                            if (isSelected) {
                              bgColor = Colors.blue.withOpacity(0.3);
                            } else if (isMarked) {
                              bgColor = Colors.green.withOpacity(0.2);
                            }

                            return Card(
                              color: bgColor,
                              child: ListTile(
                                title: Text(sewadar['name'] ?? 'Unknown'),
                                subtitle: Text(
                                  'Badge: ${sewadar['badge_number'] ?? "-"} | Dept: ${sewadar['department_sukhliya'] ?? ''}',
                                ),
                                trailing: isMarked
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : null,
                                onTap: () =>
                                    setState(() => _selectedSewadar = sewadar),
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
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45)),
                  child: const Text('Submit Attendance'),
                ),
              ],
            ),
          ),

          // Tab 2: Today’s Attendance
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _todayAttendance.isEmpty
                    ? const Center(child: Text('No attendance today'))
                    : ListView.builder(
                        itemCount: _todayAttendance.length,
                        itemBuilder: (context, index) {
                          final record = _todayAttendance[index];
                          final sewadar = record['sewadars'] ?? {};
                          final sewadarName = sewadar['name'] ?? 'Unknown';
                          final timestamp = record['timestamp'];
                          String time = '';
                          if (timestamp != null) {
                            try {
                              time = TimeOfDay.fromDateTime(
                                      DateTime.parse(timestamp.toString()))
                                  .format(context);
                            } catch (_) {
                              time = '';
                            }
                          }

                          return Card(
                            child: ListTile(
                              title: Text(sewadarName),
                              subtitle: Text(
                                  time.isNotEmpty ? 'Marked at: $time' : ''),
                              leading:
                                  const Icon(Icons.check, color: Colors.green),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deleteAttendance(record['id']?.toString()),
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
