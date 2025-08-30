import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/user.dart';
import 'models/attendance.dart';
import 'pages/homepage.dart';
import 'pages/attendance_page.dart';
import 'pages/report_page.dart';
import 'pages/add_user_page.dart';
import 'pages/user_list_page.dart';
import 'utils/hive_boxes.dart';
import 'pages/setting.dart';
import 'pages/department_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: 'https://iqvufhewqgddohvhywlg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxdnVmaGV3cWdkZG9odmh5d2xnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1MjU3NTUsImV4cCI6MjA3MjEwMTc1NX0.hjLs1c2iyC25xsz6z74wkdDOkj6Y-HeBtRPxgZPI2EE',
  );

  // ✅ Initialize Hive
  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(AttendanceModelAdapter());

  await Hive.openBox<UserModel>(Boxes.userBox);
  await Hive.openBox<AttendanceModel>(Boxes.attendanceBox);
  await Hive.openBox<String>(Boxes.departmentBox);

  // ✅ Run App
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
      '/departments': (context) => DepartmentPage(),
    },
  ));
}
