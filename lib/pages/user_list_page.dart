import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'add_user_page_new.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late Future<List<Map<String, dynamic>>> _usersFuture;
  List<Map<String, dynamic>> _departments = [];
  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _usersFuture = fetchUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = fetchUsers(); // reassign future
    });
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final response = await ApiService.getSewadars();

      return response.map<Map<String, dynamic>>((item) {
        // since getSewadars already decodes `data`, just merge directly
        final userMap = {
          "sid": item['sid']?.toString() ?? "",
          "created_at": item['created_at']?.toString() ?? "",
          "status": item['status']?.toString() ?? "",
          ...item, // item already contains parsed fields like sewadar_name, badge_no etc
        };

        print("✅ Parsed user: $userMap"); // use print instead of debugPrint
        return userMap;
      }).toList();
    } catch (e) {
      print("❌ Failed to fetch users: $e");
      return [];
    }
  }

  Future<void> deleteUser(String id, String sewadarName) async {
    try {
      await ApiService.deleteSewadar(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User "$sewadarName" deleted successfully')),
        );
        setState(() {}); // refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error deleting user: $e')),
        );
      }
    }
  }

  Map<String, dynamic> safeDecode(dynamic raw) {
    if (raw == null) return {};
    try {
      if (raw is String) {
        // First decode
        final first = jsonDecode(raw);

        // If still string, decode again
        if (first is String) {
          return jsonDecode(first);
        }
        if (first is Map) {
          return Map<String, dynamic>.from(first);
        }
      } else if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
    } catch (e) {
      debugPrint("❌ safeDecode failed: $e");
    }
    return {};
  }

  Future<void> _loadDepartments() async {
    try {
      final response = await ApiService.getDepartments();
      setState(() {
        _departments = response.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint("❌ Failed to load departments: $e");
    }
  }

  String getDeptName(dynamic id) {
    if (id == null) return '';
    final dept = _departments.firstWhere(
      (d) => d['id'].toString() == id.toString(),
      orElse: () => {},
    );
    return dept.isNotEmpty ? dept['name'] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sewadar List')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
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

          return RefreshIndicator(
            onRefresh: _refreshUsers,
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final name = user['sewadar_name'] ?? '';
                final badge = user['badge_no'] ?? '';
                final dept0 = getDeptName(user['dept_id0']);
                final mobile = user['mobile_self'] ?? '';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(name),
                    subtitle:
                        Text('Badge: $badge, Dept: $dept0, Mobile: $mobile'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Delete"),
                            content:
                                Text("Are you sure you want to delete $name?"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context), // Cancel
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  deleteUser(user['sid'].toString(), name);
                                  _refreshUsers(); // ✅ reload after delete
                                },
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddUserPageNew(isEdit: true, userData: user),
                        ),
                      ).then((result) {
                        if (result == true)
                          _refreshUsers(); // ✅ reload after update
                      });
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-user-new').then((result) {
            if (result == true) _refreshUsers(); // ✅ reload after adding
          });
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        tooltip: 'Add New User',
      ),
    );
  }
}
