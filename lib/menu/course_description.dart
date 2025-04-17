import 'package:flutter/material.dart';

void main() {
  runApp(CourseApp());
}

class CourseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course List',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: CourseListPage(),
    );
  }
}

class Course {
  final String title;
  final String description;

  Course({required this.title, required this.description});
}

final List<Course> courses = [
  Course(title: 'CSE101: Intro to Programming', description: 'Basics of programming in Python, logic building and algorithms.'),
  Course(title: 'CSE220: Data Structures', description: 'Covers arrays, linked lists, stacks, queues, trees, and graphs.'),
  Course(title: 'MATH110: Calculus I', description: 'Differential and integral calculus with applications.'),
  Course(title: 'MATH216: Linear Algebra', description: 'Matrix operations, vector spaces, and eigenvalues.'),
  Course(title: 'ENG101: English Composition', description: 'Basics of academic writing, grammar, and structure.'),
  Course(title: 'ENG103: Technical Writing', description: 'Professional communication and technical documentation skills.')
];

class CourseListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.orange.shade50,
            child: ListTile(
              title: Text(
                courses[index].title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.orange),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDescriptionPage(course: courses[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CourseDescriptionPage extends StatelessWidget {
  final Course course;

  CourseDescriptionPage({required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          course.description,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
