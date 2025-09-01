import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await Supabase.instance.client
        .from('sewadars')
        .select()
        .order('created_at', ascending: false);
    return response as List<Map<String, dynamic>>;
  }

  Future<void> deleteUser(String id, String sewadarName) async {
    try {
      // delete attendance first (if you have attendance table linked by sewadar_id)
      await Supabase.instance.client
          .from('attendance')
          .delete()
          .eq('sewadar_id', id);

      // delete from sewadars
      await Supabase.instance.client.from('sewadars').delete().eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User "$sewadarName" and attendance deleted')),
        );
        setState(() {}); // refresh UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error deleting user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sewadar List')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
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

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    (user['name'] as String?)?.isNotEmpty == true
                        ? user['name'][0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(user['name'] ?? ''),
                subtitle: Text(
                  'Badge: ${user['badge_number'] ?? ''}, '
                  'Sukhliya Dept: ${user['department_sukhliya'] ?? ''}, '
                  'Mobile: ${user['mobile_self'] ?? ''}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteUser(
                    user['id'],
                    user['sewadar_name'] ?? '',
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-user-new');
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        tooltip: 'Add New User',
      ),
    );
  }
}
