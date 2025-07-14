import 'package:flutter/material.dart';
import 'package:smart_cart_app/core/themes/dark_theme/app_colors_dark.dart';
import 'package:smart_cart_app/core/themes/dark_theme/text_styles_dark.dart';

ThemeData getDarkTheme() => ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColorsDark.scaffoldBackgroundColor,
      textTheme: TextTheme(
        bodyLarge: TextStylesDark.getBodyLarge(),
        titleMedium: TextStylesDark.getTitleMedium(),
        titleSmall: TextStylesDark.getTitleSmall(),
        headlineSmall: TextStylesDark.getHeadlineSmall(),
        headlineMedium: TextStylesDark.getHeadlineMedium(),
        displaySmall: TextStylesDark.getDisplaySmall(),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColorsDark.scaffoldBackgroundColor.withAlpha(80),
        selectedIconTheme: const IconThemeData(
          color: Color(0xffff5d65),
        ),
        selectedItemColor: const Color(0xffff5d65),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all<Color>(
            const Color(0xff23272e),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        color: AppColorsDark.scaffoldBackgroundColor,
      ),
    );
