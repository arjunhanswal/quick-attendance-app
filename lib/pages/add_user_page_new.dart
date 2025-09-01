import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final TextEditingController _otherInfoController = TextEditingController();
  final TextEditingController _sukhliyaDeptController = TextEditingController();
  final TextEditingController _khandwaDeptController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedDepartment1;
  String? _naamdaanStatus; // Yes / No
  List<String> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadDepartmentsFromSupabase();
  }

  Future<void> _loadDepartmentsFromSupabase() async {
    try {
      final response =
          await Supabase.instance.client.from('departments').select('name');

      setState(() {
        _departments = (response as List)
            .map<String>((d) => d['name'].toString())
            .toList();
      });
    } catch (e) {
      debugPrint('❌ Failed to load departments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load departments: $e')),
      );
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Supabase.instance.client.from('sewadars').insert({
          'badge_number': _badgeNumberController.text,
          'department_sukhliya': _sukhliyaDeptController.text,
          'department_khandwa': _khandwaDeptController.text,
          'name': _nameController.text,
          'father_or_husband_name': _fatherHusbandNameController.text,
          'dob_or_age': _dobAgeController.text,
          'aadhar_number': _aadharController.text,
          'namdaan': _naamdaanStatus,
          'namdaan_date': _naamdaanDateController.text,
          'address': _addressController.text,
          'education': _educationController.text,
          'occupation': _occupationController.text,
          'mobile_self': _mobileSelfController.text,
          'mobile_family': _mobileFamilyController.text,
          'nearest_sewadar': _nearbySewadarController.text,
          'other_info': _otherInfoController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Sewadar info saved successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        debugPrint("❌ Error saving Sewadar: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
                value: _selectedDepartment,
                items: _departments
                    .map(
                        (dep) => DropdownMenuItem(value: dep, child: Text(dep)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDepartment = val;
                    _sukhliyaDeptController.text =
                        val ?? ''; // ✅ keep controller in sync
                  });
                },
                decoration: const InputDecoration(labelText: "Department"),
                validator: (value) => value == null ? "Required" : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedDepartment1,
                items: _departments
                    .map(
                        (dep) => DropdownMenuItem(value: dep, child: Text(dep)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDepartment1 = val;
                    _khandwaDeptController.text =
                        val ?? ''; // ✅ keep controller in sync
                  });
                },
                decoration: const InputDecoration(labelText: "Department"),
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
                    .map(
                        (val) => DropdownMenuItem(value: val, child: Text(val)))
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
                    labelText: "Nearby Known Sewadar Name & Mobile"),
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
