import 'package:flutter/material.dart';

// Primary Colors (Lavender Theme)
const primaryColor = Color(0xFFB57EDC); // Lavender
const secondaryColor = Color(0xFFD6B4FC); // Light Lavender
const tertiaryColor = Color(0xFFE6CCFF); // Pale Lavender

// Text Colors (Responsive to Theme)
const darkTextColor = Colors.black; // Light Theme Text
const lightTextColor = Colors.white; // Dark Theme Text
const headlineTextColor = Colors.black; // Default to black for headlines

// Background Colors
var backgroundColor = Color(0xFFF5F3FF); // Very light lavender background
const cardBackgroundColor = Colors.white; // White Card
var overlayBackgroundColor = Color(0xFFEDE7F6); // Light Lavender Overlay

// Accent Colors
const successColor = Color(0xFF81C784); // Soft Green
const errorColor = Color(0xFFE57373); // Soft Red
const warningColor = Color(0xFFFFF176); // Soft Yellow

// Grayscale
const grayDark = Colors.grey; // Material Grey
var gray = Colors.grey[400]; // Light Grey
var grayLight = Colors.grey[200]; // Lighter Grey

// Gradients
const primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [primaryColor, secondaryColor],
);

const secondaryGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [tertiaryColor, primaryColor],
);

// Example Asset Paths (Placeholder for illustration)
class AppImages {
  static const logo = 'assets/images/logo.png';
  static const placeholder = 'assets/images/placeholder.png';
  static const avatarDefault = 'assets/images/avatar-default.png';
  static const onboardingImage = 'assets/images/onboarding.png';
}
