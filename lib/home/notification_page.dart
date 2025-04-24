import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';

import 'notification_detail_page.dart';

class NotificationModel {
  final String heading;
  final String content;
  final String imageUrl;

  NotificationModel({
    required this.heading,
    required this.content,
    required this.imageUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      heading: json['headings']?['en'] ?? 'No Title',
      content: json['contents']?['en'] ?? 'No Content',
      imageUrl: json['global_image'] ?? '',
    );
  }
}

class NotificationController {
  Future<List<NotificationModel>> fetchNotifications() async {
    await dotenv.load(fileName: ".env");
    String? appId = dotenv.env['ONESIGNAL_APP_ID'];
    String? apiKey = dotenv.env['ONESIGNAL_API_KEY'];

    if (appId != null) {
      var url = Uri.parse('https://onesignal.com/api/v1/notifications?app_id=$appId');

      var response = await http.get(
        url,
        headers: {'Authorization': 'Basic $apiKey'},
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (kDebugMode) {
          print(data);
        }
        List<dynamic> notificationsJson = data['notifications'];

        return notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } else {
      throw Exception('ONESIGNAL_APP_ID not found in .env');
    }
  }
}

class NotificationViewPage extends StatefulWidget {
  final String title;

  NotificationViewPage({required this.title});

  @override
  _NotificationViewPageState createState() => _NotificationViewPageState();
}

class _NotificationViewPageState extends State<NotificationViewPage> {
  late Future<List<NotificationModel>> notificationsFuture;

  @override
  void initState() {
    super.initState();
    notificationsFuture = NotificationController().fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          } else {
            return _buildNotificationList(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Lottie.asset(
        'assets/animation/loader.json',
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Text(
        'Error loading notifications. Please try again later.',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text('No notifications available.'),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          var notification = notifications[index];
          return _buildNotificationTile(notification);
        },
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailPage(notification: notification),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage('assets/ui/card_back.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Card Content
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    notification.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                // Notification Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          notification.heading,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          notification.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}