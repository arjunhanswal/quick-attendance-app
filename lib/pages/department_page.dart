import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DepartmentPage extends StatefulWidget {
  @override
  _DepartmentPageState createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  late Box<String> _departmentBox;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _departmentBox = Hive.box<String>('departments');
  }

  void _addDepartment(String dept) {
    if (dept.trim().isEmpty) return;

    if (!_departmentBox.values.contains(dept)) {
      _departmentBox.add(dept);
    }

    _controller.clear();
  }

  void _deleteDepartment(int index) {
    _departmentBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Departments')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add Department',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _addDepartment(_controller.text),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder<Box<String>>(
                valueListenable:
                    _departmentBox.listenable(), // ✅ This works now
                builder: (context, box, _) {
                  if (box.values.isEmpty) {
                    return Center(child: Text('No departments added.'));
                  }

                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final department = box.getAt(index);
                      return ListTile(
                        title: Text(department ?? ''),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteDepartment(index),
                        ),
                      );
                    },
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
