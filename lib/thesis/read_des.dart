import 'package:flutter/material.dart';

class ReadDesPage extends StatelessWidget {
  final Map<String, dynamic> thesisGroup;

  const ReadDesPage({super.key, required this.thesisGroup});

  @override
  Widget build(BuildContext context) {
    List<String> domains = List<String>.from(thesisGroup['possibleDomains']);
    List<String> topics = List<String>.from(thesisGroup['possibleTopics']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thesis Group Details"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Domains:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(domains.join(', ')),
                  const SizedBox(height: 12),

                  const Text("Topics:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ...topics.map((topic) => Text("- $topic")),
                  const SizedBox(height: 12),

                  Text("Members Needed: ${thesisGroup['membersNeeded']}"),
                  Text("Current Members: ${thesisGroup['currentMembers']}"),
                  const SizedBox(height: 12),

                  if (thesisGroup['supervisor'] != null && thesisGroup['supervisor'].toString().trim().isNotEmpty)
                    Text("Supervisor: ${thesisGroup['supervisor']}"),
                  const SizedBox(height: 12),

                  if (thesisGroup['description'] != null && thesisGroup['description'].toString().trim().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(thesisGroup['description']),
                      ],
                    ),
                  const SizedBox(height: 12),

                  Text("Posted by: ${thesisGroup['email']}"),
                  Text("Posted on: ${DateTime.parse(thesisGroup['date']).toLocal().toString().split(' ')[0]}"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
