
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pedals/routes/app_router.dart';
import 'package:pedals/routes/app_routes.dart';
import 'package:pedals/views/authentication/auth_page.dart';
import 'package:pedals/views/users/user_dashboard.dart';

import 'controllers/auth_controller.dart';
import 'core/utils/themes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Your design's screen width and height
      minTextAdapt: true, // Optional, helps to adjust text sizes
      builder: (context, child) {
        return GetMaterialApp(
          theme: lightTheme, // Apply the light theme
          darkTheme: darkTheme, // Apply the dark theme
          themeMode: ThemeMode.system, // Switch themes based on system settings
          // initialRoute: AppRoutes.auth, // Initial route
          getPages: AppRouter.routes, // Centralized route management
          defaultTransition: Transition.native,
          transitionDuration: const Duration(milliseconds: 300),
          home: Obx(() {
            User? user = Get.find<AuthController>().firebaseUser.value;
            if (user == null) {
              return  AuthPage(); // Replace with your login page
            } else {
              return  MapsPage(uemail: user.email); // Replace with your dashboard page
            }
          }),
        );
      },
    );
  }
}