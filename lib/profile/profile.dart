import 'package:bracu_core/auth/login.dart';
import 'package:bracu_core/profile/feedback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/profile_provider.dart';
import 'update.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  void _navigateTo(BuildContext context, Widget route) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => route));
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white38,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(profileProvider),
            SizedBox(height: 20),
            _buildGridOptions(context, profileProvider),
            SizedBox(height: 20),
            _buildAppSettings(context, profileProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileProvider profileProvider) {
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(profileProvider.profilePicture?.isNotEmpty == true
                ? profileProvider.profilePicture!
                : 'https://decisionsystemsgroup.github.io/workshop-html/img/john-doe.jpg'),
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            '${profileProvider.firstName} ${profileProvider.lastName}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildGridOptions(BuildContext context, ProfileProvider profileProvider) {
    List<String> options = ['Update Profile', 'Change Password', 'Location Setting'];
    List<IconData> icons = [Icons.person_outline, Icons.lock_outline, Icons.location_on_outlined];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Profile settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 3,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if (options[index] == 'Update Profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateProfilePage(
                        studentId: profileProvider.studentId,
                        phoneNumber: profileProvider.phoneNumber,
                        department: profileProvider.department,
                        permanentAddress: profileProvider.permanentAddress,
                        presentAddress: profileProvider.currentAddress,
                        emergencyContactName: profileProvider.emergencyName,
                        emergencyContactRelation: profileProvider.emergencyRelation,
                        emergencyContactPhoneNumber: profileProvider.emergencyPhoneNumber,
                      ),
                    ),
                  );
                }
              },
              child: Card(
                color: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.black87, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[index], size: 40, color: Colors.teal,),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(options[index], textAlign: TextAlign.center, style: TextStyle(fontSize: 14,),maxLines: 2,),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppSettings(BuildContext context, ProfileProvider profileProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('App Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        SizedBox(height: 10),
        ListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildListTile(Icons.notifications_none_outlined, 'Notification Setting', Colors.black, context, null),
            _buildListTile(Icons.star_border_outlined, 'Rate App', Colors.black, context, RatingPage()),
            if (profileProvider.role == 'Admin')
              _buildListTile(Icons.admin_panel_settings_outlined, 'Admin Panel', Colors.red, context, null),
            _buildListTile(Icons.feedback_outlined, 'Feedback', Colors.black, context, null),
            _buildListTile(Icons.share_outlined, 'Invite', Colors.black, context, null),
            _buildListTile(Icons.help_outline, 'Help', Colors.black, context, null),
            _buildListTile(Icons.privacy_tip_outlined, 'Privacy Policy', Colors.black, context, null),
            _buildListTile(Icons.logout_outlined, 'Logout', Colors.red, context, null),
          ],
        ),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, Color iconColor, BuildContext context, Widget? route) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: () {
          if (title == 'Logout') {
            _showLogoutDialog(context);
          } else if (route != null) {
            _navigateTo(context, route);
          }
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Do you really want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                profileProvider.updateLoginStatus(false);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login()));
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}