import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The "🎬 Movie Explorer" title shown in the app bar of Home and Favorites.
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.movie_creation_outlined, color: primaryColor, size: 22),
        SizedBox(width: 8),
        Text(
          'Movie Explorer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
