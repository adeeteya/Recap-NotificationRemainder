import 'package:flutter/material.dart';

extension DateTimeExtensions on DateTime {
  String get timeAndDateInString {
    return "${hour > 12 ? hour - 12 : hour}:${minute > 9 ? minute : "0$minute"} ${(hour > 12) ? "PM" : "AM"} - $day/$month/$year";
  }
}

extension DarkMode on BuildContext {
  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }
}
