import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';

import '../api/api_root.dart';

class StudentConsultationListPage extends StatefulWidget {
  @override
  _StudentConsultationListPageState createState() => _StudentConsultationListPageState();
}

class _StudentConsultationListPageState extends State<StudentConsultationListPage> {
  List<Map<String, dynamic>> consultations = [];
  List<String> allCourses = [];
  List<String> allSections = [];
  List<String> allInitials = [];
  List<Map<String, dynamic>> filteredConsultations = [];
  bool isLoading = true;

  String? selectedCourse;
  String? selectedSection;
  String? selectedInitial;
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

    String url = '$api_root/api/stconsultation';
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
                  .map((e) => e['Course'] as String? ?? 'Unknown')
                  .toSet()
                  .toList();
              allSections = consultations
                  .map((e) => e['Section'] as String? ?? 'Unknown')
                  .toSet()
                  .toList();
              allInitials = consultations
                  .map((e) => e['Initial'] as String? ?? 'Unknown')
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
        final course = item['Course'] as String? ?? '';
        final section = item['Section'] as String? ?? '';
        final initial = item['Initial'] as String? ?? '';
        final name = item['Name'] as String? ?? '';

        final matchesCourse = selectedCourse == null || selectedCourse!.isEmpty || course == selectedCourse;
        final matchesSection = selectedSection == null || selectedSection!.isEmpty || section == selectedSection;
        final matchesInitial = selectedInitial == null || selectedInitial!.isEmpty || initial == selectedInitial;
        final matchesSearch = searchQuery.isEmpty ||
            course.toLowerCase().contains(searchQuery.toLowerCase()) ||
            section.toLowerCase().contains(searchQuery.toLowerCase()) ||
            initial.toLowerCase().contains(searchQuery.toLowerCase()) ||
            name.toLowerCase().contains(searchQuery.toLowerCase());

        return matchesCourse && matchesSection && matchesInitial && matchesSearch;
      }).toList();
    });
  }

  Widget buildSearchBar() {
    return Padding(
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
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: Lottie.asset(
            'assets/animation/search.json',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            repeat: true,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: TextStyle(fontSize: 12, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14, color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
        ),
      ),
    );
  }

  Widget buildCard(Map<String, dynamic> item) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/ui/card_back_st.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['Name']} (${item['Studen ID']})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  'Initial: ${item['Initial'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Course: ${item['Course']} - Section: ${item['Section']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'GSuite: ${item['GSuite']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Room: ${item['Room']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Lab: ${item['Lab']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Student Consultations',
          style: TextStyle(color: Colors.black, letterSpacing: 2, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildSearchBar(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  buildDropdown('Course', selectedCourse, allCourses, (value) {
                    setState(() {
                      selectedCourse = value;
                      applyFilter();
                    });
                  }),
                  SizedBox(width: 8),
                  buildDropdown('Section', selectedSection, allSections, (value) {
                    setState(() {
                      selectedSection = value;
                      applyFilter();
                    });
                  }),
                  SizedBox(width: 8),
                  buildDropdown('Initial', selectedInitial, allInitials, (value) {
                    setState(() {
                      selectedInitial = value;
                      applyFilter();
                    });
                  }),
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
                  return buildCard(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}