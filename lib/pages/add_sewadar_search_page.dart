import 'package:flutter/material.dart';
import 'api_service.dart';

class AddSewadarSearchPage extends StatefulWidget {
  const AddSewadarSearchPage({super.key});

  @override
  State<AddSewadarSearchPage> createState() => _AddSewadarSearchPageState();
}

class _AddSewadarSearchPageState extends State<AddSewadarSearchPage> {
  List<Map<String, dynamic>> _sewadars = [];
  List<Map<String, dynamic>> _filtered = [];
  final TextEditingController _search = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchSewadars();

    _search.addListener(() {
      final query = _search.text.trim().toLowerCase();

      setState(() {
        if (query.isEmpty) {
          _filtered = List.from(_sewadars);
        } else {
          _filtered = _sewadars.where((user) {
            final name = user['sewadar_name'].toString().toLowerCase();
            final badge = user['badge_no'].toString().toLowerCase();

            return name.contains(query) || badge.contains(query);
          }).toList();
        }
      });
    });
  }

  /// Fetch Sewadars
  Future<void> fetchSewadars() async {
    try {
      final response = await ApiService.getSewadars();

      _sewadars = response.map<Map<String, dynamic>>((item) {
        return {
          "sid": item['sid']?.toString() ?? "",
          "sewadar_name": item['sewadar_name'] ?? "Unknown",
          "badge_no": item['badge_no'] ?? "",
        };
      }).toList();

      _filtered = List.from(_sewadars);
    } catch (e) {
      debugPrint("❌ Failed to fetch sewadar list: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load sewadar list")),
      );
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Sewadar")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      hintText: "Search by name or badge...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text("No results found"),
                        )
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (_, index) {
                            final user = _filtered[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              child: ListTile(
                                title: Text(user["sewadar_name"]),
                                subtitle: Text("Badge: ${user['badge_no']}"),
                                onTap: () => Navigator.pop(context, user),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
