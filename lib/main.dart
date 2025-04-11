import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  try {
    // Request storage permission
    await Permission.storage.request();
    print("Permission requested successfully.");
  } catch (e) {
    print("Error requesting permission: $e");
  }

  runApp( MyApp());
}