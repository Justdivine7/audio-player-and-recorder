import 'package:flutter/material.dart';

// LIGHT AND DARK MODE THEMES
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Nunito',
  scaffoldBackgroundColor: Colors.white,
  cardColor: const Color.fromARGB(255, 141, 142, 143),
  hintColor: const Color.fromRGBO(255, 108, 0, 1),
  focusColor: Colors.black,
  primaryColor: Colors.white,
  canvasColor: Colors.grey[400]!,
  highlightColor: Colors.grey[100]!,
  indicatorColor: const Color.fromARGB(255, 54, 54, 54),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Nunito',
  scaffoldBackgroundColor: const Color.fromARGB(255, 24, 24, 26),
  cardColor: const Color.fromRGBO(
    152,
    162,
    179,
    0.2,
  ),
  canvasColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  focusColor: Colors.white,
  hintColor: const Color.fromRGBO(255, 108, 0, 1),
  primaryColor: Colors.white,
  indicatorColor: const Color.fromARGB(255, 123, 122, 122),
  textTheme: const TextTheme(
    bodySmall: TextStyle(color: Colors.white),
  ),
);
