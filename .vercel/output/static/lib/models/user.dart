import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String center;

  @HiveField(3)
  String department;

  UserModel({
    required this.name,
    required this.userId,
    required this.center,
    required this.department,
  });
}