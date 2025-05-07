import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'course_details.dart';
import 'add.dart';
import 'edit_delete.dart';

class SearchPage extends StatefulWidget {
  final String gsuite; // User's email (gsuite)
  const SearchPage({Key? key, required this.gsuite}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List courses = [];
  List filteredCourses = [];
  String query = "";
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  // Fetch all courses from the backend
  Future<void> fetchCourses() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    const url = 'https://bracu-core-backend.vercel.app/api/courses';
    try {
      final response = await http.get(Uri.parse(url));
      print('Fetch courses response: ${response.statusCode} ${response.body}'); // Debug
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed courses: $data'); // Debug
        setState(() {
          courses = data;
          filteredCourses = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load courses: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Fetch courses error: $e'); // Debug
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching courses: $e';
      });
    }
  }

  // Update search query and filter courses
  void updateSearch(String input) {
    setState(() {
      query = input.toUpperCase();
      filteredCourses = courses
          .where((course) => course['courseCode']
          .toString()
          .toLowerCase()
          .contains(input.toLowerCase()))
          .toList();
      print('Filtered courses: $filteredCourses'); // Debug
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.gsuite == 'admin@g.bracu.ac.bd';
    print('SearchPage gsuite: ${widget.gsuite}, isAdmin: $isAdmin'); // Debug

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Materials'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by course code (e.g., CSE110)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: updateSearch,
              textCapitalization: TextCapitalization.characters,
              controller: TextEditingController(text: query)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: query.length),
                ),
            ),
          ),
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddPage(gsuite: widget.gsuite),
                        ),
                      );
                      fetchCourses();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Add Course'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Select Course to Edit/Delete'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: courses.length,
                              itemBuilder: (context, index) {
                                final course = courses[index];
                                return ListTile(
                                  title: Text(course['courseCode']),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditDeletePage(
                                          gsuite: widget.gsuite,
                                          course: course,
                                        ),
                                      ),
                                    );
                                    fetchCourses();
                                  },
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Edit or Delete Course'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: fetchCourses,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : filteredCourses.isEmpty
                ? const Center(child: Text('No courses found'))
                : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final course = filteredCourses[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      course['courseCode'].toString().toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: const Text('View Materials'),
                    trailing: isAdmin
                        ? IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditDeletePage(
                              gsuite: widget.gsuite,
                              course: course,
                            ),
                          ),
                        );
                        fetchCourses();
                      },
                    )
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SeePage(course: course),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}