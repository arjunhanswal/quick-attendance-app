// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// class DepartmentPage extends StatefulWidget {
//   @override
//   _DepartmentPageState createState() => _DepartmentPageState();
// }

// class _DepartmentPageState extends State<DepartmentPage> {
//   late Box<String> _departmentBox;
//   final TextEditingController _controller = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _departmentBox = Hive.box<String>('departments');
//   }

//   void _addDepartment(String dept) {
//     if (dept.trim().isEmpty) return;

//     if (!_departmentBox.values.contains(dept)) {
//       _departmentBox.add(dept);
//     }

//     _controller.clear();
//   }

//   void _deleteDepartment(int index) {
//     _departmentBox.deleteAt(index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Departments')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 labelText: 'Add Department',
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.add),
//                   onPressed: () => _addDepartment(_controller.text),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: ValueListenableBuilder<Box<String>>(
//                 valueListenable:
//                     _departmentBox.listenable(), // ✅ This works now
//                 builder: (context, box, _) {
//                   if (box.values.isEmpty) {
//                     return Center(child: Text('No departments added.'));
//                   }

//                   return ListView.builder(
//                     itemCount: box.length,
//                     itemBuilder: (context, index) {
//                       final department = box.getAt(index);
//                       return ListTile(
//                         title: Text(department ?? ''),
//                         trailing: IconButton(
//                           icon: Icon(Icons.delete, color: Colors.red),
//                           onPressed: () => _deleteDepartment(index),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  _DepartmentPageState createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _departments = [];

  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    final response = await Supabase.instance.client
        .from('departments')
        .select()
        .order('name', ascending: true);

    setState(() {
      _departments = (response as List).cast<Map<String, dynamic>>();
    });
  }

  Future<void> _addDepartment(String dept) async {
    if (dept.trim().isEmpty) return;

    // Check if already exists
    final exists = _departments.any((d) => d['name'] == dept);
    if (exists) return;

    try {
      await Supabase.instance.client.from('departments').insert({
        'name': dept
      }).select(); // <- important to add .select() to return inserted row

      _controller.clear();
      fetchDepartments(); // refresh list
    } catch (e) {
      debugPrint('❌ Failed to insert department: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add department: $e')),
      );
    }
  }

  Future<void> _deleteDepartment(String id) async {
    await Supabase.instance.client.from('departments').delete().eq('id', id);
    fetchDepartments(); // refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Departments')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add Department',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addDepartment(_controller.text),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _departments.isEmpty
                  ? const Center(child: Text('No departments added.'))
                  : ListView.builder(
                      itemCount: _departments.length,
                      itemBuilder: (context, index) {
                        final department = _departments[index];
                        return ListTile(
                          title: Text(department['name'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteDepartment(department['id'].toString()),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
