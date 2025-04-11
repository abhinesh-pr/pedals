import 'package:flutter/material.dart';

// Primary Colors
const primaryColor = Colors.indigo; // Material Indigo
const secondaryColor = Colors.blueAccent; // Material Light Blue
const tertiaryColor = Colors.orangeAccent; // Material Orange Accent

// Text Colors
const darkTextColor = Colors.black87; // Dark Text
const lightTextColor = Colors.blueGrey; // Material Blue Grey
const headlineTextColor = Colors.black; // Material Black

// Background Colors
var backgroundColor = Colors.grey[50]; // Light Grey Background
const cardBackgroundColor = Colors.white; // White Card
var overlayBackgroundColor = Colors.grey[200]; // Light Grey Overlay

// Accent Colors
const successColor = Colors.green; // Material Green
const errorColor = Colors.red; // Material Red
const warningColor = Colors.yellow; // Material Yellow

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