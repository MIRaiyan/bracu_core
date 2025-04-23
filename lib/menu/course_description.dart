import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;



class course_page extends StatefulWidget {
  const course_page({super.key});

  @override
  State<course_page> createState() => _MyAppState();
}

class Article {
  final String url;
  final String title;

  const Article({required this.title, required this.url});
}

class _MyAppState extends State<course_page> {
  List<Article> articles = [];

  @override
  void initState() {
    super.initState();
    getWebsiteData();
  }

  Future getWebsiteData() async {
    final url = Uri.parse('https://cse.sds.bracu.ac.bd/course/list');
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    final courseElements =
        html.querySelectorAll('div > a').where((element) {
          return element.querySelector('p.text-lg') != null;
        }).toList();

    final titles =
        courseElements
            .map(
              (element) => element.querySelector('p.text-lg')!.innerHtml.trim(),
            )
            .toList();

    final urls =
        courseElements.map((element) {
          final href = element.attributes['href'] ?? '';
          if (href.startsWith('http')) {
            return href; // already full URL
          } else {
            return 'https://cse.sds.bracu.ac.bd/$href'; // relative path
          }
        }).toList();

    setState(() {
      articles = List.generate(
        titles.length,
        (index) => Article(title: titles[index], url: urls[index]),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course List',
      home: Scaffold(
        appBar: AppBar(title: const Text('Select Course'), centerTitle: true),
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => CourseDetailPage(
                          title: article.title,
                          url: article.url,
                        ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.url,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CourseDetailPage extends StatefulWidget {
  final String title;
  final String url;

  const CourseDetailPage({super.key, required this.title, required this.url});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  String pageContent = 'Loading...';

  @override
  void initState() {
    super.initState();
    loadContent();
  }

  Future<void> loadContent() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      final document = dom.Document.html(response.body);

      // Use the long CSS selector to fetch only the course content section
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
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(child: Text(pageContent)),
      ),
    );
  }
}
