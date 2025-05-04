import 'package:flutter/material.dart';
import 'constants.dart';

bool isDarkMode = false;  // Global variable to check if it's dark mode or not

// Define light theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryColor, // Vibrant Indigo
  hintColor: grayLight, // Subtle Gray
  scaffoldBackgroundColor: backgroundColor, // Light Theme Background
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: darkTextColor), // Main Text Color
    bodyMedium: TextStyle(color: darkTextColor),
    headlineMedium: TextStyle(color: headlineTextColor, fontWeight: FontWeight.bold), // Headlines
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: primaryColor, // Primary button color
    textTheme: ButtonTextTheme.primary, // Ensure text color matches primary color
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, backgroundColor: primaryColor, // Button Text and Background
    ),
  ),
  colorScheme: ColorScheme.light(
    primary: primaryColor,      // Primary Color
    secondary: secondaryColor, // Text on Background
    surface: cardBackgroundColor, // Surface Color (e.g., Cards)
    onSurface: darkTextColor,    // Text on Surface
    tertiary: tertiaryColor,     // Tertiary Accent Color
    error: errorColor,           // Error Color
    onError: Colors.white,       // Text on Error
  ),
  cardColor: cardBackgroundColor, // Card Background Color
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

// Define dark theme
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor, // Vibrant Indigo
  hintColor: gray, // Medium Gray for hints
  scaffoldBackgroundColor: const Color(0xFF121212), // Dark Background
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: lightTextColor), // Main Text Color for Dark Theme
    bodyMedium: TextStyle(color: lightTextColor),
    headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Headlines
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: primaryColor, // Primary button color
    textTheme: ButtonTextTheme.primary, // Ensure text color matches primary color
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black, backgroundColor: secondaryColor, // Button Text and Background
    ),
  ),
  colorScheme: const ColorScheme.dark(
    primary: primaryColor,        // Primary Color
    secondary: secondaryColor, // Text on Background
    surface: Color(0xFF1F1F1F),    // Surface Color (e.g., Cards)
    onSurface: lightTextColor,    // Text on Surface
    tertiary: tertiaryColor,      // Tertiary Accent Color
    error: errorColor,            // Error Color
    onError: Colors.black,        // Text on Error
  ),
  cardColor: const Color(0xFF1F1F1F), // Card Background for Dark Theme
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
