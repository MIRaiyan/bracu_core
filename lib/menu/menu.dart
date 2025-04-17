import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildGridView(),
              const SizedBox(height: 20),
              _buildTrendingCourses(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    final List<String> options = [
      'CGPA Calculator',
      'Thesis Finder',
      'AI Assistant',
      'Trending Courses',
      'Faculty Information',
      'Emergency Contacts',
      'Routine Generator',
      'St Schedule',
      'Faculty Consultation'
    ];
    final List<IconData> icons = [
      Icons.calculate,
      Icons.search,
      Icons.smart_toy,
      Icons.trending_up,
      Icons.info,
      Icons.phone,
      Icons.schedule,
      Icons.bookmark_add_outlined,
      Icons.bookmark_add_outlined
    ];

    return SizedBox(
      height: 300, // Adjust the height as needed
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
              // Handle tap
            },
            child: _buildCard(options[index], icons[index]),
          );
        },
      ),
    );
  }

  Widget _buildCard(String option, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.teal, width: 1),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal),
            const SizedBox(height: 10),
            Text(
              option,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Trending Courses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Container(
          color: Colors.white10,
          height: 200,
          width: double.infinity,
          child: Center(child: Text("Course placeholder")),
        )
      ],
    );
  }
}