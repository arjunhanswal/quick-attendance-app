// import 'package:flutter/material.dart';

// class DashboardPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('QuickAttendance')),
//       body: GridView.count(
//         crossAxisCount: 2,
//         padding: EdgeInsets.all(16),
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         children: [
//           _buildTile(context, 'Attendance', Colors.green),
//           _buildTile(context, 'Report', Colors.blue),
//           _buildTile(context, 'Add Sewa dar', Colors.purple),
//           _buildTile(context, 'Settings', Colors.orange),
//           _buildTile(context, 'Sewa Dar List', Colors.red)
//         ],
//       ),
//     );
//   }

//   Widget _buildTile(BuildContext context, String label, Color color) {
//     return GestureDetector(
//       onTap: () {
//         switch (label) {
//           case 'Attendance':
//             Navigator.pushNamed(context, '/attendance');
//             break;
//           case 'Report':
//             Navigator.pushNamed(context, '/report');
//             break;
//           case 'Add Sewa dar':
//             Navigator.pushNamed(context, '/add-user');
//             break;
//           case 'Settings':
//             Navigator.pushNamed(context, '/settings');
//             break;
//           case 'Sewa Dar List':
//             Navigator.pushNamed(context, '/user-list');
//             break;
//         }
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Center(
//           child:
//               Text(label, style: TextStyle(color: Colors.white, fontSize: 18)),
//         ),
//       ),
//     );
//   }
// }
// dashboard_page.dart
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quick Attendance Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // 2 cards per row
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.how_to_reg,
              label: 'Attendance',
              color: Colors.green,
              route: '/attendance',
            ),
            _buildDashboardCard(
              context,
              icon: Icons.bar_chart,
              label: 'Report',
              color: Colors.deepPurple,
              route: '/report',
            ),
            _buildDashboardCard(
              context,
              icon: Icons.person_add,
              label: 'Add Sewadar',
              color: Colors.orange,
              route: '/add-user',
            ),
            _buildDashboardCard(
              context,
              icon: Icons.list,
              label: 'Sewadar List',
              color: Colors.orange,
              route: '/user-list',
            ),
            // Add more cards as needed
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white, // Solid background for card
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 30, color: color),
              ),
              SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
