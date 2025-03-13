// import 'dart:convert';
// import 'package:bracu_core/auth/login.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
//
// import '../api/api_root.dart';
//
// class registration extends StatefulWidget {
//   const registration({super.key});
//
//   @override
//   State<registration> createState() => _registrationState();
// }
//
// class _registrationState extends State<registration> {
//   final _formKey = GlobalKey<FormState>();
//   bool passEnable = true;
//   bool cpassEnable = true;
//   bool isPasswordcorrect = true;
//
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//
//   Future<void> insert_record() async {
//
//     if (_formKey.currentState!.validate()) {
//       try {
//         // make POST request UWU :D
//         //const String uri = "http://10.0.2.2/learners_api/sign_up.php";
//         const String uri = "${api_root}/sign_up.php";
//
//         var response = await http.post(
//             Uri.parse(uri),
//             body: {
//               "fname": _firstNameController.text,
//               "lname": _lastNameController.text,
//               "email": _emailController.text,
//               "password": _passwordController.text
//             });
//
//         var jsonResponse = jsonDecode(response.body);
//         if (jsonResponse["success"] == "true") {
//           Fluttertoast.showToast(msg: "Registration successful");
//           Fluttertoast.showToast(msg: "Please login");
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => const login()
//             ),
//           );
//           print("Record inserted");
//         } else {
//           Fluttertoast.showToast(msg: "${jsonResponse['message']}");
//           print(jsonResponse);
//         }
//       } catch (e) {
//         print(e);
//       }
//     } else {
//       print("Please fill all fields correctly");
//     }
//   }
//
//   void _togglePasswordVisibility() {
//     setState(() {
//       passEnable = !passEnable;
//     });
//   }
//
//   void _toggleConfirmPasswordVisibility() {
//     setState(() {
//       cpassEnable = !cpassEnable;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//
//       body: Container(
//         height: MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom,
//         width: MediaQuery.of(context).size.width,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/registration.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//
//         child: Center(
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//
//                   const Text(
//                     "Welcome!",
//                     style: TextStyle(
//                       fontSize: 34,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//
//                   const SizedBox(height: 2),
//
//                   const Text(
//                     "Please Create Your Account",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//
//                   const SizedBox(height: 6),
//
//                   Container(
//                     margin: const EdgeInsets.only(left: 20, right: 20),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12.0),
//                       color: Colors.white,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           offset: const Offset(0, 4),
//                           blurRadius: 10,
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Container(
//                           margin: const EdgeInsets.only(left: 40, right: 40, bottom: 0, top: 40),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: TextFormField(
//                                   controller: _firstNameController,
//                                   decoration: InputDecoration(
//                                     hintText: 'First Name',
//                                     border: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: _firstNameController.text.isNotEmpty
//                                             ? Colors.red
//                                             : Colors.amber,
//                                       ),
//                                     ),
//                                     focusedBorder: const UnderlineInputBorder(
//                                       borderSide: BorderSide(color: Colors.amber),
//                                     ),
//                                   ),
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Please enter your First Name';
//                                     } else if (RegExp(r'\d').hasMatch(value)) {
//                                       return "please enter valid name";
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                               ),
//
//                               const SizedBox(width: 10.0),
//
//                               Expanded(
//                                 child: TextFormField(
//                                   controller: _lastNameController,
//                                   decoration: InputDecoration(
//                                     hintText: "Last Name",
//                                     border: UnderlineInputBorder(
//                                       borderSide: BorderSide(
//                                         color: _lastNameController.text.isNotEmpty
//                                             ? Colors.red
//                                             : Colors.amber,
//                                       ),
//                                     ),
//                                     focusedBorder: const UnderlineInputBorder(
//                                       borderSide: BorderSide(color: Colors.amber),
//                                     ),
//                                   ),
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Please enter your Last Name';
//                                     } else if (RegExp(r'\d').hasMatch(value)) {
//                                       return "please enter valid name";
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         Container(
//                           margin: const EdgeInsets.only(left: 40, right: 40, bottom: 0, top: 0),
//                           child: TextFormField(
//                             controller: _emailController,
//                             keyboardType: TextInputType.emailAddress,
//                             decoration: const InputDecoration(
//                               hintText: "Email",
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.amber),
//                               ),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your Email';
//                               } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                                 return 'Please enter a valid Email';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                         Container(
//                           margin: const EdgeInsets.only(left: 40, right: 40, bottom: 0, top: 0),
//                           child: TextFormField(
//                             controller: _passwordController,
//                             obscureText: passEnable,
//                             decoration: InputDecoration(
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: isPasswordcorrect ? Colors.amber : Colors.red,
//                                 ),
//                               ),
//                               labelStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
//                               hintText: "Password",
//                               suffixIcon: IconButton(
//                                 onPressed: _togglePasswordVisibility,
//                                 icon: Icon(passEnable
//                                     ? Icons.visibility_off
//                                     : Icons.remove_red_eye),
//                                 color: Colors.black38,
//                               ),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your Password';
//                               } else if (value.length < 8) {
//                                 return 'Password must be at least 8 characters long';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                         Container(
//                           margin: const EdgeInsets.only(left: 40, right: 40, bottom: 20, top: 0),
//                           child: TextFormField(
//                             controller: _confirmPasswordController,
//                             obscureText: cpassEnable,
//                             decoration: InputDecoration(
//                               focusedBorder: UnderlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: isPasswordcorrect ? Colors.amber : Colors.red,
//                                 ),
//                               ),
//                               labelStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
//                               hintText: "Confirm Password",
//                               suffixIcon: IconButton(
//                                 onPressed: _toggleConfirmPasswordVisibility,
//                                 icon: Icon(cpassEnable
//                                     ? Icons.visibility_off
//                                     : Icons.remove_red_eye),
//                                 color: Colors.black38,
//                               ),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please confirm your Password';
//                               } else if (value != _passwordController.text) {
//                                 return 'Passwords do not match';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                         Center(
//                           child: SizedBox(
//                             height: 60,
//                             width: MediaQuery.of(context).size.width * 0.6,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.amber[800],
//                                 elevation: 2,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 padding: const EdgeInsets.all(18),
//                               ),
//                               onPressed: () {
//                                 insert_record();
//                               },
//                               child: const Text(
//                                 "Sign Up",
//                                 style: TextStyle(fontSize: 18, letterSpacing: .4, color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(10),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Text(
//                                 "Already have an account?",
//                                 style: TextStyle(
//                                   letterSpacing: .6,
//                                   wordSpacing: 2,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.pushReplacement(
//                                     context,
//                                     MaterialPageRoute(builder: (context) => login()),
//                                   );
//                                 },
//                                 child: const Text(
//                                   'Sign In',
//                                   style: TextStyle(
//                                     color: Colors.orange,
//                                     letterSpacing: 1,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }





import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_root.dart';
import '../service/pofile_provider.dart';
import '../widgets/custom_input_field.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _gsuiteController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  String _selectedGender = 'Male';

  Future<void> handle_registration() async {
    if (_formKey.currentState!.validate()) {
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
      final body = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'gsuite': _gsuiteController.text,
        'phone': _phoneController.text,
        'student_id': _studentIdController.text,
        'department': _departmentController.text,
        'gender': _selectedGender,
      };
      final response = await http.post(
        Uri.parse(uri),
        body: body,
      );

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == 'true') {
          Fluttertoast.showToast(msg: "Registration successful");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const login()));
        } else {
          Fluttertoast.showToast(msg: "${jsonResponse['message']}");
          print('Error: ${jsonResponse['message']}');
        }
      } else {
        Fluttertoast.showToast(msg: "Error failed to register");
        print('Failed to register. Status code: ${response.statusCode}');
      }
    }
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
          key: _formKey,
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
                              if (_formKey.currentState!.validate()) {
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
          key: _formKey,
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