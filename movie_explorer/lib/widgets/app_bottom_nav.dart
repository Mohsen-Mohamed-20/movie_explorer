import 'package:flutter/material.dart';

import '../screens/favorites_screen.dart';
import '../screens/search_screen.dart';

/// Bottom navigation: Home | Favorites | Search.
/// Home is always the first route of the app, so "go home" = pop back to it.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});

  /// 0 = Home, 1 = Favorites, 2 = Search
  final int currentIndex;

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final Widget screen =
        index == 1 ? const FavoritesScreen() : const SearchScreen();
    final route = MaterialPageRoute(builder: (_) => screen);

    if (currentIndex == 0) {
      Navigator.of(context).push(route);
    } else {
      // Favorites <-> Search: replace, so "back" still returns to Home.
      Navigator.of(context).pushReplacement(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}
