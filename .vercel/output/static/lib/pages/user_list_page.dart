// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import '../models/user.dart';
// import '../utils/hive_boxes.dart';

// class UserListPage extends StatelessWidget {
//   const UserListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final userBox = Hive.box<UserModel>(Boxes.userBox);

//     return Scaffold(
//       appBar: AppBar(title: Text('Sewadar List')),
//       body: ValueListenableBuilder(
//         valueListenable: userBox.listenable(),
//         builder: (context, Box<UserModel> box, _) {
//           if (box.values.isEmpty) {
//             return Center(child: Text('No users added yet.'));
//           }

//           return ListView.builder(
//             itemCount: box.length,
//             itemBuilder: (context, index) {
//               final user = box.getAt(index);
//               if (user == null) return SizedBox();

//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: Colors.blueAccent,
//                   child: Text(
//                     user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 title: Text(user.name),
//                 subtitle: Text(
//                     'ID: ${user.userId}, Center: ${user.center}, Dept: ${user.department}'),
//                 trailing: IconButton(
//                   icon: Icon(Icons.delete, color: Colors.red),
//                   onPressed: () {
//                     final deletedUser = box.getAt(index);
//                     if (deletedUser == null) return;

//                     final attendanceBox = Hive.box(Boxes.attendanceBox);
//                     final keysToDelete = attendanceBox.keys.where((key) {
//                       final record = attendanceBox.get(key);
//                       return record?.userId == deletedUser.userId;
//                     }).toList();

//                     for (var key in keysToDelete) {
//                       attendanceBox.delete(key);
//                     }

//                     box.deleteAt(index);

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                           content: Text(
//                               'User "${deletedUser.name}" and attendance deleted')),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),

//       // ➕ Floating Button
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.pushNamed(context, '/add-user');
//         },
//         backgroundColor: Colors.deepPurple,
//         child: Icon(Icons.add),
//         tooltip: 'Add New User',
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  // 🔹 Function to fetch users from Supabase
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await Supabase.instance.client
        .from('users')
        .select()
        .order('created_at', ascending: false); // optional ordering
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sewadar List')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No users added yet.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    (user['name'] as String).isNotEmpty
                        ? user['name'][0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(user['name'] ?? ''),
                subtitle: Text(
                  'ID: ${user['user_id_card']}, Center: ${user['center']}, Dept: ${user['department']}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // delete user and their attendance records
                    await Supabase.instance.client
                        .from('attendance')
                        .delete()
                        .eq('user_id', user['user_id']);

                    await Supabase.instance.client
                        .from('users')
                        .delete()
                        .eq('user_id', user['user_id']);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'User "${user['name']}" and attendance deleted')),
                    );

                    // refresh UI
                    (context as Element).reassemble();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-user');
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        tooltip: 'Add New User',
      ),
    );
  }
}
