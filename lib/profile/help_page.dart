import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  final String facebookUrl = 'https://www.facebook.com/Onnesok.94';

  Future<void> urllauncher(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildContactCard(String label, String number) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        leading: Icon(Icons.phone, color: Colors.teal, size: 28),
        title: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          number,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        onTap: () async {
          final Uri phoneUri = Uri(scheme: 'tel', path: number);
          await urllauncher(phoneUri);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Help',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/ui/help.png',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Emergency Contact Numbers
            Text(
              'Emergency Contacts',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildContactCard('Police', '999'),
            _buildContactCard('Fire Service', '199'),
            _buildContactCard('Ambulance', '112'),
            SizedBox(height: 30),
            // Facebook Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri uri = Uri.parse(facebookUrl);
                  await urllauncher(uri);
                },
                icon: Icon(Icons.facebook, color: Colors.white),
                label: Text('Facebook'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}