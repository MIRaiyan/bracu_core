import 'package:flutter/material.dart';

void main() {
  runApp(const CGPACalculatorApp());
}

class CGPACalculatorApp extends StatelessWidget {
  const CGPACalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CGPA Calculator',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const CGPACalculatorScreen(),
    );
  }
}

class CGPACalculatorScreen extends StatefulWidget {
  const CGPACalculatorScreen({super.key});

  @override
  _CGPACalculatorScreenState createState() => _CGPACalculatorScreenState();
}

class _CGPACalculatorScreenState extends State<CGPACalculatorScreen> {
  final TextEditingController _currentCgpaController = TextEditingController();
  final TextEditingController _coursesCompletedController =
  TextEditingController();
  final List<TextEditingController> _courseGpaControllers = List.generate(
    5,
        (index) => TextEditingController(),
  );

  double? _calculatedCgpa;

  void _calculateCgpa() {
    final currentCgpa = double.tryParse(_currentCgpaController.text) ?? 0.0;
    final coursesCompleted =
        int.tryParse(_coursesCompletedController.text) ?? 0;

    double totalPoint = currentCgpa * coursesCompleted;
    int validCourses = 0;

    for (var controller in _courseGpaControllers) {
      if (controller.text.isNotEmpty) {
        totalPoint += double.tryParse(controller.text) ?? 0.0;
        validCourses++;
      }
    }

    if (validCourses >= 3) {
      final cgpa = totalPoint / (coursesCompleted + validCourses);
      setState(() {
        _calculatedCgpa = double.parse(cgpa.toStringAsFixed(2));
      });
    } else {
      setState(() {
        _calculatedCgpa = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least 3 course GPAs.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CGPA Calculator'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your current CGPA:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _currentCgpaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'e.g., 3.50',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter the number of courses completed:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _coursesCompletedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'e.g., 30',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter GPAs for up to 5 courses:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              for (int i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextField(
                    controller: _courseGpaControllers[i],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Course ${i + 1} GPA',
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _calculateCgpa,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Calculate CGPA'),
                ),
              ),
              const SizedBox(height: 16),
              if (_calculatedCgpa != null)
                Center(
                  child: Text(
                    'Your CGPA is: $_calculatedCgpa',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
