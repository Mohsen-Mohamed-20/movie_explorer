import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A rounded label such as [ Action ].
///  - default:   neutral chip (Details screen)
///  - selected:  purple chip (selected genre filter on Home)
///  - small:     tiny tinted tag (inside cards)
class GenreChip extends StatelessWidget {
  const GenreChip({
    super.key,
    required this.label,
    this.selected = false,
    this.small = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool small;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color background;
    Color textColor;
    if (selected) {
      background = primaryColor;
      textColor = Colors.white;
    } else if (small) {
      background = primaryColor.withValues(alpha: 0.18);
      textColor = isDark ? secondaryColor : primaryColor;
    } else {
      background = theme.cardColor;
      textColor = theme.colorScheme.onSurface;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 10 : 16,
          vertical: small ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: (selected || small)
              ? null
              : Border.all(color: theme.dividerColor),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: small ? 11 : 13,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
