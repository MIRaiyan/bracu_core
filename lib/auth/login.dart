import 'dart:convert';
import 'package:bracu_core/auth/signup.dart';
import 'package:bracu_core/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_root.dart';
import '../service/pofile_provider.dart';
import '../widgets/custom_input_field.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final _formKey = GlobalKey<FormState>();
  bool passEnable = true;
  bool isPasswordcorrect = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> handle_login(String email, String password) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen())); // for test

    const String uri = "${api_root}/login.php";
    final body = {
      'email': email,
      'password': password,
    };
    final response = await http.post(
      Uri.parse(uri),
      body: body,
    );

    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['success'] == 'true') {
        final user = jsonResponse['user'];
        final String firstName = user['fname'];
        final String lastName = user['lname'];
        final String userEmail = user['email'];

        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        Fluttertoast.showToast(msg: "welcome $firstName");

        LogInStatus("None");

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        Fluttertoast.showToast(msg: "${jsonResponse['message']}");
        print('Error: ${jsonResponse['message']}');
      }
    } else {
      Fluttertoast.showToast(msg: "Error failed to login");
      print('Failed to login. Status code: ${response.statusCode}');
    }
  }

  Future<void> LogInStatus(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
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

        child: SingleChildScrollView(
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
                    "Login!",
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
                          controller: _emailController,
                          hintText: "Email",
                          icon: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return "Please enter a valid email";
                            }
                            return null;
                          },
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
                        Container(
                          margin: const EdgeInsets.only(right: 0),
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Fluttertoast.showToast(
                                  msg: 'Not Applicable right now',
                                  gravity: ToastGravity.TOP);
                            },
                            child: const Text(
                              'Forgot password',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
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
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    handle_login(_emailController.text, _passwordController.text);
                                  }
                                },
                                child: const Text(
                                  "Log In",
                                  style: TextStyle(fontSize: 18, letterSpacing: .4, color: Color(0xFFD45858)),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        _buildButton(),


                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return TextButton(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Registration()));
        },
        child: Text(
          "Register ?",
            style: TextStyle(
                color: Colors.white,
              letterSpacing:  1.5,
              fontSize: 18,
            ),
        )
    );
  }
}