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
      appBar: AppBar(title: Text('User List')),
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
                  onPressed: () => box.deleteAt(index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
