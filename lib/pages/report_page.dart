import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'api_service.dart';
import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
// Only import dart:html for web builds
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTimeRange? _selectedRange;
  List<Map<String, dynamic>> presentUsers = [];

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      final from = _selectedRange?.start ?? DateTime.now();
      final to = _selectedRange?.end ?? DateTime.now();

      final fromStr = DateFormat("yyyy-MM-dd").format(from);
      final toStr = DateFormat("yyyy-MM-dd").format(to);

      final response = await ApiService.getdashboardDetails(
        "/dashboard?from=$fromStr&to=$toStr",
        body: {},
      );

      final data = Map<String, dynamic>.from(response ?? {});

      setState(() {
        final rawPresentUsers = data['present_users'];
        if (rawPresentUsers != null && rawPresentUsers is List) {
          presentUsers = rawPresentUsers
              .where((e) => e is Map)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        } else {
          presentUsers = [];
        }
      });

      debugPrint("📋 Report users: ${jsonEncode(presentUsers)}");
    } catch (e, st) {
      debugPrint("❌ Error fetching report: $e\n$st");
      setState(() {
        presentUsers = [];
      });
    }
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange ??
          DateTimeRange(start: DateTime.now(), end: DateTime.now()),
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
      await fetchDashboard();
    }
  }

  // Future<void> _exportToCSV() async {
  //   List<List<String>> csvData = [
  //     ['Sewadar Name', 'Badge No', 'Mobile', 'checkin Time', 'checkout Time','created time']
  //   ];

  //   for (var record in presentUsers) {
  //     Map<String, dynamic> extraData = {};
  //     if (record['data'] != null && record['data'] is String) {
  //       try {
  //         extraData = jsonDecode(record['data']);
  //       } catch (_) {}
  //     }

  //     final name = extraData['sewadar_name'] ?? 'Unknown';
  //     final badge = extraData['badge_no'] ?? '-';
  //     final mobile = extraData['mobile_self'] ?? '-';
  //     final checkintime = record['check_in_time'] ?? '-';
  //     final checkoutitme  = record['check_out_time'] ?? '-';
  //     final rawDate = record['datetime'];
  //     DateTime? timestamp;

  //     if (rawDate != null && rawDate.isNotEmpty) {
  //       final parsed = DateTime.parse(rawDate);

  //       // 🚨 Force backend value to be UTC
  //       timestamp = DateTime.utc(
  //         parsed.year,
  //         parsed.month,
  //         parsed.day,
  //         parsed.hour,
  //         parsed.minute,
  //         parsed.second,
  //       ).toLocal();
  //     }

  //     final time = timestamp != null
  //         ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp)
  //         : '';
  //     ;

  //     csvData.add([name, badge, mobile, time]);
  //   }

  //   final csv = const ListToCsvConverter().convert(csvData);
  //   final fileName =
  //       'attendance_report_${DateTime.now().millisecondsSinceEpoch}.csv';

  //   if (kIsWeb) {
  //     // ✅ Web: trigger browser download
  //     final bytes = utf8.encode(csv);
  //     final blob = html.Blob([bytes], 'text/csv');
  //     final url = html.Url.createObjectUrlFromBlob(blob);
  //     final anchor = html.AnchorElement(href: url)
  //       ..setAttribute('download', fileName)
  //       ..click();
  //     html.Url.revokeObjectUrl(url);
  //   } else {
  //     // ✅ Mobile/Desktop: Save to temp & share
  //     final directory = await getTemporaryDirectory();
  //     final path = '${directory.path}/$fileName';
  //     final file = File(path);
  //     await file.writeAsString(csv);

  //     await Share.shareXFiles([XFile(file.path)],
  //         text: 'Here is the exported attendance report CSV');
  //   }
  // }

  // Future<void> _exportToCSV() async {
  //   List<List<String>> csvData = [
  //     ['Sewadar Name', 'Badge No', 'Mobile', 'Attendance Time']
  //   ];

  //   for (var record in presentUsers) {
  //     Map<String, dynamic> extraData = {};
  //     if (record['data'] != null && record['data'] is String) {
  //       try {
  //         extraData = jsonDecode(record['data']);
  //       } catch (_) {}
  //     }

  //     final name = extraData['sewadar_name'] ?? 'Unknown';
  //     final badge = extraData['badge_no'] ?? '-';
  //     final mobile = extraData['mobile_self'] ?? '-';

  //     final timestamp = DateTime.tryParse(record['datetime'] ?? '');
  //     final time = timestamp != null
  //         ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toLocal())
  //         : '';

  //     csvData.add([name, badge, mobile, time]);
  //   }

  //   final directory = await getTemporaryDirectory();
  //   final path =
  //       '${directory.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.csv';
  //   final file = File(path);
  //   String csv = const ListToCsvConverter().convert(csvData);
  //   await file.writeAsString(csv);

  //   await Share.shareXFiles([XFile(file.path)],
  //       text: 'Here is the exported attendance report CSV');
  // }
  Future<void> _exportToCSV() async {
    List<List<String>> csvData = [
      [
        'Sewadar Name',
        'Badge No',
        'Mobile',
        'Checkin Time',
        'Checkout Time',
        'Created Time'
      ]
    ];

    for (var record in presentUsers) {
      Map<String, dynamic> extraData = {};

      if (record['data'] != null && record['data'] is String) {
        try {
          extraData = jsonDecode(record['data']);
        } catch (_) {}
      }

      final name = extraData['sewadar_name'] ?? 'Unknown';
      final badge = extraData['badge_no'] ?? '-';
      final mobile = extraData['mobile_self'] ?? '-';

      /// ✅ Checkin Checkout
      final checkinTime = record['check_in_time'] ?? '-';
      final checkoutTime = record['check_out_time'] ?? '-';

      /// ✅ Created Time Convert UTC → Local
      final rawDate = record['datetime'];

      DateTime? timestamp;

      if (rawDate != null && rawDate.toString().isNotEmpty) {
        final parsed = DateTime.parse(rawDate);

        timestamp = DateTime.utc(
          parsed.year,
          parsed.month,
          parsed.day,
          parsed.hour,
          parsed.minute,
          parsed.second,
        ).toLocal();
      }

      final createdTime = timestamp != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp)
          : "";

      /// ✅ Add Row
      csvData.add([
        name.toString(),
        badge.toString(),
        mobile.toString(),
        checkinTime.toString(),
        checkoutTime.toString(),
        createdTime
      ]);
    }

    final csv = const ListToCsvConverter().convert(csvData);

    final fileName =
        'attendance_report_${DateTime.now().millisecondsSinceEpoch}.csv';

    if (kIsWeb) {
      final bytes = utf8.encode(csv);

      final blob = html.Blob([bytes], 'text/csv');

      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();

      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getTemporaryDirectory();

      final path = '${directory.path}/$fileName';

      final file = File(path);

      await file.writeAsString(csv);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Here is the exported attendance report CSV',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Report"),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: fetchDashboard),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🔘 Filter + Export
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _selectedRange == null
                        ? "Select Date Range"
                        : "${DateFormat('dd MMM').format(_selectedRange!.start)} - ${DateFormat('dd MMM').format(_selectedRange!.end)}",
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _exportToCSV,
                  icon: const Icon(Icons.download),
                  label: const Text("Export CSV"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 📋 Attendance List
          Expanded(
            child: presentUsers.isEmpty
                ? const Center(child: Text("⚠️ No attendance records found"))
                : ListView.builder(
                    itemCount: presentUsers.length,
                    itemBuilder: (context, index) {
                      final record = presentUsers[index];
                      Map<String, dynamic> extraData = {};
                      if (record['data'] != null && record['data'] is String) {
                        try {
                          extraData = jsonDecode(record['data']);
                        } catch (_) {}
                      }

                      final name = extraData['sewadar_name'] ?? 'Unknown';
                      final badge = extraData['badge_no'] ?? '-';
                      final mobile = extraData['mobile_self'] ?? '-';
                      final timestamp =
                          DateTime.tryParse(record['datetime'] ?? '');
                      final time = timestamp != null
                          ? DateFormat('dd MMM, HH:mm')
                              .format(timestamp.toLocal())
                          : '';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(name),
                          subtitle: Text("Badge: $badge\nMobile: $mobile"),
                          trailing: Text(time),
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
