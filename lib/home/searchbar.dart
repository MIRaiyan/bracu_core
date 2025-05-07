import 'package:flutter/material.dart';
import '../api/api_root.dart';
import 'package:provider/provider.dart';

class Search_bar extends StatefulWidget {
  @override
  _Search_barState createState() => _Search_barState();
}

class _Search_barState extends State<Search_bar> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Future<void>.delayed(Duration.zero, () {
    //   final allCourseProvider = Provider.of<AllCourseProvider>(context, listen: false);
    //   allCourseProvider.fetchAllCourses();
    //   //this is for opening keyboard ...................
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     FocusScope.of(context).requestFocus(_focusNode);
    //   });
    // });
  }


  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final allCourseProvider = Provider.of<AllCourseProvider>(context);
    // List<AllCourse> filteredCourses = allCourseProvider.resources
    //     .where((course) =>
    // course.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
    //     course.instructorName
    //         .toLowerCase()
    //         .contains(searchQuery.toLowerCase()) ||
    //     course.categoryTitle
    //         .toLowerCase()
    //         .contains(searchQuery.toLowerCase()))
    //     .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Search Courses'),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 20,),

            TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6), fontStyle: FontStyle.normal, letterSpacing: 1),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.orange),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),

            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.only(left: 24),
              child: Text("Results : ",),
            ),
          ],
        ),
      ),
    );
  }
}
