import 'package:hive/hive.dart';

part 'attendance.g.dart';

@HiveType(typeId: 1)
class AttendanceModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  DateTime weekStart; // 🔁 Add this field

  AttendanceModel({
    required this.userId,
    required this.timestamp,
    required this.weekStart,
  });
}
