import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/profile_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ThesisPostPage extends StatefulWidget {
  const ThesisPostPage({super.key});

  @override
  State<ThesisPostPage> createState() => _ThesisPostPageState();
}

class _ThesisPostPageState extends State<ThesisPostPage> {
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _domainControllers = [TextEditingController()];
  final List<TextEditingController> _topicControllers = [TextEditingController()];
  final TextEditingController _supervisorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _membersNeededController = TextEditingController();
  final TextEditingController _currentMembersController = TextEditingController();

  bool _isLoading = false;

  // Add a new domain field
  void _addDomainField() {
    setState(() {
      _domainControllers.add(TextEditingController());
    });
  }

  // Add a new topic field
  void _addTopicField() {
    setState(() {
      _topicControllers.add(TextEditingController());
    });
  }

  Future<void> _submitForm(String gsuite) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Collect domains and topics, trim whitespace, and filter out empty values
    final domains = _domainControllers
        .map((controller) => controller.text.trim())
        .where((domain) => domain.isNotEmpty)
        .toList();
    final topics = _topicControllers
        .map((controller) => controller.text.trim())
        .where((topic) => topic.isNotEmpty)
        .toList();

    // Validate domains and topics
    if (domains.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("At least one domain is required")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    if (topics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("At least one topic is required")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final payload = {
      "email": gsuite,
      "possibleDomains": domains,
      "possibleTopics": topics,
      "supervisor": _supervisorController.text.trim(),
      "description": _descriptionController.text.trim(),
      "membersNeeded": int.tryParse(_membersNeededController.text) ?? 0,
      "currentMembers": int.tryParse(_currentMembersController.text) ?? 0,
    };

    final token = Provider.of<ProfileProvider>(context, listen: false).authToken;

    try {
      final response = await http.post(
        Uri.parse("https://bracu-core-backend.vercel.app/api/thesis"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token, // Removed "Bearer " prefix to match middleware
        },
        body: json.encode(payload),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post created successfully")),
        );
        Navigator.pop(context);
      } else {
        final error = json.decode(response.body)['error'] ?? "Something went wrong";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $error")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _domainControllers) {
      controller.dispose();
    }
    for (var controller in _topicControllers) {
      controller.dispose();
    }
    _supervisorController.dispose();
    _descriptionController.dispose();
    _membersNeededController.dispose();
    _currentMembersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gsuite = Provider.of<ProfileProvider>(context).gsuite;

    return Scaffold(
      appBar: AppBar(title: const Text("Post Thesis Group")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Logged in as: $gsuite", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Domains Tray
              const Text(
                'Possible Domains',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._domainControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Domain ${index + 1} (e.g., AI)',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            if (_domainControllers.length > 1) {
                              _domainControllers.removeAt(index);
                              controller.dispose();
                            } else {
                              controller.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addDomainField,
                icon: const Icon(Icons.add),
                label: const Text('Add another domain'),
              ),
              const SizedBox(height: 16),

              // Topics Tray
              const Text(
                'Possible Topics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._topicControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Topic ${index + 1} (e.g., Neural Networks)',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            if (_topicControllers.length > 1) {
                              _topicControllers.removeAt(index);
                              controller.dispose();
                            } else {
                              controller.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addTopicField,
                icon: const Icon(Icons.add),
                label: const Text('Add another topic'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _supervisorController,
                decoration: const InputDecoration(
                  labelText: "Supervisor (optional)",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description (optional)",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white70,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _membersNeededController,
                decoration: const InputDecoration(
                  labelText: "Members Needed",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white70,
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty || int.tryParse(val) == null ? "Enter a valid number" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _currentMembersController,
                decoration: const InputDecoration(
                  labelText: "Current Members",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white70,
                ),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty || int.tryParse(val) == null ? "Enter a valid number" : null,
              ),
              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () => _submitForm(gsuite),
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}