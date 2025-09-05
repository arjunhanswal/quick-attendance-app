import 'package:flutter/material.dart';
import 'api_service.dart';
import 'session_manager.dart';

class AddUserPageNew extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final bool isEdit;

  const AddUserPageNew({super.key, this.isEdit = false, this.userData});

  @override
  _SewadarFormState createState() => _SewadarFormState();
}

class _SewadarFormState extends State<AddUserPageNew> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _badgeNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _fatherHusbandNameController = TextEditingController();
  final _dobAgeController = TextEditingController();
  final _aadharController = TextEditingController();
  final _naamdaanDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _educationController = TextEditingController();
  final _occupationController = TextEditingController();
  final _mobileSelfController = TextEditingController();
  final _mobileFamilyController = TextEditingController();
  final _nearbySewadarController = TextEditingController();
  final _mobileNearbyController = TextEditingController();
  final _otherInfoController = TextEditingController();

  String? _naamdaanStatus;
  int? _selectedDepartmentSukhliya;
  int? _selectedDepartmentKhandwa;
  List<Map<String, dynamic>> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadDepartments();

    if (widget.isEdit && widget.userData != null) {
      final data = widget.userData!;
      _badgeNumberController.text = data['badge_no'] ?? '';
      _nameController.text = data['sewadar_name'] ?? '';
      _fatherHusbandNameController.text = data['father_or_husband_name'] ?? '';
      _dobAgeController.text = data['dob_or_age'] ?? '';
      _aadharController.text = data['aadhaar_no'] ?? '';
      _naamdaanStatus = data['namdan_status'];
      _naamdaanDateController.text = data['namdan_date'] ?? '';
      _addressController.text = data['address'] ?? '';
      _educationController.text = data['education'] ?? '';
      _occupationController.text = data['occupation'] ?? '';
      _mobileSelfController.text = data['mobile_self'] ?? '';
      _mobileFamilyController.text = data['mobile_family'] ?? '';
      _nearbySewadarController.text = data['nearest_sewadar_name'] ?? '';
      _mobileNearbyController.text = data['nearest_sewadar_mobile'] ?? '';
      _otherInfoController.text = data['other_info'] ?? '';
      _selectedDepartmentSukhliya =
          data['dept_id0'] != null && data['dept_id0'].toString().isNotEmpty
              ? int.tryParse(data['dept_id0'].toString())
              : null;

      _selectedDepartmentKhandwa =
          data['dept_id1'] != null && data['dept_id1'].toString().isNotEmpty
              ? int.tryParse(data['dept_id1'].toString())
              : null;
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final response = await ApiService.getDepartments();
      setState(() {
        _departments = response.cast<Map<String, dynamic>>();
        // ✅ Set default if empty
        if (_departments.isNotEmpty) {
          _selectedDepartmentSukhliya ??= _departments.first['id'];
          _selectedDepartmentKhandwa ??= _departments.first['id'];
        }
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

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _saveForm() async {
    final userId = await SessionManager.getUserId();
    if (_formKey.currentState!.validate()) {
      try {
        final sewadarData = {
          "badge_no": _badgeNumberController.text,
          "sewadar_name": _nameController.text,
          "father_or_husband_name": _fatherHusbandNameController.text,
          "dob_or_age": _dobAgeController.text,
          "aadhaar_no": _aadharController.text,
          "namdan_status": _naamdaanStatus ?? "",
          "namdan_date": _naamdaanDateController.text,
          "address": _addressController.text,
          "education": _educationController.text,
          "occupation": _occupationController.text,
          "mobile_self": _mobileSelfController.text,
          "mobile_family": _mobileFamilyController.text,
          "nearest_sewadar_name": _nearbySewadarController.text,
          "nearest_sewadar_mobile": _mobileNearbyController.text,
          "other_info": _otherInfoController.text,
          "dept_id0": (_selectedDepartmentSukhliya ?? "").toString(),
          "dept_id1": (_selectedDepartmentKhandwa ?? "").toString(),
        };

        if (widget.isEdit && widget.userData != null) {
          await ApiService.updateSewadar(
            widget.userData!['sid'].toString(),
            sewadarData,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Sewadar updated successfully!')),
          );
        } else {
          await ApiService.addSewadar(createdBy: userId, data: sewadarData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Sewadar added successfully!')),
          );
        }

        Navigator.pop(context, true);
      } catch (e) {
        debugPrint("❌ Error saving Sewadar: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sewadar Information")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSection("Basic Details", [
                  TextFormField(
                    controller: _badgeNumberController,
                    decoration:
                        const InputDecoration(labelText: "Badge Number"),
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: "Sewadar Name"),
                    validator: (value) => value!.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: _fatherHusbandNameController,
                    decoration:
                        const InputDecoration(labelText: "Father/Husband Name"),
                  ),
                  TextFormField(
                    controller: _dobAgeController,
                    readOnly: true,
                    onTap: () => _pickDate(_dobAgeController),
                    decoration:
                        const InputDecoration(labelText: "Date of Birth / Age"),
                  ),
                  TextFormField(
                    controller: _aadharController,
                    decoration:
                        const InputDecoration(labelText: "Aadhaar Number"),
                    keyboardType: TextInputType.number,
                  ),
                ]),
                _buildSection("Departments", [
                  DropdownButtonFormField<int>(
                    value: _selectedDepartmentSukhliya,
                    items: _departments
                        .map((dep) => DropdownMenuItem<int>(
                              value: dep['id'],
                              child: Text(dep['name']),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedDepartmentSukhliya = val),
                    decoration: const InputDecoration(
                        labelText: "Department (Sukhliya)"),
                  ),
                  DropdownButtonFormField<int>(
                    value: _selectedDepartmentKhandwa,
                    items: _departments
                        .map((dep) => DropdownMenuItem<int>(
                              value: dep['id'],
                              child: Text(dep['name']),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedDepartmentKhandwa = val),
                    decoration: const InputDecoration(
                        labelText: "Department (Khandwa)"),
                    validator: (value) => value == null ? "Required" : null,
                  ),
                ]),
                _buildSection("Naamdaan", [
                  DropdownButtonFormField<String>(
                    value: _naamdaanStatus,
                    items: ["Yes", "No"]
                        .map((val) => DropdownMenuItem(
                              value: val,
                              child: Text(val),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _naamdaanStatus = val),
                    decoration:
                        const InputDecoration(labelText: "Naamdaan Status"),
                    validator: (value) => value == null ? "Required" : null,
                  ),
                  TextFormField(
                    controller: _naamdaanDateController,
                    readOnly: true,
                    onTap: () => _pickDate(_naamdaanDateController),
                    decoration:
                        const InputDecoration(labelText: "Naamdaan Date/Year"),
                  ),
                ]),
                _buildSection("Contact Info", [
                  TextFormField(
                    controller: _mobileSelfController,
                    decoration: const InputDecoration(
                        labelText: "Mobile Number (Self)"),
                    keyboardType: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: _mobileFamilyController,
                    decoration: const InputDecoration(
                        labelText: "Mobile Number (Family)"),
                    keyboardType: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: _nearbySewadarController,
                    decoration: const InputDecoration(
                        labelText: "Nearby Known Sewadar Name"),
                  ),
                  TextFormField(
                    controller: _mobileNearbyController,
                    decoration: const InputDecoration(
                        labelText: "Nearby Sewadar Mobile"),
                    keyboardType: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration:
                        const InputDecoration(labelText: "Home Address"),
                  ),
                ]),
                _buildSection("Other Details", [
                  TextFormField(
                    controller: _educationController,
                    decoration: const InputDecoration(
                        labelText: "Education / Qualification"),
                  ),
                  TextFormField(
                    controller: _occupationController,
                    decoration: const InputDecoration(labelText: "Occupation"),
                  ),
                  TextFormField(
                    controller: _otherInfoController,
                    decoration:
                        const InputDecoration(labelText: "Other Information"),
                  ),
                ]),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _saveForm,
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
