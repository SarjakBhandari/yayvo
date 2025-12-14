import 'package:flutter/material.dart';
import 'package:yayvo/screens/dashboard_screens/consumer/add_review_screen.dart';
import 'package:yayvo/screens/dashboard_screens/consumer/collections_screen.dart';
import 'package:yayvo/screens/dashboard_screens/consumer/consumer_home_screen.dart';
import 'package:yayvo/screens/dashboard_screens/consumer/explore_screen.dart';
import 'package:yayvo/screens/dashboard_screens/consumer/profile_screen.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  int _selectedIndex=0;

  List<Widget> lstBottomScreen = [
    const ConsumerHomeScreen(),
    const ExploreScreen(),
    const AddReviewScreen(),
    const CollectionsScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),
              label: "Home"
          ),
          BottomNavigationBarItem(icon: Icon(Icons.explore),
              label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle),
              label: "Create"),
          BottomNavigationBarItem(icon: Icon(Icons.collections),
              label: "Collection"),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: "Profile")
        ],
        currentIndex: _selectedIndex,
        onTap: (index){
          setState(() {
            _selectedIndex= index;
          });
        },

      ),
      body: lstBottomScreen[_selectedIndex],
    );
  }
}
