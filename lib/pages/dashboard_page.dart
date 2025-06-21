import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QuickAttendance')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildTile(context, 'Attendance', Colors.green),
          _buildTile(context, 'Report', Colors.blue),
          _buildTile(context, 'Add Sewa dar', Colors.purple),
          _buildTile(context, 'Settings', Colors.orange),
          _buildTile(context, 'Sewa Dar List', Colors.red)
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, String label, Color color) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case 'Attendance':
            Navigator.pushNamed(context, '/attendance');
            break;
          case 'Report':
            Navigator.pushNamed(context, '/report');
            break;
          case 'Add Sewa dar':
            Navigator.pushNamed(context, '/add-user');
            break;
          case 'Settings':
            Navigator.pushNamed(context, '/settings');
            break;
          case 'Sewa Dar List':
            Navigator.pushNamed(context, '/user-list');
            break;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child:
              Text(label, style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}
