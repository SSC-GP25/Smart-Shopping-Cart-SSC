import 'package:flutter/material.dart';

class TextStylesDark {
  static getLabelLarge() => const TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white);

  static getBodyLarge() => const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white);

  static getTitleMedium() => const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);

  static getTitleSmall() => const TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white);

  static getHeadlineMedium() => const TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white);

  static getHeadlineSmall() => const TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white);

  static getDisplaySmall() => const TextStyle(
      fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white);
}
