import 'package:bracu_core/menu/ai_assistant.dart';
import 'package:bracu_core/menu/alumnifrontend.dart';
import 'package:bracu_core/menu/cgpa_calc.dart';
import 'package:bracu_core/menu/course_description.dart';
import 'package:bracu_core/menu/faculty_review.dart';
import 'package:bracu_core/menu/st_consultation.dart';
import 'package:bracu_core/profile/help_page.dart';
import 'package:flutter/material.dart';
import '../thesis/thesis_home.dart';
import 'faculty_consultation.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {

  void _navigateTo(BuildContext context, Widget route) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => route));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildGridView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    final List<String> options = [
      'CGPA Calculator',
      'Thesis Finder',
      'AI Assistant',
      'Course info',
      'Faculty Review',
      'Emergency Contacts',
      'Alumni Info',
      'St Schedule',
      'Faculty Consultation'
    ];
    final List<IconData> icons = [
      Icons.calculate,
      Icons.search,
      Icons.smart_toy,
      Icons.golf_course_outlined,
      Icons.info,
      Icons.phone,
      Icons.people_alt_outlined,
      Icons.face_4_outlined,
      Icons.bookmark_add_outlined
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: options.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _handleTap(context, options[index]);
            },
            child: _buildCard(options[index], icons[index]),
          );
        },
      ),
    );
  }

  void _handleTap(BuildContext context, String option) {
    final Map<String, VoidCallback> actions = {
      'CGPA Calculator': () => _navigateTo(context, const CgpaCalculatorScreen()),
      'Thesis Finder': () => _navigateTo(context,  ThesisHome()),
      'AI Assistant': () => _navigateTo(context, const AIAssistantScreen()),
      'Course info': () => _navigateTo(context, const CoursePage()),
      'Faculty Review': () => _navigateTo(context, const FacultyReviewPage()),
      'Emergency Contacts': () => _navigateTo(context, HelpPage()),
      'Alumni Info': () => _navigateTo(context, AlumniInfoPage()),  //ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Coming soon in next update"))),
      'St Schedule': () => _navigateTo(context, StudentConsultationListPage()),
      'Faculty Consultation': () => _navigateTo(context, ConsultationListPage()),
    };

    if (actions.containsKey(option)) {
      actions[option]!(); // Safely invoke the callback
    } else {
      print('Unknown option');
    }
  }

  Widget _buildCard(String option, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.grey, width: 0.7),
      ),
      elevation: 3,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/ui/card_back2.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Text and icon overlay
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.teal),
                const SizedBox(height: 10),
                Text(
                  option,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}