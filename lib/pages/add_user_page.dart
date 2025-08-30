// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import '../models/user.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';

// class AddUserPage extends StatefulWidget {
//   @override
//   _AddUserPageState createState() => _AddUserPageState();
// }

// class _AddUserPageState extends State<AddUserPage> {
//   final _formKey = GlobalKey<FormState>();
//   String _name = '';
//   String _userId = '';
//   String _center = 'Sukhliya'; // Default value
//   String? _selectedDepartment;

//   List<String> _departments = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadDepartments();
//   }

//   void _loadDepartments() {
//     final deptBox = Hive.box<String>('departments');
//     setState(() {
//       _departments = deptBox.values.toList();
//     });
//   }

//   // void _saveUser() {
//   //   if (_formKey.currentState!.validate()) {
//   //     _formKey.currentState!.save();

//   //     final newUser = UserModel(
//   //       name: _name,
//   //       userId: _userId,
//   //       center: _center,
//   //       department: _selectedDepartment ?? '',
//   //     );

//   //     final userBox = Hive.box<UserModel>(Boxes.userBox);
//   //     userBox.add(newUser);

//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('User added successfully')),
//   //     );
//   //     Navigator.pop(context);
//   //   }
//   // }

//   void _saveUser() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       final newUser = UserModel(
//         name: _name,
//         userId: _userId,
//         center: _center,
//         department: _selectedDepartment ?? '',
//       );

//       // ✅ Supabase client
//       final supabase = Supabase.instance.client;
//       final uuid = Uuid();
//       final userId = uuid.v4();
//       try {
//         final response = await supabase.from('users').insert({
//           'user_id': userId,
//           'user_id_card': newUser.userId,
//           'name': newUser.name,
//           'center': newUser.center,
//           'department': newUser.department,
//         });

//         debugPrint('✅ User saved to Supabase: $response');

//         // Show success
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User added successfully')),
//         );

//         Navigator.pop(context);
//       } catch (e) {
//         debugPrint('❌ Supabase insert exception: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to save user: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add User')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'Name'),
//                   validator: (value) => value!.isEmpty ? 'Enter name' : null,
//                   onSaved: (value) => _name = value!,
//                 ),
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'User ID'),
//                   validator: (value) => value!.isEmpty ? 'Enter user ID' : null,
//                   onSaved: (value) => _userId = value!,
//                 ),
//                 TextFormField(
//                   initialValue: _center,
//                   decoration: InputDecoration(labelText: 'Center'),
//                   validator: (value) => value!.isEmpty ? 'Enter center' : null,
//                   onSaved: (value) => _center = value!,
//                 ),
//                 DropdownButtonFormField<String>(
//                   value: _selectedDepartment,
//                   decoration: InputDecoration(labelText: 'Department'),
//                   items: _departments.map((dept) {
//                     return DropdownMenuItem(
//                       value: dept,
//                       child: Text(dept),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedDepartment = value;
//                     });
//                   },
//                   validator: (value) => value == null || value.isEmpty
//                       ? 'Select department'
//                       : null,
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _saveUser,
//                   child: Text('Save User'),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _userIdCard = '';
  String _center = 'Sukhliya'; // Default value
  String? _selectedDepartment;

  List<String> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadDepartmentsFromSupabase();
  }

  Future<void> _loadDepartmentsFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('departments')
          .select('name'); // returns List<Map<String, dynamic>>

      setState(() {
        // Extract 'name' from each map
        _departments = (response as List)
            .map<String>((d) => d['name'].toString())
            .toList();
      });
    } catch (e) {
      debugPrint('❌ Failed to load departments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load departments: $e')),
      );
    }
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final supabase = Supabase.instance.client;
      final uuid = Uuid();
      final userId = uuid.v4();

      try {
        final response = await supabase.from('users').insert({
          'userid': userId,
          'user_id_card': _userIdCard,
          'name': _name,
          'center': _center,
          'department': _selectedDepartment,
        });

        debugPrint('✅ User saved to Supabase: $response');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User added successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        debugPrint('❌ Supabase insert exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Enter name' : null,
                  onSaved: (value) => _name = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'User ID'),
                  validator: (value) => value!.isEmpty ? 'Enter user ID' : null,
                  onSaved: (value) => _userIdCard = value!,
                ),
                TextFormField(
                  initialValue: _center,
                  decoration: const InputDecoration(labelText: 'Center'),
                  validator: (value) => value!.isEmpty ? 'Enter center' : null,
                  onSaved: (value) => _center = value!,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: _departments.map((dept) {
                    return DropdownMenuItem(
                      value: dept,
                      child: Text(dept),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value;
                    });
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Select department'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveUser,
                  child: const Text('Save User'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
