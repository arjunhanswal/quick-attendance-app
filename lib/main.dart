import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/user.dart';
import 'models/attendance.dart';
import 'pages/homepage.dart';
import 'pages/attendance_page.dart';
import 'pages/report_page.dart';
import 'pages/add_user_page.dart';
import 'pages/user_list_page.dart';
import 'utils/hive_boxes.dart';
import 'pages/setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(AttendanceModelAdapter());

  await Hive.openBox<UserModel>(Boxes.userBox);
  await Hive.openBox<AttendanceModel>(Boxes.attendanceBox);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => HomePage(), // Bottom Nav with Dashboard
      '/attendance': (context) => AttendancePage(),
      '/report': (context) => ReportPage(),
      '/add-user': (context) => AddUserPage(),
      '/user-list': (context) => UserListPage(),
      '/settings': (context) => const SettingsPage(),
    },
  ));
}
