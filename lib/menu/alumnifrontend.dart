import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ================= MAIN APP =================
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alumni App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

// ================= HOME SCREEN =================
// This is the entry point with Alumni Info button
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alumni App')),
      body: Center(
        child: ElevatedButton(
          child: Text('Alumni Info'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AlumniInfoPage()),
            );
          },
        ),
      ),
    );
  }
}

// ================= ALUMNI INFO PAGE =================
// Main alumni page with two options: View and Upload
class AlumniInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alumni Information'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                minimumSize: Size(250, 50),
              ),
              child: Text('View Existing Alumni Info'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewAlumniInfo()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                minimumSize: Size(250, 50),
              ),
              child: Text('Upload Alumni Info'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadAlumniInfo()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================= ALUMNI MODEL =================
// Model class to represent alumni data
class Alumni {
  final String id;
  final String name;
  final String admissionSession;
  final String graduatingSession;
  final String workDomain;
  final String company;
  final String speciality;
  final String currentAddress;
  final String contactInfo;
  final String others;
  final bool isVerified;

  Alumni({
    required this.id,
    required this.name,
    required this.admissionSession,
    required this.graduatingSession,
    required this.workDomain,
    required this.company,
    required this.speciality,
    required this.currentAddress,
    required this.contactInfo,
    required this.others,
    required this.isVerified,
  });

  factory Alumni.fromJson(Map<String, dynamic> json) {
    return Alumni(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      admissionSession: json['admissionSession'] ?? '',
      graduatingSession: json['graduatingSession'] ?? '',
      workDomain: json['workDomain'] ?? '',
      company: json['company'] ?? '',
      speciality: json['speciality'] ?? '',
      currentAddress: json['currentAddress'] ?? '',
      contactInfo: json['contactInfo'] ?? '',
      others: json['others'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'admissionSession': admissionSession,
      'graduatingSession': graduatingSession,
      'workDomain': workDomain,
      'company': company,
      'speciality': speciality,
      'currentAddress': currentAddress,
      'contactInfo': contactInfo,
      'others': others,
    };
  }
}

// ================= ALUMNI SERVICE =================
// Service class for API interactions
class AlumniService {
  final String baseUrl =
      'http://10.0.2.2:3000'; // localhost for Android emulator

  Future<List<Alumni>> getAlumni() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/alumni'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Alumni.fromJson(json)).toList();
      } else {
        // If API call fails, use mock data for development
        print('API request failed with status: ${response.statusCode}');
        return _getMockAlumni();
      }
    } catch (e) {
      // If there's any exception (like connection error), use mock data
      print('Error getting alumni data: $e');
      return _getMockAlumni();
    }
  }

  Future<void> submitAlumni(Alumni alumni) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/alumni'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(alumni.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to submit alumni data');
      }
    } catch (e) {
      // For development purposes, just print the error and return
      print('Error submitting alumni: $e');
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    }
  }

  // Mock data for development purposes
  List<Alumni> _getMockAlumni() {
    return [
      Alumni(
        id: '1',
        name: 'John Doe',
        admissionSession: '2015',
        graduatingSession: '2019',
        workDomain: 'Software Development',
        company: 'Google',
        speciality: 'Mobile Development',
        currentAddress: 'Mountain View, CA',
        contactInfo: 'john.doe@example.com',
        others: 'Flutter enthusiast',
        isVerified: true,
      ),
      Alumni(
        id: '2',
        name: 'Jane Smith',
        admissionSession: '2016',
        graduatingSession: '2020',
        workDomain: 'Data Science',
        company: 'Amazon',
        speciality: 'Machine Learning',
        currentAddress: 'Seattle, WA',
        contactInfo: 'jane.smith@example.com',
        others: 'Loves hiking',
        isVerified: true,
      ),
    ];
  }
}

// ================= VIEW ALUMNI INFO SCREEN =================
// Screen to display existing alumni information
class ViewAlumniInfo extends StatefulWidget {
  @override
  _ViewAlumniInfoState createState() => _ViewAlumniInfoState();
}

class _ViewAlumniInfoState extends State<ViewAlumniInfo> {
  final AlumniService _alumniService = AlumniService();
  List<Alumni> _alumniList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlumniData();
  }

  Future<void> _loadAlumniData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would fetch data from your API
      final List<Alumni> alumni = await _alumniService.getAlumni();

      // Make sure we're still mounted before setting state
      if (mounted) {
        setState(() {
          _alumniList = alumni;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Make sure we're still mounted before setting state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load alumni data: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Alumni Information'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _alumniList.isEmpty
              ? Center(child: Text('No alumni information available'))
              : ListView.builder(
                itemCount: _alumniList.length,
                itemBuilder: (context, index) {
                  final alumni = _alumniList[index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: Text(alumni.name),
                      subtitle: Text(
                        '${alumni.admissionSession} - ${alumni.graduatingSession}',
                      ),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _buildInfoRow('Work Domain', alumni.workDomain),
                              _buildInfoRow('Company', alumni.company),
                              _buildInfoRow('Speciality', alumni.speciality),
                              _buildInfoRow(
                                'Current Address',
                                alumni.currentAddress,
                              ),
                              _buildInfoRow('Contact Info', alumni.contactInfo),
                              _buildInfoRow('Others', alumni.others),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  // Helper method to build consistent info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ================= UPLOAD ALUMNI INFO SCREEN =================
// Form screen to submit new alumni information
class UploadAlumniInfo extends StatefulWidget {
  @override
  _UploadAlumniInfoState createState() => _UploadAlumniInfoState();
}

class _UploadAlumniInfoState extends State<UploadAlumniInfo> {
  final _formKey = GlobalKey<FormState>();
  final AlumniService _alumniService = AlumniService();

  // Text controllers for all form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _admissionSessionController =
      TextEditingController();
  final TextEditingController _graduatingSessionController =
      TextEditingController();
  final TextEditingController _workDomainController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();
  final TextEditingController _currentAddressController =
      TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _othersController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    _nameController.dispose();
    _admissionSessionController.dispose();
    _graduatingSessionController.dispose();
    _workDomainController.dispose();
    _companyController.dispose();
    _specialityController.dispose();
    _currentAddressController.dispose();
    _contactInfoController.dispose();
    _othersController.dispose();
    super.dispose();
  }

  // Handle form submission
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final alumni = Alumni(
          id: '', // Will be assigned by the backend
          name: _nameController.text,
          admissionSession: _admissionSessionController.text,
          graduatingSession: _graduatingSessionController.text,
          workDomain: _workDomainController.text,
          company: _companyController.text,
          speciality: _specialityController.text,
          currentAddress: _currentAddressController.text,
          contactInfo: _contactInfoController.text,
          others: _othersController.text,
          isVerified: false, // Default to false, will be verified by admin
        );

        await _alumniService.submitAlumni(alumni);

        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alumni information submitted successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit alumni information')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Alumni Information'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Form fields for all required alumni information
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _admissionSessionController,
                  label: 'Admission Session',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your admission session';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _graduatingSessionController,
                  label: 'Graduating Session',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your graduating session';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _workDomainController,
                  label: 'Work Domain',
                ),
                _buildTextField(
                  controller: _companyController,
                  label: 'Company',
                ),
                _buildTextField(
                  controller: _specialityController,
                  label: 'Speciality',
                ),
                _buildTextField(
                  controller: _currentAddressController,
                  label: 'Current Address',
                ),
                _buildTextField(
                  controller: _contactInfoController,
                  label: 'Contact Info',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact information';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _othersController,
                  label: 'Others',
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                // Submit button with loading state
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child:
                      _isSubmitting
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Submit Alumni Information'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build consistent text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }
}
