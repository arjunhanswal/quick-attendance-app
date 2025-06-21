import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user.dart';
import 'models/attendance.dart';
import 'pages/dashboard_page.dart';
import 'utils/hive_boxes.dart';
import 'pages/attendance_page.dart';
import 'pages/report_page.dart';
import 'pages/add_user_page.dart';
import 'pages/user_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(AttendanceModelAdapter());
  await Hive.openBox<UserModel>(Boxes.userBox);
  await Hive.openBox<AttendanceModel>(Boxes.attendanceBox);

  //final userBox = Hive.box<UserModel>(Boxes.userBox);
  // if (userBox.isEmpty) {
  //   userBox.add(UserModel(
  //       name: 'Amit Sharma',
  //       userId: 'U101',
  //       center: 'Delhi',
  //       department: 'HR'));
  //   userBox.add(UserModel(
  //       name: 'Neha Reddy',
  //       userId: 'U102',
  //       center: 'Bangalore',
  //       department: 'Tech'));
  //   userBox.add(UserModel(
  //       name: 'Raj Kumar',
  //       userId: 'U103',
  //       center: 'Mumbai',
  //       department: 'Finance'));
  // }

  runApp(MaterialApp(
    title: 'QuickAttendance',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light(),
    home: DashboardPage(),
    routes: {
      '/attendance': (_) => AttendancePage(),
      '/report': (_) => ReportPage(),
      '/add-user': (_) => AddUserPage(),
      '/settings': (_) => Placeholder(),
      '/user-list': (_) => UserListPage() // Optional
    },
  ));
}
