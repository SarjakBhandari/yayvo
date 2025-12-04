import 'package:flutter/material.dart';
import '../common/show_my_snack_bar.dart';

class BottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onHomeTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onHomeTap,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final List<Map<String, dynamic>> _tabs = [
    {"label": "Home", "icon": Icons.home},
    {"label": "Explore", "icon": Icons.explore},
    {"label": "Create", "icon": Icons.add_circle},
    {"label": "Collections", "icon": Icons.bookmark},
    {"label": "Profile", "icon": Icons.person},
  ];

  void _onItemTapped(int index) {
    if (index == 0) {
      widget.onHomeTap(index);
    } else {
      showMySnackBar(
        context: context,
        message: "Not implemented yet",
        status: SnackBarStatus.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.currentIndex,
      onTap: _onItemTapped,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: _tabs.map((tab) {
        return BottomNavigationBarItem(
          icon: Icon(tab["icon"]),
          label: tab["label"],
        );
      }).toList(),
    );
  }
}
