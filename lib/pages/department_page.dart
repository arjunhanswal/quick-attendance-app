import 'package:flutter/material.dart';
import 'api_service.dart';

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

  /// ✅ Fetch all departments
  Future<void> fetchDepartments() async {
    try {
      final response = await ApiService.getDepartments();
      setState(() {
        _departments = response.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('❌ Failed to load departments: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load departments: $e')),
        );
      }
    }
  }

  /// ✅ Add new department
  Future<void> _addDepartment(String dept) async {
    if (dept.trim().isEmpty) return;

    // check duplicate in current list
    final exists = _departments.any(
      (d) => (d['name'] as String).toLowerCase() == dept.toLowerCase(),
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Department already exists")),
      );
      return;
    }

    try {
      await ApiService.addDepartment(dept);
      _controller.clear();
      fetchDepartments();
    } catch (e) {
      debugPrint('❌ Failed to add department: $e');
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Failed to add department: $e')),
      //   );
      // }
    }
  }

  /// ✅ Delete department
  Future<void> _deleteDepartment(int id) async {
    try {
      await ApiService.deleteDepartment(id);
      fetchDepartments();
    } catch (e) {
      debugPrint('❌ Failed to delete department: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete department: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Departments')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ➕ Add Department Field
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

            // 📋 Department List
            Expanded(
              child: _departments.isEmpty
                  ? const Center(child: Text('No departments added.'))
                  : ListView.builder(
                      itemCount: _departments.length,
                      itemBuilder: (context, index) {
                        final dept = _departments[index];
                        return ListTile(
                          title: Text(dept['name'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteDepartment(dept['id'] as int),
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
