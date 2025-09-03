import 'package:flutter/material.dart';
import 'api_service.dart';

class AddUserPageNew extends StatefulWidget {
  const AddUserPageNew({super.key});

  @override
  _SewadarFormState createState() => _SewadarFormState();
}

class _SewadarFormState extends State<AddUserPageNew> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _badgeNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherHusbandNameController =
      TextEditingController();
  final TextEditingController _dobAgeController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _naamdaanDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _mobileSelfController = TextEditingController();
  final TextEditingController _mobileFamilyController = TextEditingController();
  final TextEditingController _nearbySewadarController =
      TextEditingController();
  final TextEditingController _mobileNearbyController = TextEditingController();
  final TextEditingController _otherInfoController = TextEditingController();

  String? _selectedDepartmentSukhliya;
  String? _selectedDepartmentKhandwa;
  String? _naamdaanStatus; // Yes / No

  List<Map<String, dynamic>> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
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

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // ✅ Get department IDs
        final deptSukhliya = _departments.firstWhere(
          (dep) => dep['name'] == _selectedDepartmentSukhliya,
          orElse: () => {'id': 0},
        )['id'];

        final deptKhandwa = _departments.firstWhere(
          (dep) => dep['name'] == _selectedDepartmentKhandwa,
          orElse: () => {'id': 0},
        )['id'];

        // ✅ Pack "data" object
        final Map<String, dynamic> sewadarData = {
          "badge_no": _badgeNumberController.text,
          "sewadar_name": _nameController.text,
          "father_or_husband_name": _fatherHusbandNameController.text,
          "dob_or_age": _dobAgeController.text,
          "aadhaar_no": _aadharController.text,
          "namdan_status": _naamdaanStatus,
          "namdan_date": _naamdaanDateController.text,
          "address": _addressController.text,
          "education": _educationController.text,
          "occupation": _occupationController.text,
          "mobile_self": _mobileSelfController.text,
          "mobile_family": _mobileFamilyController.text,
          "nearest_sewadar_name": _nearbySewadarController.text,
          "nearest_sewadar_mobile": _mobileNearbyController.text,
          "other_info": _otherInfoController.text,
          "dept_id0": deptSukhliya,
          "dept_id1": deptKhandwa,
        };

        // ✅ Call API
        await ApiService.addSewadar(
          createdBy: 1, // 🔁 Replace with logged-in user id
          data: sewadarData,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Sewadar saved successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint("❌ Error saving Sewadar: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sewadar Information")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _badgeNumberController,
                decoration: const InputDecoration(labelText: "Badge Number"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedDepartmentSukhliya,
                items: _departments
                    .map((dep) => DropdownMenuItem<String>(
                          value: dep['name'],
                          child: Text(dep['name']),
                        ))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedDepartmentSukhliya = val),
                decoration:
                    const InputDecoration(labelText: "Department (Sukhliya)"),
                validator: (value) => value == null ? "Required" : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedDepartmentKhandwa,
                items: _departments
                    .map((dep) => DropdownMenuItem<String>(
                          value: dep['name'],
                          child: Text(dep['name']),
                        ))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedDepartmentKhandwa = val),
                decoration:
                    const InputDecoration(labelText: "Department (Khandwa)"),
                validator: (value) => value == null ? "Required" : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Sewadar Name"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _fatherHusbandNameController,
                decoration:
                    const InputDecoration(labelText: "Father/Husband Name"),
              ),
              TextFormField(
                controller: _dobAgeController,
                decoration:
                    const InputDecoration(labelText: "Date of Birth / Age"),
              ),
              TextFormField(
                controller: _aadharController,
                decoration: const InputDecoration(labelText: "Aadhar Number"),
              ),
              DropdownButtonFormField<String>(
                value: _naamdaanStatus,
                items: ["Yes", "No"]
                    .map((val) =>
                        DropdownMenuItem<String>(value: val, child: Text(val)))
                    .toList(),
                onChanged: (val) => setState(() => _naamdaanStatus = val),
                decoration:
                    const InputDecoration(labelText: "Naamdaan (Yes/No)"),
              ),
              TextFormField(
                controller: _naamdaanDateController,
                decoration:
                    const InputDecoration(labelText: "Naamdaan Date/Year"),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Home Address"),
              ),
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
                controller: _mobileSelfController,
                decoration:
                    const InputDecoration(labelText: "Mobile Number (Self)"),
              ),
              TextFormField(
                controller: _mobileFamilyController,
                decoration: const InputDecoration(
                    labelText: "Mobile Number (Family Member)"),
              ),
              TextFormField(
                controller: _nearbySewadarController,
                decoration: const InputDecoration(
                    labelText: "Nearby Known Sewadar Name"),
              ),
              TextFormField(
                controller: _mobileNearbyController,
                decoration:
                    const InputDecoration(labelText: "Nearby Sewadar Mobile"),
              ),
              TextFormField(
                controller: _otherInfoController,
                decoration:
                    const InputDecoration(labelText: "Other Information"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
