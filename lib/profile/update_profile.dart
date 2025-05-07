import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/profile_provider.dart';
import 'profile.dart';

class UpdateProfilePage extends StatefulWidget {
  final String studentId;
  final String phoneNumber;
  final String department;
  final String permanentAddress;
  final String presentAddress;
  final String emergencyContactName;
  final String emergencyContactRelation;
  final String emergencyContactPhoneNumber;

  const UpdateProfilePage({
    Key? key,
    required this.studentId,
    required this.phoneNumber,
    required this.department,
    required this.permanentAddress,
    required this.presentAddress,
    required this.emergencyContactName,
    required this.emergencyContactRelation,
    required this.emergencyContactPhoneNumber,
  }) : super(key: key);

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  late TextEditingController studentIdController;
  late TextEditingController phoneNumberController;
  late TextEditingController departmentController;
  late TextEditingController permanentAddressController;
  late TextEditingController currentAddressController;
  late TextEditingController emergencyContactNameController;
  late TextEditingController emergencyContactRelationController;
  late TextEditingController emergencyContactPhoneNumberController;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    studentIdController = TextEditingController(text: widget.studentId);
    phoneNumberController = TextEditingController(text: widget.phoneNumber);
    departmentController = TextEditingController(text: widget.department);
    permanentAddressController = TextEditingController(text: widget.permanentAddress);
    currentAddressController = TextEditingController(text: widget.presentAddress);
    emergencyContactNameController = TextEditingController(text: widget.emergencyContactName);
    emergencyContactRelationController = TextEditingController(text: widget.emergencyContactRelation);
    emergencyContactPhoneNumberController = TextEditingController(text: widget.emergencyContactPhoneNumber);
  }

  @override
  void dispose() {
    studentIdController.dispose();
    phoneNumberController.dispose();
    departmentController.dispose();
    currentAddressController.dispose();
    permanentAddressController.dispose();
    emergencyContactNameController.dispose();
    emergencyContactRelationController.dispose();
    emergencyContactPhoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<ProfileProvider>(context, listen: false);
    bool success = await provider.updateProfile(
      studentId: studentIdController.text,
      phoneNumber: phoneNumberController.text,
      department: departmentController.text,
      permanentAddress: permanentAddressController.text,
      currentAddress: currentAddressController.text,
      emergencyContact: {
      "name": emergencyContactNameController.text,
      "relation": emergencyContactRelationController.text,
      "phoneNumber": emergencyContactPhoneNumberController.text,
      }
    );

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Profile updated successfully' : 'Failed to update profile'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Student ID', studentIdController),
              _buildTextField('Phone Number', phoneNumberController),
              _buildTextField('Department', departmentController),
              _buildTextField('Permanent Address', permanentAddressController),
              _buildTextField('Present Address', currentAddressController),
              _buildTextField('Emergency Contact Name', emergencyContactNameController),
              _buildTextField('Emergency Contact Relation', emergencyContactRelationController),
              _buildTextField('Emergency Contact Phone Number', emergencyContactPhoneNumberController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
