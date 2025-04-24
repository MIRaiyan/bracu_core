import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionSettings extends StatefulWidget {
  const PermissionSettings({super.key});

  @override
  State<PermissionSettings> createState() => _PermissionSettingsState();
}

class _PermissionSettingsState extends State<PermissionSettings> with WidgetsBindingObserver {
  bool _isNotificationGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final notificationStatus = await Permission.notification.status;

    setState(() {
      _isNotificationGranted = notificationStatus.isGranted;
    });
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      setState(() {
        _isNotificationGranted = true;
      });
    } else if (status.isDenied) {
      setState(() {
        _isNotificationGranted = false;
      });
    } else if (status.isPermanentlyDenied) {
      _openNotificationSettings();
    }
  }

  Future<void> _openNotificationSettings() async {
    openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Permission Settings", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                "assets/ui/notification_permission.png",
                height: 200,
              ),
              const Divider(),
              InkWell(
                onTap: _isNotificationGranted
                    ? _openNotificationSettings
                    : _requestNotificationPermission,
                child: ListTile(
                  title: const Text("Notification Permission", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    _isNotificationGranted
                        ? "Notifications are enabled"
                        : "Notifications are disabled",
                    style: TextStyle(color: _isNotificationGranted ? Colors.green : Colors.red),
                  ),
                  trailing: Icon(
                    _isNotificationGranted ? Icons.notifications : Icons.notifications_off,
                    color: _isNotificationGranted ? Colors.green : Colors.red,
                    size: 30,
                  ),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  "Note: If you have permanently denied a permission, you can open the app settings to enable it manually.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}