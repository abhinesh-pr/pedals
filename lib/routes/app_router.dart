import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:pedals/views/authentication/admin_login_page.dart';
import 'package:pedals/views/authentication/auth_page.dart';
import 'package:pedals/views/authentication/guest_login_page.dart';

import 'app_routes.dart';

class AppRouter {
  static final List<GetPage> routes = [
    GetPage(name: AppRoutes.auth, page: () => AuthPage()),
    GetPage(name: AppRoutes.adminLogin, page: () => AdminLoginPage()),
    GetPage(name: AppRoutes.guestLogin, page: ()=> GuestLoginPage()),
  ];
}