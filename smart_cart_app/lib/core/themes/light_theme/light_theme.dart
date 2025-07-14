import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_cart_app/core/themes/light_theme/app_colors_light.dart';
import 'package:smart_cart_app/core/themes/light_theme/text_styles_light.dart';

ThemeData getLightTheme() => ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColorsLight.scaffoldBackgroundColor,
      textTheme: TextTheme(
        bodyLarge: TextStylesLight.getBodyLarge(),
        bodySmall: TextStylesLight.getBodySmall(),
        bodyMedium: TextStylesLight.getBodyMedium(),
        labelLarge: TextStylesLight.getLabelLarge(),
        titleMedium: TextStylesLight.getTitleMedium(),
        titleSmall: TextStylesLight.getTitleSmall(),
        headlineSmall: TextStylesLight.getHeadlineSmall(),
        headlineMedium: TextStylesLight.getHeadlineMedium(),
        headlineLarge: TextStylesLight.getHeadlineLarge(),
        displaySmall: TextStylesLight.getDisplaySmall(),
        displayMedium: TextStylesLight.getDisplayMedium(),
        displayLarge: TextStylesLight.getDisplayLarge(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: AppColorsLight.appBarCompsColor),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColorsLight.appBarCompsColor),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xff5b9ee1),
        showUnselectedLabels: false,
        enableFeedback: false,
        selectedItemColor: Colors.white,
        selectedIconTheme: IconThemeData(color: Colors.white, size: 24.sp),
        elevation: 0,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
      ),
      appBarTheme: const AppBarTheme(
        color: AppColorsLight.scaffoldBackgroundColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarColor: AppColorsLight.scaffoldBackgroundColor,
        ),
      ),
    );
