import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGPA Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.orange[300]!,
          secondary: Colors.orange[200]!,
          background: Colors.white,
        ),
      ),
      home: const CgpaCalculatorScreen(),
    );
  }
}

class CgpaCalculatorScreen extends StatefulWidget {
  const CgpaCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CgpaCalculatorScreen> createState() => _CgpaCalculatorScreenState();
}

class _CgpaCalculatorScreenState extends State<CgpaCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  // User data
  final Map<String, dynamic> user = {"currentCgpa": 0.0, "coursesCompleted": 0};

  // Course GPA list
  final List<double> courseGpa = [];

  // Number of resources to calculate
  int numberOfCourses = 3;

  // Controllers for course grades
  final List<TextEditingController> gradeControllers = List.generate(
    5, // Maximum 5 resources
    (index) => TextEditingController(),
  );

  // Controllers for user data
  final TextEditingController currentCgpaController = TextEditingController();
  final TextEditingController coursesCompletedController =
      TextEditingController();

  // Result
  String resultCgpa = "";
  bool showResult = false;

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in gradeControllers) {
      controller.dispose();
    }
    currentCgpaController.dispose();
    coursesCompletedController.dispose();
    super.dispose();
  }

  // Calculate CGPA based on the provided formula
  double calculate() {
    double totalPoint = user["currentCgpa"] * user["coursesCompleted"];

    courseGpa.clear();
    for (int i = 0; i < numberOfCourses; i++) {
      courseGpa.add(double.parse(gradeControllers[i].text));
    }

    for (var i = 0; i < courseGpa.length; i++) {
      totalPoint += courseGpa[i];
    }

    double cgpa = totalPoint / (user["coursesCompleted"] + courseGpa.length);

    return cgpa;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        user["currentCgpa"] = double.parse(currentCgpaController.text);
        user["coursesCompleted"] = int.parse(coursesCompletedController.text);

        double calculatedCgpa = calculate();
        resultCgpa = calculatedCgpa.toStringAsFixed(2);
        showResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CGPA Calculator',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),

              // Current CGPA
              TextFormField(
                controller: currentCgpaController,
                decoration: InputDecoration(
                  labelText: 'Current CGPA',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.orange[50],
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current CGPA';
                  }
                  double? cgpa = double.tryParse(value);
                  if (cgpa == null || cgpa < 0 || cgpa > 4.0) {
                    return 'CGPA must be between 0.0 and 4.0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Courses Completed
              TextFormField(
                controller: coursesCompletedController,
                decoration: InputDecoration(
                  labelText: 'Courses Completed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.orange[50],
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of resources completed';
                  }
                  int? courses = int.tryParse(value);
                  if (courses == null || courses < 0) {
                    return 'Number of resources must be a positive number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Number of courses selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Number of resources:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<int>(
                    value: numberOfCourses,
                    items:
                        [3, 4, 5].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        numberOfCourses = newValue!;
                        showResult = false;
                      });
                    },
                    dropdownColor: Colors.orange[50],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Course GPAs
              ...List.generate(numberOfCourses, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: gradeControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Course ${index + 1} GPA (3 Credits)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.orange[50],
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the GPA for this course';
                      }
                      double? gpa = double.tryParse(value);
                      if (gpa == null || gpa < 0 || gpa > 4.0) {
                        return 'GPA must be between 0.0 and 4.0';
                      }
                      return null;
                    },
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Calculate Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Calculate CGPA',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 24),

              // Result Display
              if (showResult)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your Calculated CGPA:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resultCgpa,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
