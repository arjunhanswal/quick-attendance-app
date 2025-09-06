import 'package:flutter/material.dart';
import 'package:quick_attendance_app/pages/satsang_schedule_page.dart';
import 'pages/homepage.dart';
import 'pages/loginpage.dart';
import 'pages/attendance_page.dart';
import 'pages/report_page.dart';
import 'pages/user_list_page.dart';
import 'pages/setting.dart';
import 'pages/department_page.dart';
import 'pages/add_user_page_new.dart';
import 'pages/session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Get session
  final session = await SessionManager.getUser();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: session == null ? '/login' : '/',
    routes: {
      '/': (context) => const HomePage(),
      '/login': (context) => LoginPage(),
      '/attendance': (context) => const AttendancePage(),
      '/report': (context) => const ReportPage(),
      '/user-list': (context) => const UserListPage(),
      '/settings': (context) => const SettingsPage(),
      '/departments': (context) => const DepartmentPage(),
      '/add-user-new': (context) => const AddUserPageNew(),
    },
  ));
}
