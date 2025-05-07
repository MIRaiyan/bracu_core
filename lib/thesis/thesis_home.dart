import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'thesis_post.dart';
import 'edit_delete.dart';
import '../service/profile_provider.dart';
import 'package:provider/provider.dart';

class ThesisHome extends StatefulWidget {
  const ThesisHome({Key? key}) : super(key: key);

  @override
  State<ThesisHome> createState() => _ThesisHomeState();
}

class _ThesisHomeState extends State<ThesisHome> {
  List<dynamic> thesisGroups = [];
  bool isLoading = true;
  int? expandedIndex;

  final List<TextEditingController> _domainControllers = [TextEditingController()];
  final String apiBaseUrl = "https://bracu-core-backend.vercel.app";

  @override
  void initState() {
    super.initState();
    fetchAllGroups();
  }

  @override
  void dispose() {
    for (var controller in _domainControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Add a new domain field
  void _addDomainField() {
    setState(() {
      _domainControllers.add(TextEditingController());
    });
  }

  Future<void> fetchAllGroups() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$apiBaseUrl/api/thesis"));
      print("fetchAllGroups status: ${response.statusCode}");
      print("fetchAllGroups body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          thesisGroups = data;
          print("fetchAllGroups parsed: $thesisGroups");
        } else {
          print("Unexpected data format: $data");
          thesisGroups = [];
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid data format from server")),
          );
        }
      } else if (response.statusCode == 404) {
        thesisGroups = [];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Thesis groups endpoint not found. Please check the backend or contact support.",
            ),
          ),
        );
      } else {
        thesisGroups = [];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load groups: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("fetchAllGroups error: $e");
      thesisGroups = [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMyPostsAndNavigate(BuildContext context) async {
    final token = context.read<ProfileProvider>().authToken;
    final gsuite = context.read<ProfileProvider>().gsuite; // Get gsuite from ProfileProvider
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to view your posts")),
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
      print("Sending request to $apiBaseUrl/api/thesis/by-gsuite?gsuite=$gsuite with token: $token");
      final response = await http.get(
        Uri.parse("$apiBaseUrl/api/thesis/by-gsuite?gsuite=$gsuite"),
        headers: {"Authorization": token},
      );
      print("fetchMyPosts status: ${response.statusCode}");
      print("fetchMyPosts body: ${response.body}");

      if (response.statusCode == 200) {
        final posts = json.decode(response.body);
        if (posts is List && posts.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditDeleteThesisPost(thesisData: posts[0]),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You haven't posted anything yet")),
          );
        }
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gsuite is required. Please log in again.")),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unauthorized: Invalid or expired token. Please log in again.")),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Endpoint not found. Please check the backend setup for /api/thesis/by-gsuite.")),
        );
      } else {
        final error = json.decode(response.body)['error'] ?? "Unknown error";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch your post: ${response.statusCode} - $error")),
        );
      }
    } catch (e) {
      print("fetchMyPosts error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: $e")),
      );
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> searchByDomain() async {
    // Get domains from controllers, trim and filter out empty values
    final domains = _domainControllers
        .map((controller) => controller.text.trim())
        .where((domain) => domain.isNotEmpty)
        .toList();

    if (domains.isEmpty) {
      fetchAllGroups();
      return;
    }

    setState(() => isLoading = true);
    try {
      // Build query string with multiple domain parameters (e.g., domain=AI&domain=ML)
      final queryParams = domains.map((domain) => "domain=$domain").join("&");
      final response = await http.get(
        Uri.parse("$apiBaseUrl/api/thesis/search/domain?$queryParams"),
      );
      print("searchByDomain status: ${response.statusCode}");
      print("searchByDomain body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          thesisGroups = data;
          print("searchByDomain parsed: $thesisGroups");
          if (data.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No groups found for domain(s): ${domains.join(', ')}")),
            );
          }
        } else {
          print("Unexpected search data format: $data");
          thesisGroups = [];
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid search data format")),
          );
        }
      } else if (response.statusCode == 400) {
        thesisGroups = [];
        final error = json.decode(response.body)['error'] ?? "Invalid search parameters";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Search failed: $error")),
        );
      } else {
        thesisGroups = [];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Search failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("searchByDomain error: $e");
      thesisGroups = [];
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
    print("Building with thesisGroups length: ${thesisGroups.length}");
    return Scaffold(
      appBar: AppBar(title: const Text("Find Thesis Group")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Domains Tray
            const Text(
              'Search by Domains',
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
                          searchByDomain();
                        });
                      },
                    ),
                  ),
                  onChanged: (value) => searchByDomain(),
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addDomainField,
              icon: const Icon(Icons.add),
              label: const Text('Add another domain'),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ThesisPostPage()),
                      );
                    },
                    child: const Text("Post"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => fetchMyPostsAndNavigate(context),
                    child: const Text("Edit or Delete your post"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : thesisGroups.isEmpty
                  ? const Center(child: Text("No thesis groups found"))
                  : ListView.builder(
                itemCount: thesisGroups.length,
                itemBuilder: (context, index) {
                  final group = thesisGroups[index];
                  final isExpanded = expandedIndex == index;
                  final topics = group["possibleTopics"] is List ? group["possibleTopics"] : [];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Possible Domain(s): ${(group["possibleDomains"] is List ? group["possibleDomains"].join(", ") : "N/A")}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 6),
                            const Text("Possible Topic(s):"),
                            if (topics.isEmpty)
                              const Text("  N/A")
                            else
                              for (int i = 0; i < topics.length; i++)
                                Text("  Topic ${i + 1}: ${topics[i]?.toString() ?? "N/A"}"),
                            const SizedBox(height: 6),
                            Text("No. of members needed: ${group["membersNeeded"]?.toString() ?? "N/A"}"),
                            Text("Current no. of members: ${group["currentMembers"]?.toString() ?? "N/A"}"),
                            Text("Supervisor (optional): ${group["supervisor"]?.toString() ?? "Not assigned"}"),
                            Text("Posted by: ${group["email"]?.toString() ?? "Anonymous"}"),
                            Text("Description: ${group["description"]?.toString() ?? "N/A"}"),
                            Text("Date: ${group["date"]?.toString() ?? "N/A"}"),
                          ],
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  expandedIndex = isExpanded ? null : index;
                                });
                              },
                              child: Text(isExpanded ? "Hide Details" : "View Details"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}