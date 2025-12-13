class BusAttendanceRecord {
  final String sid;
  final String name;
  final DateTime date;
  bool isPresent;

  BusAttendanceRecord({
    required this.sid,
    required this.name,
    required this.date,
    required this.isPresent,
  });
}
