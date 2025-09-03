import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/homepage.dart';
import 'pages/attendance_page.dart';
import 'pages/report_page.dart';
import 'pages/user_list_page.dart';
import 'pages/setting.dart';
import 'pages/department_page.dart';
import 'pages/loginpage.dart';
import 'pages/add_user_page_new.dart'; // ✅ keep only once

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: 'https://iqvufhewqgddohvhywlg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxdnVmaGV3cWdkZG9odmh5d2xnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1MjU3NTUsImV4cCI6MjA3MjEwMTc1NX0.hjLs1c2iyC25xsz6z74wkdDOkj6Y-HeBtRPxgZPI2EE',
  );

  final supabase = Supabase.instance.client;
  final session = supabase.auth.currentSession;

  // ✅ Run App
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: session == null ? '/login' : '/', // ✅ check login
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
