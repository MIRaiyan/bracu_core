import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPage extends StatefulWidget {
  final String gsuite; // User's email (gsuite)
  const AddPage({Key? key, required this.gsuite}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courseCodeController = TextEditingController();
  final List<TextEditingController> _youtubeControllers = [TextEditingController()];
  final List<TextEditingController> _driveControllers = [TextEditingController()];
  bool isSubmitting = false;

  // Add a new YouTube link field
  void _addYoutubeField() {
    setState(() {
      _youtubeControllers.add(TextEditingController());
    });
  }

  // Add a new Drive link field
  void _addDriveField() {
    setState(() {
      _driveControllers.add(TextEditingController());
    });
  }

  // Submit the form to the backend
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
    });

    final courseData = {
      'courseCode': _courseCodeController.text.trim().toUpperCase(),
      'youtubePlaylists': _youtubeControllers
          .map((controller) => controller.text.trim())
          .where((link) => link.isNotEmpty)
          .toList(),
      'driveFolderLinks': _driveControllers
          .map((controller) => controller.text.trim())
          .where((link) => link.isNotEmpty)
          .toList(),
    };

    try {
      final response = await http.post(
        Uri.parse('https://bracu-core-backend.vercel.app/api/courses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(courseData),
      );

      final bool success = response.statusCode == 201;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Added successfully' : 'Failed to add course'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      if (success) {
        Navigator.pop(context); // Return to SearchPage
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add course'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _courseCodeController.dispose();
    for (var controller in _youtubeControllers) {
      controller.dispose();
    }
    for (var controller in _driveControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verify admin access
    if (widget.gsuite != 'admin@g.bracu.ac.bd') {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Course')),
        body: const Center(child: Text('Unauthorized access')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Course'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Code Tray
              const Text(
                'Course Code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _courseCodeController,
                decoration: InputDecoration(
                  hintText: 'e.g., CSe110',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                textCapitalization: TextCapitalization.characters, // Force uppercase
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Course code is required';
                  }
                  if (!RegExp(r'^[A-Z0-9-]+$').hasMatch(value.trim())) {
                    return 'Course code must be alphanumeric with optional hyphens';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // YouTube Link Tray
              const Text(
                'YouTube Playlists',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._youtubeControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'YouTube playlist link ${index + 1}',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.url,
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addYoutubeField,
                icon: const Icon(Icons.add),
                label: const Text('Add another YouTube link'),
              ),
              const SizedBox(height: 16),

              // Drive Link Tray
              const Text(
                'Drive Folder Links',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._driveControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Drive folder link ${index + 1}',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.url,
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addDriveField,
                icon: const Icon(Icons.add),
                label: const Text('Add another Drive link'),
              ),
              const SizedBox(height: 16),

              // Spacer to push Done button to bottom
              const Spacer(),

              // Done Button
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}