import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Reusable search field.
///  - Home:   readOnly = true, tapping it opens the Search screen.
///  - Search: a normal text field with validation.
/// (Named MovieSearchBar because Flutter already has a SearchBar widget.)
class MovieSearchBar extends StatelessWidget {
  const MovieSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search for movies...',
    this.readOnly = false,
    this.onTap,
    this.onSubmitted,
    this.validator,
  });

  final TextEditingController? controller;
  final String hintText;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color),
      );
    }

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: theme.hintColor, fontSize: 14),
        prefixIcon: Icon(Icons.search, color: theme.hintColor),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: border(theme.dividerColor),
        enabledBorder: border(theme.dividerColor),
        focusedBorder: border(primaryColor),
        errorBorder: border(errorColor),
        focusedErrorBorder: border(errorColor),
      ),
    );
  }
}
