import 'package:bracu_core/api/api_root.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConsultationListPage extends StatefulWidget {
  @override
  _ConsultationListPageState createState() => _ConsultationListPageState();
}

class _ConsultationListPageState extends State<ConsultationListPage> {
  List<Map<String, dynamic>> consultations = [];
  List<String> allCourses = [];
  List<String> allInitials = [];
  List<String> allDays = [];
  List<Map<String, dynamic>> filteredConsultations = [];
  bool isLoading = true;

  String? selectedCourse;
  String? selectedInitial;
  String? selectedDay;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchConsultations();
  }

  Future<void> fetchConsultations() async {
    setState(() {
      isLoading = true;
    });

    String url = '${api_root}/api/faculty/consultations';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('consultations')) {
          final fetchedConsultations = List<Map<String, dynamic>>.from(data['consultations']);
          if (mounted) {
            setState(() {
              consultations = fetchedConsultations;
              filteredConsultations = List.from(consultations);

              allCourses = consultations
                  .map((e) => (e['Course'] as String?)?.split('-').first ?? 'Unknown')
                  .toSet()
                  .toList();
              allInitials = consultations
                  .map((e) => (e['Theory Initial'] as String?) ?? 'Unknown')
                  .toSet()
                  .toList();
              allDays = consultations
                  .expand((e) => ((e['Theory Day'] as String?) ?? 'Unknown').split('+'))
                  .toSet()
                  .toList();

              isLoading = false;
            });
          }
        } else {
          throw Exception('Key "consultations" not found in response');
        }
      } else {
        throw Exception('Failed to load consultations');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching consultations: $e');
    }
  }

  void applyFilter() {
    setState(() {
      filteredConsultations = consultations.where((item) {
        final course = (item['Course'] as String?)?.split('-').first ?? '';
        final initial = item['Theory Initial'] as String? ?? '';
        final day = item['Theory Day'] as String? ?? '';

        final matchesCourse = selectedCourse == null || selectedCourse!.isEmpty || course == selectedCourse;
        final matchesInitial = selectedInitial == null || selectedInitial!.isEmpty || initial == selectedInitial;
        final matchesDay = selectedDay == null || selectedDay!.isEmpty || day.split('+').contains(selectedDay);
        final matchesSearch = searchQuery.isEmpty ||
            course.toLowerCase().contains(searchQuery.toLowerCase()) ||
            initial.toLowerCase().contains(searchQuery.toLowerCase());

        return matchesCourse && matchesInitial && matchesDay && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Faculty Consultations'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Field
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (query) {
                  setState(() {
                    searchQuery = query;
                    applyFilter();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            // Filter Form
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCourse,
                      items: allCourses
                          .map((course) => DropdownMenuItem(
                                value: course,
                                child: Text(
                                  course,
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCourse = value;
                          applyFilter();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Course',
                        labelStyle: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedInitial,
                      items: allInitials
                          .map((initial) => DropdownMenuItem(
                                value: initial,
                                child: Text(
                                  initial,
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedInitial = value;
                          applyFilter();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Theory Initial',
                        labelStyle: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedDay,
                      items: allDays
                          .map((day) => DropdownMenuItem(
                                value: day,
                                child: Text(
                                  day,
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDay = value;
                          applyFilter();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Day',
                        labelStyle: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredConsultations.length,
                      itemBuilder: (context, index) {
                        final item = filteredConsultations[index];
                        return Card(
                          margin: EdgeInsets.all(10),
                          elevation: 3,
                          child: ListTile(
                            title: Text(
                              item['Course']?.split('-').first ?? 'No Course',
                              style: TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Theory: ${item['Theory Day']} @ ${item['Theory Time\n(1hr 20min)']}',
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Room: ${item['Theory Room']}',
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Lab: ${item['Lab Day']} @ ${item['Lab Time (3hr)']}',
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Lab Room: ${item['Lab Room']}',
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            leading: Icon(Icons.person),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
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