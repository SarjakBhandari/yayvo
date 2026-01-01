import 'package:flutter/material.dart';

class HomeFeedRetailer extends StatefulWidget {
  const HomeFeedRetailer({super.key});

  @override
  State<HomeFeedRetailer> createState() => _HomeFeedRetailerState();
}

class _HomeFeedRetailerState extends State<HomeFeedRetailer> {
  int _selectedIndex = 0;

  // Provide a widget for each BottomNavigationBarItem
  final List<Widget> lstBottomScreen = const [
    Center(child: Text("Home Screen")),
    Center(child: Text("Explore Screen")),
    Center(child: Text("Create Screen")),
    Center(child: Text("My Products Screen")),
    Center(child: Text("Profile Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor:
        theme.bottomNavigationBarTheme.selectedItemColor ??
            theme.colorScheme.primary,
        unselectedItemColor:
        theme.bottomNavigationBarTheme.unselectedItemColor ??
            theme.colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: theme.bottomNavigationBarTheme.selectedLabelStyle,
        unselectedLabelStyle: theme.bottomNavigationBarTheme.unselectedLabelStyle,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: "Create",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: "My Products",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: lstBottomScreen[_selectedIndex],
    );
  }
}
