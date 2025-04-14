
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../views/authentication/auth_page.dart';
import '../views/users/user_dashboard.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observing user state
  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    if (user == null) {
      Get.off(AuthPage()); // Navigate to login if no user
    } else {
      Get.off(MapsPage()); // Navigate to dashboard if logged in
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
