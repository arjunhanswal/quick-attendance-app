import 'package:flutter/material.dart';
import 'session_manager.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add Department'),
            subtitle: Text('Add New Department'),
            onTap: () async {
              Navigator.pushNamed(context, '/departments');
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('All Sewadar List'),
            subtitle: Text('List of all sewadar'),
            onTap: () async {
              await Navigator.pushNamed(context, "/user-list");
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('App Info'),
            subtitle: Text('Version 1.0.0'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle: Text('Coming soon'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Theme'),
            subtitle: Text('Light / Dark'),
            onTap: () {
              // Add theme change logic if needed
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              // ✅ Clear session
              await SessionManager.clearSession();

              // ✅ Navigate to login page
              Navigator.pushReplacementNamed(context, '/login');

              // ✅ Optional: show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out')),
              );
            },
          ),
        ],
      ),
    );
  }
}
