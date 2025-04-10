import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:bracu_core/home/notificationPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_root.dart';
import '../service/profile_provider.dart';
import 'searchbar.dart';
import 'package:animations/animations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  DateTime selectedDate = DateTime.now();
  bool isExpanded = false;
  bool isRefreshing = false;
  String location = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    Location locationService = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationService.requestService();
      if (!serviceEnabled) {
        setState(() {
          location = 'Location services are disabled.';
        });
        return;
      }
    }

    permissionGranted = await locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          location = 'Location permissions are denied';
        });
        return;
      }
    }

    LocationData locationData = await locationService.getLocation();
    setState(() {
      location = '${locationData.latitude}, ${locationData.longitude}';
    });
  }

  Future<void> _refresh() async {
    setState(() {
      isRefreshing = true;
    });
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final authToken = await profileProvider.loadAuthToken();

      final response = await http.get(
        Uri.parse('${api_root}/api/user/profile'),
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print(response.body);
        print(response.statusCode);
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await profileProvider.saveProfileData(data);
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      debugPrint('Error refreshing profile data: $e');
    } finally {
      setState(() {
        isRefreshing = false;
      });
    }
  }

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
  }

  Future<void> LaunchUrl(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 100.0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        profileProvider.profilePicture?.isNotEmpty == true
                            ? profileProvider.profilePicture!
                            : 'https://decisionsystemsgroup.github.io/workshop-html/img/john-doe.jpg',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hi !', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                        Text('${profileProvider.firstName ?? ''} ${profileProvider.lastName ?? ''}', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    OpenContainer(
                      closedColor: Colors.white,
                      closedElevation: 0,
                      transitionDuration: const Duration(milliseconds: 500),
                      closedBuilder: (ctx, action) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Lottie.asset(
                          'assets/animation/search.json',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          repeat: true,
                        ),
                      ),
                      openBuilder: (ctx, action) => Search_bar(),
                    ),
                    const SizedBox(width: 10),
                    OpenContainer(
                      closedColor: Colors.white,
                      closedElevation: 0,
                      transitionDuration: const Duration(milliseconds: 500),
                      closedBuilder: (ctx, action) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Lottie.asset(
                          'assets/animation/notification3.json',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          repeat: false,
                        ),
                      ),
                      openBuilder: (ctx, action) => const Notificationpage(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(),
              _buildCourseSchedule(profileProvider),
              _buildOtherFeatures(),
              //_buildTrendingCourses(),
              _buildLocationDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => _changeDate(-1),
        ),
        Text(DateFormat('EEEE, MMM d').format(selectedDate), style: TextStyle(fontSize: 16)),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios),
          onPressed: () => _changeDate(1),
        ),
      ],
    );
  }

  Widget _buildCourseSchedule(ProfileProvider profileProvider) {
    List ongoingCourses = profileProvider.ongoingCourses;

    List visibleCourses = ongoingCourses.where((course) {
      List<String> days = List<String>.from(course["days"] ?? []);
      String selectedDay = DateFormat('EEEE').format(selectedDate);
      return days.contains(selectedDay);
    }).toList();

    if (visibleCourses.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animation/ghost.json',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  repeat: true,
                ),
                const Text("No Classes Today"),
              ],
            ),
        ),
      );
    }

    List displayedCourses = isExpanded ? visibleCourses : visibleCourses.take(2).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...displayedCourses.map((course) {
            return _courseTile(course["courseCode"] ?? '', course["room"] ?? '', course["time"] ?? '', course["faculty"] ?? '', course["section"] ?? '');
          }).toList(),
          if (visibleCourses.length >= 1)
            TextButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Center(
                child: Text(
                  isExpanded ? 'Show Less' : 'Show More',
                  style: TextStyle(color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _courseTile(String course, String room, String time, String faculty, String section) {
    List<String> timeParts = time.split('-');
    String hours = timeParts.length > 0 ? timeParts[0] : '';
    String minutes = timeParts.length > 1 ? timeParts[1] : '';

    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hours,
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
                Text(
                  minutes,
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),

        Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: 1,
          height: 100,
          color: Colors.grey,
        ),

        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      course,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "[${faculty}]",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "section: ",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      section,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[600],
                      ),
                    ),

                    SizedBox(width: 10),

                    Text(
                      "Class: ",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      room,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherFeatures() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Other features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Container(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _featureCard('CGPA Calculator', Colors.red),
                SizedBox(width: 10),
                _featureCard('AI Assistant', Colors.green),
                SizedBox(width: 10),
                _featureCard('Thesis group finder', Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(String title, Color color) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calculate, color: Colors.white, size: 30),
          SizedBox(height: 5),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildLocationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16),
          child: Text('Location & Safety', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Container(
          margin: EdgeInsets.all(16.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage('assets/ui/map.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Your Location: $location",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  GestureDetector(
                    child: Lottie.asset(
                      'assets/animation/maps.json',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      repeat: false,
                    ),
                    onTap: () async {
                      final locationData = location.split(':').last.trim();
                      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$locationData');
                      LaunchUrl(url);
                    },
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Soon to be implemented'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.teal, // Text color
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        elevation: 5, // Elevation
                      ),
                      child: Text(
                        '⚠️ Send SOS',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}