import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiRoot = "https://bracu-core-backend.vercel.app";


// ALUMNI INFO PAGE
class AlumniInfoPage extends StatefulWidget {
  @override
  _AlumniInfoPageState createState() => _AlumniInfoPageState();
}

class _AlumniInfoPageState extends State<AlumniInfoPage> {
  Future<List<dynamic>> fetchAlumni() async {
    final response = await http.get(Uri.parse("$apiRoot/api/alumni"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['alumni'];
    } else {
      throw Exception("Failed to load alumni");
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text("Alumni Info", style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 16),),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    body: FutureBuilder<List<dynamic>>(
      future: fetchAlumni(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text('Error: ${snapshot.error}'));

        final alumni = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: alumni.length,
          itemBuilder: (context, index) {
            final a = alumni[index];
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "👤 ${a['full_name'] ?? ''}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("📧 ${a['email'] ?? ''}"),
                    Text("📱 ${a['phone'] ?? ''}"),
                    Text("🎓 ${a['degree'] ?? ''}, ${a['university'] ?? ''}"),
                    Text("📅 Graduation Year: ${a['graduation_year'] ?? ''}"),
                    Text("🏠 Address: ${a['current_address'] ?? ''}"),
                    if (a['current_position'] != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("💼 ${a['current_position']['title'] ?? ''}"),
                          Text("🏢 ${a['current_position']['company'] ?? ''}"),
                          Text("📍 ${a['current_position']['location'] ?? ''}"),
                        ],
                      ),
                    if ((a['linkedin'] ?? '').isNotEmpty)
                      Text("🔗 LinkedIn: ${a['linkedin']}"),
                    if (a['achievements'] != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("🏅 Achievements:"),
                          ...List.from(
                            a['achievements'],
                          ).map((ach) => Text("• $ach")).toList(),
                        ],
                      ),
                    Text("✅ Approved: ${a['approved'] == true ? 'Yes' : 'No'}"),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: Colors.deepPurple,
      icon: Icon(Icons.add),
      label: Text("Add an alumni?", style: TextStyle(color: Colors.white),),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddAlumniInfoPage()),
      ).then((_) => setState(() {})), // Refresh list
    ),
  );
}

// ADD ALUMNI INFO PAGE
class AddAlumniInfoPage extends StatefulWidget {
  @override
  _AddAlumniInfoPageState createState() => _AddAlumniInfoPageState();
}

class _AddAlumniInfoPageState extends State<AddAlumniInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> alumniData = {
    "full_name": "",
    "email": "",
    "phone": "",
    "graduation_year": 0,
    "degree": "",
    "university": "",
    "current_address": "",
    "current_position": {"title": "", "company": "", "location": ""},
    "linkedin": "",
    "achievements": [],
  };

  final achievementsController = TextEditingController();

  Future<void> submit() async {
    if (achievementsController.text.isNotEmpty) {
      alumniData["achievements"] = achievementsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final response = await http.post(
      Uri.parse("$apiRoot/api/alumni"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(alumniData),
    );
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Alumni added successfully")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed to add alumni")));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text("Add Alumni Info", style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 16),),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            ...["full_name", "email", "phone", "degree", "university"].map(
                  (field) => TextFormField(
                decoration: InputDecoration(labelText: field),
                onChanged: (value) => alumniData[field] = value,
                validator: (v) => v!.isEmpty ? "$field required" : null,
              ),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Graduation Year"),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
              alumniData["graduation_year"] = int.tryParse(value) ?? 0,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Current Address"),
              onChanged: (value) => alumniData["current_address"] = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Current Title"),
              onChanged: (value) =>
              alumniData["current_position"]["title"] = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Current Company"),
              onChanged: (value) =>
              alumniData["current_position"]["company"] = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Current Location"),
              onChanged: (value) =>
              alumniData["current_position"]["location"] = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "LinkedIn URL"),
              onChanged: (value) => alumniData["linkedin"] = value,
            ),
            TextFormField(
              controller: achievementsController,
              decoration: InputDecoration(
                labelText: "Achievements (comma separated)",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Submit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) submit();
              },
            ),
          ],
        ),
      ),
    ),
  );
}