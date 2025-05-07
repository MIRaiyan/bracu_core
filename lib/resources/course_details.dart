import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SeePage extends StatelessWidget {
  final Map<String, dynamic> course;
  const SeePage({Key? key, required this.course}) : super(key: key);

  // Launch URL in external app or browser
  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    print('Attempting to launch: $url');
    print('Parsed URI: $uri');
    try {
      // Check if the URL can be launched
      if (!await canLaunchUrl(uri)) {
        print('Cannot launch $url: URL scheme not supported');
        // Fallback: Try opening in browser
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          print('Opened $url in browser');
        } else {
          print('Cannot open $url in browser either');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open $url: No app or browser available'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Attempt to open in external app
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      print('Successfully launched $url in external app');
    } catch (e) {
      print('Error launching $url: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening $url: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course['courseCode'].toString().toUpperCase()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Code: ${course['courseCode'].toString().toUpperCase()}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'YouTube Playlists:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if ((course['youtubePlaylists'] as List<dynamic>?)?.isEmpty ?? true)
              const Text('No YouTube playlists available'),
            ...(course['youtubePlaylists'] as List<dynamic>? ?? []).map<Widget>((link) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: GestureDetector(
                onTap: () {
                  print('Tapped YouTube link: $link');
                  _launchUrl(context, link.toString());
                },
                child: Text(
                  link.toString(),
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            )),
            const SizedBox(height: 16),
            const Text(
              'Drive Folder Links:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if ((course['driveFolderLinks'] as List<dynamic>?)?.isEmpty ?? true)
              const Text('No Drive folders available'),
            ...(course['driveFolderLinks'] as List<dynamic>? ?? []).map<Widget>((link) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: GestureDetector(
                onTap: () {
                  print('Tapped Drive link: $link');
                  _launchUrl(context, link.toString());
                },
                child: Text(
                  link.toString(),
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}