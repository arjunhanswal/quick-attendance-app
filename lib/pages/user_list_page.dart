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
              return ListTile(
                title: Text(user?.name ?? ''),
                subtitle: Text(
                    'ID: ${user?.userId}, Center: ${user?.center}, Dept: ${user?.department}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    final deletedUser = box.getAt(index);
                    if (deletedUser == null) return;

                    // Delete related attendance
                    final attendanceBox = Hive.box(Boxes.attendanceBox);
                    final keysToDelete = attendanceBox.keys.where((key) {
                      final record = attendanceBox.get(key);
                      return record['userId'] == deletedUser.userId;
                    }).toList();

                    for (var key in keysToDelete) {
                      attendanceBox.delete(key);
                    }

                    // Delete the user
                    box.deleteAt(index);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('User and related attendance deleted')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
