import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../api/api_root.dart';
import '../widgets/custom_input_field.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _gsuiteController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedGender = 'Male';
  bool passEnable = true;


  Future<void> handle_registration() async {
    if (_formKey1.currentState!.validate() && _formKey2.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      const String uri = "${api_root}/register.php";

      final Map<String, dynamic> requestBody = {
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "gsuite": _gsuiteController.text.trim(),
        "phoneNumber": _phoneController.text.trim(),
        "studentId": _studentIdController.text.trim(),
        "department": _departmentController.text.trim(),
        "gender": _selectedGender,
        "password": _passwordController.text,
        "admission_year": null,
        "profilePicture": "https://decisionsystemsgroup.github.io/workshop-html/img/john-doe.jpg",
        "bio": null,
        "currentAddress": null,
        "permanentAddress": null,
        "bloodGroup": null,
        "emergencyContact": {
          "name": null,
          "relation": null,
          "phoneNumber": null,
        },
        "cgpa": double.parse("0.0"),
        "completedCredits": int.parse("0"),
        "totalCredits": int.parse("0"),
        "role": "Student",
        "accountVerified": false,
        "studentIdImages": {
          "front": "https://i.fbcd.co/products/resized/resized-750-500/44-32586d03d0647878c6ef48e35b1c7f313f5551d92b0b3fbb1c920f18f3d2ecef.jpg",
          "back": "https://i.fbcd.co/products/resized/resized-750-500/44-32586d03d0647878c6ef48e35b1c7f313f5551d92b0b3fbb1c920f18f3d2ecef.jpg",
        },
        "clubMemberships": [null],
        "ongoingCourses": [
          {
            "courseCode": null,
            "courseTitle": null,
            "section": null,
            "faculty": null
          },
          {
            "courseCode": null,
            "courseTitle": null,
            "section": null,
            "faculty": null,
          },
        ],
        "registeredDevices": [null],
        "lastLogin": DateTime.now().toIso8601String(),
      };

      try {
        final response = await http.post(
          Uri.parse(uri),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(requestBody),
        );

        // Close loading dialog
        if (context.mounted) Navigator.of(context).pop();

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);

          if (jsonResponse['success'] == 'true') {
            Fluttertoast.showToast(msg: "✅ Registration successful");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const login()),
            );
          } else {
            Fluttertoast.showToast(msg: "❌ ${jsonResponse['message']}");
            print("Error: ${jsonResponse['message']}");
          }
        } else {
          Fluttertoast.showToast(msg: "⚠️ Failed to register. Try again.");
          print("Failed to register. Status code: ${response.statusCode}");
        }
      } catch (error) {
        // Close loading dialog if error occurs
        if (context.mounted) Navigator.of(context).pop();
        Fluttertoast.showToast(msg: "🚨 Network error. Please check your connection.");
        print("Exception: $error");
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      passEnable = !passEnable;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/ui/Login.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildFirstPage(),
            _buildSecondPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstPage() {
    return SingleChildScrollView(
      child: Center(
        child: Form(
          key: _formKey1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 160),
              Center(
                child: Image.asset(
                    "assets/logo/bracu_core.png",
                    width: 200),
              ),
              const Text(
                "Register!",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                  fontFamily: "nicomoji",
                ),
              ),
              const SizedBox(height: 6),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    CustomInputField(
                      controller: _firstNameController,
                      hintText: "First Name",
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your first name";
                        }
                        return null;
                      },
                    ),
                    CustomInputField(
                      controller: _lastNameController,
                      hintText: "Last Name",
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your last name";
                        }
                        return null;
                      },
                    ),
                    CustomInputField(
                      controller: _gsuiteController,
                      hintText: "Gsuite",
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your gsuite";
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Please enter a valid gsuite";
                        }
                        return null;
                      },
                    ),
                    CustomInputField(
                      controller: _phoneController,
                      hintText: "Phone Number",
                      icon: Icons.phone,
                      isNumeric: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your phone number";
                        }
                        return null;
                      },
                    ),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 20, right: 20, left: 20),
                        child: SizedBox(
                          height: 60,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.all(18),
                            ),
                            onPressed: () {
                              if (_formKey1.currentState!.validate()) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: const Text(
                              "Next",
                              style: TextStyle(fontSize: 18, letterSpacing: .4, color: Color(0xFFD45858)),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10,),

                    _buildButton(),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondPage() {
    return SingleChildScrollView(
      child: Center(
        child: Form(
          key: _formKey2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 160),
              Center(
                child: Image.asset(
                    "assets/logo/bracu_core.png",
                    width: 200),
              ),
              const Text(
                "Register!",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                  fontFamily: "nicomoji",
                ),
              ),
              const SizedBox(height: 6),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    CustomInputField(
                      controller: _studentIdController,
                      hintText: "Student ID",
                      icon: Icons.badge,
                      isNumeric: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your student ID";
                        }
                        return null;
                      },
                    ),
                    CustomInputField(
                      controller: _departmentController,
                      hintText: "Department",
                      icon: Icons.school,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your department";
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      items: ['Male', 'Female', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedGender = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    CustomInputField(
                      controller: _passwordController,
                      hintText: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                      isPasswordVisible: !passEnable,
                      onTogglePasswordVisibility: _togglePasswordVisibility,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        } else if (value.length < 8) {
                          return "Password must be at least 8 characters long";
                        }
                        return null;
                      },
                    ),
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 20, right: 20, left: 20),
                        child: SizedBox(
                          height: 60,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.9),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.all(18),
                            ),
                            onPressed: handle_registration,
                            child: const Text(
                              "Register",
                              style: TextStyle(fontSize: 18, letterSpacing: .4, color: Color(0xFFD45858)),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10,),

                    _buildButton(),


                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const login()),
          );
        },
        child: Text (
          "Login ?",
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
    );
  }
}