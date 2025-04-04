import 'package:flutter/material.dart';

class Course extends StatelessWidget {
  const Course({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'This is the Course page placeholder',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
