import 'package:bracu_core/api/api_root.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../service/profile_provider.dart';
import 'package:provider/provider.dart';


class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  final Color orangeColor = Color(0xFFF57C00); // Use same orange for both AppBar & button

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        backgroundColor: orangeColor, // Orange AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(
                controller: _currentController,
                label: 'Current Password',
                isHidden: _hideCurrent,
                onToggle: () => setState(() => _hideCurrent = !_hideCurrent),
              ),
              SizedBox(height: 20),
              _buildPasswordField(
                controller: _newController,
                label: 'New Password',
                isHidden: _hideNew,
                onToggle: () => setState(() => _hideNew = !_hideNew),
              ),
              SizedBox(height: 20),
              _buildPasswordField(
                controller: _confirmController,
                label: 'Confirm Password',
                isHidden: _hideConfirm,
                onToggle: () => setState(() => _hideConfirm = !_hideConfirm),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeColor, // Orange button
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final token = await Provider.of<ProfileProvider>(
                      context,
                      listen: false,
                    ).loadAuthToken();

                    try {
                      final response = await http.put(
                        Uri.parse('${api_root}/api/user/update_password'),
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer $token',
                        },
                        body: jsonEncode({
                          'oldPassword': _currentController.text,
                          'newPassword': _newController.text,
                        }),
                      );

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Password updated successfully')),
                        );
                        Navigator.pop(context);
                      } else {
                        final error = jsonDecode(response.body)['message'] ?? 'Something went wrong';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $error')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: Text(
                  'Update Password',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isHidden,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isHidden,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (label == 'Confirm Password' && value != _newController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
