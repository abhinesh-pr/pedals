import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodels/auth_model.dart';
import 'dart:convert'; // for utf8.encode
import 'package:crypto/crypto.dart'; // for hashing


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }


  Future<bool> isUserIdTaken(String userId) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: userId)
        .get();

    return result.docs.isNotEmpty;
  }


  // Signup with OTP verification
  Future<String> signUpUserWithOtp({
    required SignUpModel signUpModel,
    required String enteredOtp,
    required String sentOtp,
  }) async {
    if (enteredOtp != sentOtp) {
      return "Invalid OTP";
    }

    try {
      // Create a new user in Firebase Authentication
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: signUpModel.email,
        password: signUpModel.password,
      );

      // Update user profile with full name
      await cred.user?.updateProfile(displayName: signUpModel.fullName);
      await cred.user?.reload();

      // Store the user data in Firestore under "users" collection
      await FirebaseFirestore.instance.collection('users').doc(signUpModel.userId).set({
        'fullName': signUpModel.fullName,
        'email': signUpModel.email,
        'userId': signUpModel.userId,
        'createdAt': FieldValue.serverTimestamp(), // Automatically sets the creation time
      });

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('fullName', signUpModel.fullName);
        await prefs.setString('email', signUpModel.email);
        await prefs.setString('userId', signUpModel.userId);
        await prefs.setBool('isLoggedIn', true);
      } catch (e) {
        print('Error saving data: $e');
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? testValue = prefs.getString('email');
      print('Test Value: $testValue');



      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  // Login
  Future<String> loginUser(AuthCredentials credentials) async {
    try {
      // Sign in the user
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: credentials.email,
        password: credentials.password,
      );

      if (cred.user != null) {
        String email = cred.user!.email ?? '';

        // Query Firestore to get user document where email matches
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Extract user data
          var userDoc = querySnapshot.docs.first;
          String fullName = userDoc.data()['fullName'] ?? '';
          String userId = userDoc.data()['userId'] ?? '';

          // Save user data into SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('fullName', fullName);
          await prefs.setString('email', email);
          await prefs.setString('userId', userId);

          return "success";
        } else {
          return "User data not found in database";
        }
      } else {
        return "Login failed";
      }
    } catch (e) {
      return e.toString();
    }
  }



  // OTP sender
  Future<String?> sendOtp(String email) async {
    String otp = _generateOtp();

    try {
      String username = 'abhinesh436@gmail.com'; // Your email
      // String password = 'urmz bufm uzft cgev'; // App password
      String password = 'mdcu oyti jyys exdx'; // App password

      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'Pedals - Auth Service')
        ..recipients.add(email)
        ..subject = 'Your OTP Code'
        ..text = 'Your OTP code is: $otp';

      final sendReport = await send(message, smtpServer);

      if (sendReport != null) return otp;
      return null;
    } catch (e) {
      print("OTP Send Error: $e");
      return null;
    }
  }

  // Generate 6-digit OTP
  String _generateOtp() {
    return (100000 +
        (999999 - 100000) *
            (DateTime.now().millisecondsSinceEpoch % 1000000) /
            1000000)
        .toString()
        .substring(0, 4);
  }

  // Check if email is registered
  Future<bool> isEmailRegistered(String email, String testPassword) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: testPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return false;
      if (e.code == 'wrong-password') return true;
      return false;
    }
  }

  // Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar('Success', 'If the email exists, a reset link has been sent.');
    } catch (e) {
      Get.snackbar('Error', 'Failed: ${e.toString()}');
    }
  }

  // Update password
  Future<String> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
        await user.reload();
        return "Password updated";
      }
      return "User not logged in or empty password";
    } catch (e) {
      return e.toString();
    }
  }

  // Get current user details
  Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return {
        'uid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        'phoneNumber': user.phoneNumber,
      };
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
  }

  // Delete account
  Future<String> deleteUserAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', false);
        return "User deleted";
      }
      return "No user signed in";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return "Re-authentication required";
      }
      return e.message ?? "Unknown error";
    } catch (e) {
      return e.toString();
    }
  }

  // Google Sign In
  // Future<User?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return null;
  //
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     UserCredential userCredential = await _auth.signInWithCredential(credential);
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     prefs.setBool('isLoggedIn', true);
  //
  //     return userCredential.user;
  //   } catch (e) {
  //     print("Google Sign-In error: $e");
  //     return null;
  //   }
  // }
}
