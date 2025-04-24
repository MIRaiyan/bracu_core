import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class FacultyReviewPage extends StatefulWidget {
  const FacultyReviewPage({Key? key}) : super(key: key);

  @override
  _FacultyReviewPageState createState() => _FacultyReviewPageState();
}

class _FacultyReviewPageState extends State<FacultyReviewPage> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _reviewController = TextEditingController();
  double _rating = 0;
  List<Map<String, String>> reviews = [];
  List<Map<String, dynamic>> facultyList = [
    {'name': 'ab', 'department': 'Computer Science', 'courses': ['CSE101', 'CSE102']},
    {'name': 'abc', 'department': 'Mathematics', 'courses': ['MAT101', 'MAT102']},
    {'name': 'abcd', 'department': 'Physics', 'courses': ['PHY101', 'PHY102']},
  ];

  String selectedFaculty = '';
  bool isFacultyFound = false;
  String selectedCourse = '';
  DateTime currentDate = DateTime.now();
  String reviewerName = 'Anonymous';

  void _submitReview() {
    if (_rating > 0 && _reviewController.text.isNotEmpty && selectedCourse.isNotEmpty) {
      setState(() {
        reviews.add({
          'faculty': selectedFaculty,
          'review': _reviewController.text,
          'rating': _rating.toString(),
          'date': DateFormat('yyyy-MM-dd').format(currentDate),
          'reviewer': reviewerName,
          'course': selectedCourse,
        });
      });
      _reviewController.clear();
    }
  }

  Color _getColorForRating(double rating) {
    if (rating <= 2) {
      return Colors.red.shade300;  // Low rating -> Red
    } else if (rating == 3) {
      return Colors.yellow.shade300;  // Neutral rating -> Yellow
    } else {
      return Colors.green.shade300;  // High rating -> Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faculty Review Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Faculty',
                hintText: 'Enter faculty name',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      selectedFaculty = _searchController.text;
                      isFacultyFound = facultyList.any((faculty) =>
                      faculty['name'] == selectedFaculty);
                      // Reset the selected course when a new faculty is searched
                      selectedCourse = '';
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            // Faculty Details and Course Selection
            if (isFacultyFound)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Faculty: $selectedFaculty',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Department: ${facultyList.firstWhere((faculty) => faculty['name'] == selectedFaculty)['department']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  // Course Dropdown
                  DropdownButton<String>(
                    hint: Text('Select a Course'),
                    value: selectedCourse.isNotEmpty ? selectedCourse : null,
                    onChanged: (newCourse) {
                      setState(() {
                        selectedCourse = newCourse!;
                      });
                    },
                    items: (facultyList
                        .firstWhere((faculty) => faculty['name'] == selectedFaculty)['courses'] as List<String>?)
                        ?.map<DropdownMenuItem<String>>((String course) {
                      return DropdownMenuItem<String>(
                        value: course,
                        child: Text(course),
                      );
                    }).toList() ?? [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('No courses available'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Rate this Faculty:', style: TextStyle(fontSize: 16)),
                  Slider(
                    value: _rating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _rating.toString(),
                    onChanged: (newRating) {
                      setState(() {
                        _rating = newRating;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Write your review',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submitReview,
                    child: Text('Submit Review'),
                  ),
                ],
              ),
            if (!isFacultyFound && selectedFaculty.isNotEmpty)
              Text(
                'Faculty not found!',
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20),

            // Display All Reviews in Colored Boxes (Scrollable)
            Expanded(
              child: reviews.isNotEmpty
                  ? ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  // Ensure that we only display reviews for the selected faculty
                  if (reviews[index]['faculty'] == selectedFaculty) {
                    double rating = double.parse(reviews[index]['rating'] ?? '0');
                    return Card(
                      color: _getColorForRating(rating),  // Set color based on rating
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(reviews[index]['review'] ?? ''),
                        subtitle: Text(
                            'Rating: ${reviews[index]['rating']} by ${reviews[index]['reviewer']} on ${reviews[index]['date']}'),
                      ),
                    );
                  } else {
                    return Container();  // If the review doesn't match the selected faculty, skip it
                  }
                },
              )
                  : Center(child: Text('No reviews available for this faculty.')),
            ),
          ],
        ),
      ),
    );
  }
}
