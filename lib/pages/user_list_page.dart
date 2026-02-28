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

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  List<Map<String, dynamic>> _departments = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _usersFuture = fetchUsers();
  }

  Future<void> _refreshUsers() async {
    final users = await fetchUsers();

    setState(() {
      _users = users;
      _filteredUsers = users;
    });
  }

  /// FETCH USERS
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final response = await ApiService.getSewadars();

      final users = response.map<Map<String, dynamic>>((item) {
        return {
          "sid": item['sid']?.toString() ?? "",
          "created_at": item['created_at']?.toString() ?? "",
          "status": item['status']?.toString() ?? "",
          ...item,
        };
      }).toList();

      /// Sort by name
      users.sort((a, b) {
        final nameA = (a['sewadar_name'] ?? '').toString().toLowerCase();
        final nameB = (b['sewadar_name'] ?? '').toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      /// Save locally
      _users = users;
      _filteredUsers = users;

      return users;
    } catch (e) {
      print("Fetch error $e");
      return [];
    }
  }

  /// SEARCH FUNCTION
  void searchUsers(String value) {
    value = value.toLowerCase();

    setState(() {
      _filteredUsers = _users.where((user) {
        final name = (user['sewadar_name'] ?? '').toString().toLowerCase();

        final badge = (user['badge_no'] ?? '').toString().toLowerCase();

        final mobile = (user['mobile_self'] ?? '').toString().toLowerCase();

        final dept = getDeptName(user['dept_id0']).toLowerCase();

        return name.contains(value) ||
            badge.contains(value) ||
            mobile.contains(value) ||
            dept.contains(value);
      }).toList();
    });
  }

  Future<void> deleteUser(String id, String name) async {
    try {
      await ApiService.deleteSewadar(id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name deleted")),
      );

      _refreshUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete error $e")),
      );
    }
  }

  Future<void> _loadDepartments() async {
    final response = await ApiService.getDepartments();

    setState(() {
      _departments = response.cast<Map<String, dynamic>>();
    });
  }

  String getDeptName(dynamic id) {
    if (id == null) return "";

    final dept = _departments.firstWhere(
        (d) => d['id'].toString() == id.toString(),
        orElse: () => {});

    return dept.isNotEmpty ? dept['name'] : "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sewadar List'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              onChanged: searchUsers,
              decoration: InputDecoration(
                hintText: "Search name, badge, mobile...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_filteredUsers.isEmpty) {
            return const Center(child: Text("No Users Found"));
          }

          return RefreshIndicator(
            onRefresh: _refreshUsers,
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];

                final name = user['sewadar_name'] ?? "";

                final badge = user['badge_no'] ?? "";

                final dept = getDeptName(user['dept_id0']);

                final mobile = user['mobile_self'] ?? "";

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "?",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(name),
                    subtitle:
                        Text("Badge: $badge\nDept: $dept\nMobile: $mobile"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteUser(user['sid'].toString(), name);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddUserPageNew(
                                  isEdit: true, userData: user))).then((value) {
                        if (value == true) _refreshUsers();
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
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/add-user-new').then((value) {
            if (value == true) _refreshUsers();
          });
        },
      ),
    );
  }
}
