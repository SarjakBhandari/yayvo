import 'package:flutter/material.dart';

enum ConsumerRoute {
  home,
  explore,
  create,
  collection,
  profile,
}

extension ConsumerRouteExt on ConsumerRoute {
  String get label {
    switch (this) {
      case ConsumerRoute.home:
        return 'Home';
      case ConsumerRoute.explore:
        return 'Explore';
      case ConsumerRoute.create:
        return 'Create';
      case ConsumerRoute.collection:
        return 'Collection';
      case ConsumerRoute.profile:
        return 'Profile';
    }
  }

  IconData get icon {
    switch (this) {
      case ConsumerRoute.home:
        return Icons.home_rounded;
      case ConsumerRoute.explore:
        return Icons.explore_rounded;
      case ConsumerRoute.create:
        return Icons.add_box_rounded;
      case ConsumerRoute.collection:
        return Icons.bookmark_rounded;
      case ConsumerRoute.profile:
        return Icons.person_rounded;
    }
  }
}
