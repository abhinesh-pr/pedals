import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AppLinks stream listener
  final AppLinks _appLinks = AppLinks();
  _appLinks.uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      print('Received deep link: $uri');
      // Handle the deep link URI here, e.g., navigate to specific screen
    }
  });


  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  try {
    // Initialize Firebase
    await Supabase.initialize(
      url: 'https://wmpsrbceoqatpmcgpvjd.supabase.co', // Your Supabase URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndtcHNyYmNlb3FhdHBtY2dwdmpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYwOTM1NTMsImV4cCI6MjA2MTY2OTU1M30.8S5TFs-aza8fCKbA3Z3-58W0jY9mU7KUEcxb8mDAd94', // The anonKey you copied
    );
    print("Supabase initialized successfully.");
  } catch (e) {
    print("Error initializing Supabase: $e");
  }



  try {
    Get.put(AuthController());
    print("AuthController initialized successfully.");
  } catch (e) {
    print("Error initializing AuthController: $e");
  }

  try {
    // Request storage permission
    await Permission.storage.request();
    print("Permission requested successfully.");
  } catch (e) {
    print("Error requesting permission: $e");
  }

  runApp(MyApp());
}

