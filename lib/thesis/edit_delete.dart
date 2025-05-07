import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../service/profile_provider.dart';

class EditDeleteThesisPost extends StatefulWidget {
  final Map<String, dynamic> thesisData;

  const EditDeleteThesisPost({Key? key, required this.thesisData}) : super(key: key);

  @override
  State<EditDeleteThesisPost> createState() => _EditDeleteThesisPostState();
}

class _EditDeleteThesisPostState extends State<EditDeleteThesisPost> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _supervisorController = TextEditingController();
  final TextEditingController _membersNeededController = TextEditingController();
  final TextEditingController _currentMembersController = TextEditingController();
  final List<TextEditingController> _domainControllers = [];
  final List<TextEditingController> _topicControllers = [];
  bool isLoading = false;
  final String apiBaseUrl = "https://bracu-core-backend.vercel.app";

  @override
  void initState() {
    super.initState();
    // Initialize controllers with thesisData
    _descriptionController.text = widget.thesisData['description'] ?? '';
    _supervisorController.text = widget.thesisData['supervisor'] ?? '';
    _membersNeededController.text = widget.thesisData['membersNeeded']?.toString() ?? '';
    _currentMembersController.text = widget.thesisData['currentMembers']?.toString() ?? '';

    // Initialize domain controllers
    final domains = widget.thesisData['possibleDomains'] is List ? widget.thesisData['possibleDomains'] : [];
    if (domains.isEmpty) {
      _domainControllers.add(TextEditingController());
    } else {
      for (var domain in domains) {
        _domainControllers.add(TextEditingController(text: domain));
      }
    }

    // Initialize topic controllers
    final topics = widget.thesisData['possibleTopics'] is List ? widget.thesisData['possibleTopics'] : [];
    if (topics.isEmpty) {
      _topicControllers.add(TextEditingController());
    } else {
      for (var topic in topics) {
        _topicControllers.add(TextEditingController(text: topic));
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _supervisorController.dispose();
    _membersNeededController.dispose();
    _currentMembersController.dispose();
    for (var controller in _domainControllers) {
      controller.dispose();
    }
    for (var controller in _topicControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addDomainField() {
    setState(() {
      _domainControllers.add(TextEditingController());
    });
  }

  void _addTopicField() {
    setState(() {
      _topicControllers.add(TextEditingController());
    });
  }

  Future<void> _updateThesis() async {
    final token = context.read<ProfileProvider>().authToken;
    final gsuite = context.read<ProfileProvider>().gsuite; // Get gsuite
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to update your post")),
      );
      return;
    }
    if (gsuite == null || gsuite.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gsuite not available. Please log in again.")),
      );
      return;
    }

    final domains = _domainControllers.map((controller) => controller.text.trim()).where((domain) => domain.isNotEmpty).toList();
    final topics = _topicControllers.map((controller) => controller.text.trim()).where((topic) => topic.isNotEmpty).toList();

    if (domains.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("At least one domain is required")),
      );
      return;
    }

    final membersNeededText = _membersNeededController.text.trim();
    final currentMembersText = _currentMembersController.text.trim();
    if (membersNeededText.isEmpty || currentMembersText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Members needed and current members are required")),
      );
      return;
    }

    final membersNeeded = int.tryParse(membersNeededText);
    final currentMembers = int.tryParse(currentMembersText);
    if (membersNeeded == null || currentMembers == null || membersNeeded < currentMembers || currentMembers < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid member counts")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final payload = {
        "userId": widget.thesisData['userId'],
        "email": gsuite, // Include gsuite as email
        "possibleDomains": domains,
        "possibleTopics": topics,
        "membersNeeded": membersNeeded,
        "currentMembers": currentMembers,
        "supervisor": _supervisorController.text.trim(),
        "description": _descriptionController.text.trim(),
      };

      final response = await http.put(
        Uri.parse("$apiBaseUrl/api/thesis/${widget.thesisData['_id']}"),
        headers: {
          "Authorization": token,
          "Content-Type": "application/json",
        },
        body: json.encode(payload),
      );
      print("updateThesis status: ${response.statusCode}");
      print("updateThesis body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thesis post updated successfully")),
        );
        Navigator.pop(context);
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Not authorized to update this post")),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post not found for this gsuite")),
        );
      } else {
        final error = json.decode(response.body)['error'] ?? "Unknown error";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update post: ${response.statusCode} - $error")),
        );
      }
    } catch (e) {
      print("updateThesis error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteThesis() async {
    final token = context.read<ProfileProvider>().authToken;
    final gsuite = context.read<ProfileProvider>().gsuite; // Get gsuite
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to delete your post")),
      );
      return;
    }
    if (gsuite == null || gsuite.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gsuite not available. Please log in again.")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.delete(
        Uri.parse("$apiBaseUrl/api/thesis/${widget.thesisData['_id']}"),
        headers: {
          "Authorization": token,
          "Content-Type": "application/json",
        },
        body: json.encode({
          "email": gsuite, // Include gsuite as email
        }),
      );
      print("deleteThesis status: ${response.statusCode}");
      print("deleteThesis body: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thesis post deleted successfully")),
        );
        Navigator.pop(context);
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Not authorized to delete this post")),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post not found for this gsuite")),
        );
      } else {
        final error = json.decode(response.body)['error'] ?? "Unknown error";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete post: ${response.statusCode} - $error")),
        );
      }
    } catch (e) {
      print("deleteThesis error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit/Delete Thesis Post")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    hintText: 'Domain ${index + 1} (e.g., AI, ML)',
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

            // Members Needed
            TextFormField(
              controller: _membersNeededController,
              decoration: const InputDecoration(
                labelText: 'Members Needed',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Current Members
            TextFormField(
              controller: _currentMembersController,
              decoration: const InputDecoration(
                labelText: 'Current Members',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Supervisor
            TextFormField(
              controller: _supervisorController,
              decoration: const InputDecoration(
                labelText: 'Supervisor (Optional)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateThesis,
                    child: const Text("Update"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Delete"),
                          content: const Text("Are you sure you want to delete this post?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        _deleteThesis();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Delete"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}