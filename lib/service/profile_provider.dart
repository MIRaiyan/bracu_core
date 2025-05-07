import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile/profile.dart';
import '../profile/update_profile.dart';

class ProfileProvider with ChangeNotifier {
  String _firstName = '';
  String _lastName = '';
  String _gsuite = '';
  String _phoneNumber = '';
  String _studentId = '';
  String _department = '';
  String _gender = '';
  String _password = '';
  String _admissionYear = '';
  String _profilePicture = '';
  String _bio = '';
  String _currentAddress = '';
  String _permanentAddress = '';
  String _bloodGroup = '';
  Map<String, String> _emergencyContact = {};
  double _cgpa = 0.0;
  int _completedCredits = 0;
  int _totalCredits = 0;
  String _role = '';
  bool _accountVerified = false;
  Map<String, String> _studentIdImages = {};
  List<String> _clubMemberships = [];
  List<Map<String, dynamic>> _ongoingCourses = [];
  List<String> _registeredDevices = [];
  String _lastLogin = '';
  String _authToken = '';

  bool _isLoggedIn = false;

  // Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get gsuite => _gsuite;
  String get phoneNumber => _phoneNumber;
  String get studentId => _studentId;
  String get department => _department;
  String get gender => _gender;
  String get password => _password;
  String get admissionYear => _admissionYear;
  String get profilePicture => _profilePicture;
  String get bio => _bio;
  String get currentAddress => _currentAddress;
  String get permanentAddress => _permanentAddress;
  String get bloodGroup => _bloodGroup;
  Map<String, String> get emergencyContact => _emergencyContact;
  double get cgpa => _cgpa;
  int get completedCredits => _completedCredits;
  int get totalCredits => _totalCredits;
  String get role => _role;
  bool get accountVerified => _accountVerified;
  Map<String, String> get studentIdImages => _studentIdImages;
  List<String> get clubMemberships => _clubMemberships;
  List<Map<String, dynamic>> get ongoingCourses => _ongoingCourses;
  List<String> get registeredDevices => _registeredDevices;
  String get lastLogin => _lastLogin;
  String get authToken => _authToken;

  String get emergencyName => _emergencyContact['name'] ?? '';
  String get emergencyRelation => _emergencyContact['relation'] ?? '';
  String get emergencyPhoneNumber => _emergencyContact['phoneNumber'] ?? '';


  bool get isLoggedIn => _isLoggedIn;

  // Constructor to initialize and load profile
  ProfileProvider() {
    _loadProfile();
  }

  /// Load profile data from SharedPreferences
  Future<void> _loadProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? profileData = prefs.getString('profile_data');

      // If profile data exists, load it
      if (profileData != null) {
        final Map<String, dynamic> data = jsonDecode(profileData);

        _firstName = data['firstName'] ?? '';
        _lastName = data['lastName'] ?? '';
        _gsuite = data['gsuite'] ?? '';
        _phoneNumber = data['phoneNumber'] ?? '';
        _studentId = data['studentId'] ?? '';
        _department = data['department'] ?? '';
        _gender = data['gender'] ?? '';
        _password = data['password'] ?? '';
        _admissionYear = data['admission_year'] ?? '';
        _profilePicture = data['profilePicture'] ?? '';
        _bio = data['bio'] ?? '';
        _currentAddress = data['currentAddress'] ?? '';
        _permanentAddress = data['permanentAddress'] ?? '';
        _bloodGroup = data['bloodGroup'] ?? '';
        _emergencyContact = Map<String, String>.from(data['emergencyContact'] ?? {});
        _cgpa = data['cgpa'] ?? 0.0;
        _completedCredits = data['completedCredits'] ?? 0;
        _totalCredits = data['totalCredits'] ?? 0;
        _role = data['role'] ?? '';
        _accountVerified = data['accountVerified'] ?? false;
        _studentIdImages = Map<String, String>.from(data['studentIdImages'] ?? {});
        _clubMemberships = List<String>.from(data['clubMemberships'] ?? []);
        _ongoingCourses = List<Map<String, dynamic>>.from(data['ongoingCourses'] ?? []);
        _registeredDevices = List<String>.from(data['registeredDevices'] ?? []);
        _lastLogin = data['lastLogin'] ?? '';
        _authToken = prefs.getString('token') ?? '';

        // Load login status
        _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  /// Save profile data to SharedPreferences
  Future<void> saveProfileData(Map<String, dynamic> profileData) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Save profile data as a JSON string
      await prefs.setString('profile_data', jsonEncode(profileData));

      // Save the individual values locally
      _firstName = profileData['firstName'] ?? '';
      _lastName = profileData['lastName'] ?? '';
      _gsuite = profileData['gsuite'] ?? '';
      _phoneNumber = profileData['phoneNumber'] ?? '';
      _studentId = profileData['studentId'] ?? '';
      _department = profileData['department'] ?? '';
      _gender = profileData['gender'] ?? '';
      _password = profileData['password'] ?? '';
      _admissionYear = profileData['admission_year'] ?? '';
      _profilePicture = profileData['profilePicture'] ?? '';
      _bio = profileData['bio'] ?? '';
      _currentAddress = profileData['currentAddress'] ?? '';
      _permanentAddress = profileData['permanentAddress'] ?? '';
      _bloodGroup = profileData['bloodGroup'] ?? '';
      _emergencyContact = Map<String, String>.from(profileData['emergencyContact'] ?? {});
      _cgpa = profileData['cgpa'] ?? 0.0;
      _completedCredits = profileData['completedCredits'] ?? 0;
      _totalCredits = profileData['totalCredits'] ?? 0;
      _role = profileData['role'] ?? '';
      _accountVerified = profileData['accountVerified'] ?? false;
      _studentIdImages = Map<String, String>.from(profileData['studentIdImages'] ?? {});
      _clubMemberships = List<String>.from(profileData['clubMemberships'] ?? []);
      _ongoingCourses = List<Map<String, dynamic>>.from(profileData['ongoingCourses'] ?? []);
      _registeredDevices = List<String>.from(profileData['registeredDevices'] ?? []);
      _lastLogin = profileData['lastLogin'] ?? '';

      notifyListeners();
    } catch (e) {
      debugPrint('Error saving profile data: $e');
    }
  }

  /// Save login status
  Future<void> updateLoginStatus(bool status) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _isLoggedIn = status;
      await prefs.setBool('isLoggedIn', status);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating login status: $e');
    }
  }

  /// Save auth token
  Future<void> saveAuthToken(String token) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _authToken = token;
      await prefs.setString('token', token);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving auth token: $e');
    }
  }

  /// Load auth token from SharedPreferences and return it
  Future<String> loadAuthToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('token') ?? '';
      notifyListeners();
      return _authToken;
    } catch (e) {
      if(kDebugMode) {
        debugPrint('Error loading auth token: $e');
      }
      return '';
    }
  }

  /// Clear profile and authentication data
  Future<void> clearProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.remove('profile_data');
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('isLoggedIn');
      await prefs.remove('token');

      _firstName = '';
      _lastName = '';
      _gsuite = '';
      _phoneNumber = '';
      _studentId = '';
      _department = '';
      _gender = '';
      _password = '';
      _admissionYear = '';
      _profilePicture = '';
      _bio = '';
      _currentAddress = '';
      _permanentAddress = '';
      _bloodGroup = '';
      _emergencyContact = {};
      _cgpa = 0.0;
      _completedCredits = 0;
      _totalCredits = 0;
      _role = '';
      _accountVerified = false;
      _studentIdImages = {};
      _clubMemberships = [];
      _ongoingCourses = [];
      _registeredDevices = [];
      _lastLogin = '';
      _authToken = '';

      _isLoggedIn = false;

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing profile: $e');
    }
  }

  /// Update user profile picture
  Future<void> updateProfilePicture(String? url) async {
    try {
      _profilePicture = url!;
      notifyListeners();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? profileData = prefs.getString('profile_data');

      if (profileData != null) {
        final Map<String, dynamic> data = jsonDecode(profileData);
        data['profilePicture'] = url;
        await prefs.setString('profile_data', jsonEncode(data));
      }
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
    }
  }

  /// Update user address
  Future<void> updateAddress(String? newAddress) async {
    try {
      _currentAddress = newAddress!;
      notifyListeners();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? profileData = prefs.getString('profile_data');

      if (profileData != null) {
        final Map<String, dynamic> data = jsonDecode(profileData);
        data['currentAddress'] = newAddress;
        await prefs.setString('profile_data', jsonEncode(data));
      }
    } catch (e) {
      debugPrint('Error updating address: $e');
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await loadAuthToken(); // your stored JWT
      final url = Uri.parse('https://bracu-core-backend.vercel.app/api/user/update_password'); // adjust endpoint

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to update password: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error in updatePassword: $e');
      return false;
    }
  }



  Future<bool> updateProfile({
    required String studentId,
    required String phoneNumber,
    required String department,
    required String permanentAddress,
    required String currentAddress,
    required Map<String, String> emergencyContact,
  }) async {
    try {
      // Prepare API URL and token
      final url = Uri.parse('https://bracu-core-backend.vercel.app/api/user/update'); //endpoint
      final prefs = await SharedPreferences.getInstance();
      final token = await loadAuthToken(); // JWT token

      if (token == null) {
        throw Exception("JWT token not found");
      }

      // Send PUT request to backend
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({
          'studentId': studentId,
          'phoneNumber': phoneNumber,
          'department': department,
          'permanentAddress': permanentAddress,
          'currentAddress': currentAddress,
          'emergencyContact': emergencyContact,
        }),
      );

      if (response.statusCode == 200) {
        // Update local variables only if backend call is successful
        _studentId = studentId;
        _phoneNumber = phoneNumber;
        _department = department;
        _permanentAddress = permanentAddress;
        _currentAddress = currentAddress;
        _emergencyContact = emergencyContact;

        // Update SharedPreferences
        final String? profileData = prefs.getString('profile_data');
        Map<String, dynamic> data = profileData != null ? jsonDecode(profileData) : {};

        data['studentId'] = studentId;
        data['phoneNumber'] = phoneNumber;
        data['department'] = department;
        data['permanentAddress'] = permanentAddress;
        data['currentAddress'] = currentAddress;
        data['emergencyContact'] = emergencyContact;

        await prefs.setString('profile_data', jsonEncode(data));

        notifyListeners();
        return true;
      } else {
        debugPrint('Backend error: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }
}