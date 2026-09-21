import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Displays a yellow star and the rating:  ★ 8.5
class RatingWidget extends StatelessWidget {
  const RatingWidget({
    super.key,
    required this.rating,
    this.fontSize = 13,
    this.textColor,
  });

  final double rating;
  final double fontSize;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: ratingColor, size: fontSize + 3),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
