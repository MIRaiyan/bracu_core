import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../service/pofile_provider.dart';
import 'package:animations/animations.dart';
import 'searchbar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  bool isExpanded = false;

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
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
            padding: EdgeInsets.all(16.0),
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
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi !', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
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
                        width: 50,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.search, color: Colors.black),
                      ),
                      openBuilder: (ctx, action) => Search_bar(),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.notifications, color: Colors.black),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(),
            _buildCourseSchedule(profileProvider),
            _buildOtherFeatures(),
            _buildTrendingCourses(),
          ],
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

    // Filter courses based on the selected day
    List visibleCourses = ongoingCourses.where((course) {
      List<String> days = List<String>.from(course["days"] ?? []);
      String selectedDay = DateFormat('EEEE').format(selectedDate);
      return days.contains(selectedDay);
    }).toList();

    if (visibleCourses.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No classes today', style: TextStyle(fontSize: 16))),
      );
    }

    List displayedCourses = isExpanded ? visibleCourses : visibleCourses.take(2).toList();

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...displayedCourses.map((course) {
            return _courseTile(course["courseCode"] ?? '', course["room"] ?? '', course["time"] ?? '', course["faculty"] ?? '', course["section"] ?? '');
          }).toList(),
          if (visibleCourses.length > 1)
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
      padding: EdgeInsets.all(16),
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

  Widget _buildTrendingCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Trending Courses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Container(
          color: Colors.white10,
          height: 200,
          width: double.infinity,
          child: Center(child: Text("Course placeholder")),
        )
      ],
    );
  }
}
