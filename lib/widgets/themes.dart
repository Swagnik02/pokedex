import 'package:flutter/material.dart';

class TextThemeStyle {
  final BuildContext context;

  // Constructor that takes BuildContext
  TextThemeStyle(this.context);

  // Lazily initialize the text styles using getters
  TextStyle get themeHeadlineLarge {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white60,
        );
  }

  TextStyle get themeHeadlineSmall {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black45,
        );
  }

  TextStyle get themeOfChips {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        );
  }

  TextStyle get themeOfTypeChips {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        );
  }
}
