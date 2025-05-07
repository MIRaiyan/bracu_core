import 'package:bracu_core/resources/course_details.dart';
import 'package:bracu_core/menu/menu.dart';
import 'package:bracu_core/profile/profile.dart';
import 'package:bracu_core/resources/course_home.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import '../service/profile_provider.dart';
import 'home_screen.dart';
import 'searchbar.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    //Initialize widget options using gsuite from ProfileProvider
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    //Assume profileData getter;
    final gsuite = profileProvider.gsuite??'';
    _widgetOptions=[
      HomeScreen(),
      Menu(),
      SearchPage(gsuite: gsuite),
      Profile(),
    ];
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
          child: GNav(
            gap: 8,
            selectedIndex: _selectedIndex,
            onTabChange: _onTabChange,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: Colors.white,
            color: Colors.grey[600],
            activeColor: Colors.white,
            tabBackgroundColor: Colors.black.withOpacity(0.8),
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.menu_open,
                text: 'Menu',
              ),
              GButton(
                icon: Icons.menu_book,
                text: 'Courses',
              ),
              GButton(
                icon: Icons.person_outline,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}