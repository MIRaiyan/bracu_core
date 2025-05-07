import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:lottie/lottie.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  List<Map<String, String>> articles = [];
  String? selectedTitle;
  String? selectedUrl;
  String pageContent = 'Loading...';
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final url = Uri.parse('https://cse.sds.bracu.ac.bd/course/list');
      final response = await http.get(url);
      dom.Document html = dom.Document.html(response.body);

      final courseElements = html.querySelectorAll('div > a').where((element) {
        return element.querySelector('p.text-lg') != null;
      }).toList();

      setState(() {
        articles = courseElements.map((element) {
          final title = element.querySelector('p.text-lg')!.innerHtml.trim();
          final href = element.attributes['href'] ?? '';
          final url = href.startsWith('http') ? href : 'https://cse.sds.bracu.ac.bd/$href';
          return {'title': title, 'url': url};
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Future<void> fetchCourseDetails(String url) async {
    setState(() {
      pageContent = 'Loading...';
    });
    try {
      final response = await http.get(Uri.parse(url));
      final document = dom.Document.html(response.body);

      final contentElement = document.querySelector(
        'div.p-4.bg-white.border.rounded-md.md\\:col-span-2.lg\\:col-span-3.xl\\:col-span-4.border-slate-300.md\\:p-4.lg\\:p-6',
      );

      setState(() {
        pageContent = contentElement?.text.trim() ?? 'Content not found';
      });
    } catch (e) {
      setState(() {
        pageContent = 'Failed to load content';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(selectedTitle == null ? 'Select Course' : selectedTitle!),
        centerTitle: true,
        leading: selectedTitle == null
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedTitle = null;
              selectedUrl = null;
            });
          },
        ),
      ),
      body: isLoading
          ? Center(child: Lottie.asset('assets/animation/loader.json'),
      )
          : isError
          ? buildErrorState()
          : selectedTitle == null
          ? buildCourseList()
          : buildCourseDetails(),
    );
  }

  Widget buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          const Text(
            'Failed to load resources. Please try again.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchCourses,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget buildCourseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTitle = article['title'];
              selectedUrl = article['url'];
              fetchCourseDetails(selectedUrl!);
            });
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article['url']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildCourseDetails() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Details:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pageContent,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}