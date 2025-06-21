import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../utils/hive_boxes.dart';

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _userId = '';
  String _center = '';
  String _department = '';

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newUser = UserModel(
        name: _name,
        userId: _userId,
        center: _center,
        department: _department,
      );

      final userBox = Hive.box<UserModel>(Boxes.userBox);
      userBox.add(newUser);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User added successfully')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Enter name' : null,
                  onSaved: (value) => _name = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'User ID'),
                  validator: (value) => value!.isEmpty ? 'Enter user ID' : null,
                  onSaved: (value) => _userId = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Center'),
                  validator: (value) => value!.isEmpty ? 'Enter center' : null,
                  onSaved: (value) => _center = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Department'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter department' : null,
                  onSaved: (value) => _department = value!,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveUser,
                  child: Text('Save User'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
