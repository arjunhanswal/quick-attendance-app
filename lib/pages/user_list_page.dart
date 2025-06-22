import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../utils/hive_boxes.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<UserModel>(Boxes.userBox);

    return Scaffold(
      appBar: AppBar(title: Text('Sewadar List')),
      body: ValueListenableBuilder(
        valueListenable: userBox.listenable(),
        builder: (context, Box<UserModel> box, _) {
          if (box.values.isEmpty) {
            return Center(child: Text('No users added yet.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final user = box.getAt(index);
              if (user == null) return SizedBox();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(user.name),
                subtitle: Text(
                    'ID: ${user.userId}, Center: ${user.center}, Dept: ${user.department}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    final deletedUser = box.getAt(index);
                    if (deletedUser == null) return;

                    final attendanceBox = Hive.box(Boxes.attendanceBox);
                    final keysToDelete = attendanceBox.keys.where((key) {
                      final record = attendanceBox.get(key);
                      return record?.userId == deletedUser.userId;
                    }).toList();

                    for (var key in keysToDelete) {
                      attendanceBox.delete(key);
                    }

                    box.deleteAt(index);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'User "${deletedUser.name}" and attendance deleted')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      // ➕ Floating Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-user');
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
        tooltip: 'Add New User',
      ),
    );
  }
}
