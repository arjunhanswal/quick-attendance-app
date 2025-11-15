import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';

class BusReportPage extends StatefulWidget {
  const BusReportPage({super.key});

  @override
  _BusReportPageState createState() => _BusReportPageState();
}

class _BusReportPageState extends State<BusReportPage> {
  DateTime? fromDate;
  DateTime? toDate;

  bool isLoading = false;
  List<dynamic> rollCallData = [];

  final dateFormat = DateFormat("yyyy-MM-dd");

  Future<void> _pickFromDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => fromDate = picked);
  }

  Future<void> _pickToDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => toDate = picked);
  }

  /// 🔥 Fetch API + decode nested JSON inside "data"
  Future<void> _fetchReport() async {
    if (fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both dates")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String from = dateFormat.format(fromDate!);
      String to = dateFormat.format(toDate!);

      final raw = await ApiService.getBusRollCall(from: from, to: to);

      /// API returns: { from, to, total_users, present_users }
      final List<dynamic> presentUsers = raw["present_users"] ?? [];

      /// Decode inner JSON inside "data"
      final decodedList = presentUsers.map((user) {
        final innerJsonString = user["data"] ?? "{}";

        Map<String, dynamic> inner;
        try {
          inner = jsonDecode(innerJsonString);
        } catch (e) {
          inner = {};
        }

        return {
          "sid": user["sid"] ?? "",
          "datetime": user["datetime"] ?? "",
          "attendance": user["attendance"] ?? "",
          "details": inner,
        };
      }).toList();

      setState(() => rollCallData = decodedList);
    } catch (e) {
      debugPrint("❌ Error loading report: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch report")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🔹 Export CSV
  Future<void> _exportCSV() async {
    if (rollCallData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data to export")),
      );
      return;
    }

    try {
      final today = dateFormat.format(DateTime.now());

      List<List<dynamic>> rows = [];

      // Title
      rows.add(["Radha Swami Bus Report - $today"]);
      rows.add([]);

      // Header
      rows.add(["Serial No", "Name", "Mobile", "Present"]);

      // Rows
      for (int i = 0; i < rollCallData.length; i++) {
        final item = rollCallData[i];
        final details = item["details"];

        rows.add([
          i + 1,
          details["sewadar_name"] ?? "",
          details["mobile_self"] ?? "",
          item["attendance"] == "Present" ? "Yes" : "No",
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final dir = await getDownloadsDirectory();
      final filePath =
          "${dir!.path}/Bus_Report_${dateFormat.format(DateTime.now())}.csv";

      final file = File(filePath);
      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CSV saved in Downloads: $filePath")),
      );
    } catch (e) {
      debugPrint("CSV Export Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to export CSV")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Attendance Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportCSV,
          ),
        ],
      ),
      body: Column(
        children: [
          /// Date Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickFromDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fromDate == null
                            ? "From Date"
                            : dateFormat.format(fromDate!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickToDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        toDate == null ? "To Date" : dateFormat.format(toDate!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _fetchReport,
                  child: const Text("Load"),
                ),
              ],
            ),
          ),

          /// List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : rollCallData.isEmpty
                    ? const Center(child: Text("No Data"))
                    : ListView.builder(
                        itemCount: rollCallData.length,
                        itemBuilder: (context, index) {
                          final item = rollCallData[index];
                          final details = item["details"];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 12),
                            child: ListTile(
                              title: Text(details["sewadar_name"] ?? ""),
                              subtitle: Text(
                                "Mobile: ${details["mobile_self"] ?? 'N/A'}",
                              ),
                              trailing: Text(
                                item["attendance"] == "Present"
                                    ? "Present"
                                    : "Absent",
                                style: TextStyle(
                                  color: item["attendance"] == "Present"
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
