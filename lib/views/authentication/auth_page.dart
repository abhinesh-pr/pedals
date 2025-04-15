import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pedals/views/authentication/forgot_pass_page.dart';
import 'package:pedals/views/users/user_dashboard.dart';

import '../../services/auth_service.dart';
import '../../viewmodels/auth_model.dart';
import 'otp_verification_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _signUpNameController = TextEditingController();
  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.asset(
                  'assets/images/logo1.png',
                  height: 50.h,
                ),
              ),

              Text("Pedals", style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 30.h),
              DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        height: 45.h,
                        width: 300.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          tabs: [
                            Tab(text: "Login"),
                            Tab(text: "Sign Up"),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        height: 450.h,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLoginForm(),
                            _buildSignUpForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email", style: TextStyle(color: Colors.black)),
            SizedBox(height: 5.h),
            TextField(
              controller: _loginEmailController,
              decoration: _inputDecoration("student@kgkite.ac.in"),
            ),
            SizedBox(height: 10.h),
            Text("Password", style: TextStyle(color: Colors.black)),
            SizedBox(height: 5.h),
            TextField(
              controller: _loginPasswordController,
              obscureText: true,
              decoration: _inputDecoration("Enter password"),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: _buttonStyle(),
                onPressed: () async {
                  final AuthService authService = AuthService();
                  final email = _loginEmailController.text.trim();
                  final password = _loginPasswordController.text.trim();

                  if (email.isNotEmpty && password.isNotEmpty) {
                    AuthCredentials credentials = AuthCredentials(email: email, password: password);
                    String result = await authService.loginUser(credentials);

                    if (result == "success") {
                      Get.offAll(MapsPage(uemail: email,));
                      // Navigate to the next screen or show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Login successful!")),
                      );

                      // Example: Navigator.pushReplacement(...)
                    } else {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Login failed: $result")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter email and password.")),
                    );
                  }
                },

                child: Text("Login", style: TextStyle(fontSize: 16.sp)),
              ),
            ),
            SizedBox(height: 10.h),
            Center(
              child: TextButton(
                onPressed: () {
                  Get.to(ForgotPasswordPage());
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                ),
              ),
            ),
            SizedBox(height: 90.h),

            // Guest Login as outlined TextButton
            Center(
              child: TextButton(
                onPressed: () {
                  // Handle guest login
                },
                style: TextButton.styleFrom(
                  side: BorderSide(color: Colors.grey, width: 1.5),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical:2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Guest Login",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(height: 7.h),

            // Admin Login as TextButton
            Center(
              child: TextButton(
                onPressed: () {
                  // Handle admin login
                },
                child: Text(
                  "Admin Login",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSignUpForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Full Name", style: TextStyle(color: Colors.black)),
            SizedBox(height: 5.h),
            TextField(
              controller: _signUpNameController,
              decoration: _inputDecoration("John Doe"),
            ),
            SizedBox(height: 5.h,),
            // New Student ID Field
            Text("User ID", style: TextStyle(color: Colors.black)),
            SizedBox(height: 5.h),
            TextField(
              controller: _studentIdController,
              decoration: _inputDecoration("Student/Employee ID"),
            ),
            SizedBox(height: 10.h),
            Text("Email", style: TextStyle(color: Colors.black)),
            SizedBox(height: 5.h),
            TextField(
              controller: _signUpEmailController,
              decoration: _inputDecoration("name@example.com"),
            ),
            SizedBox(height: 10.h),
            Text("Password", style: TextStyle(color: Colors.black)),
            SizedBox(height: 5.h),
            TextField(
              controller: _signUpPasswordController,
              obscureText: true,
              decoration: _inputDecoration("Enter password"),
            ),
            SizedBox(height: 10.h),
            Text("Confirm Password", style: TextStyle(color: Colors.black)),
            SizedBox(height: 5.h),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: _inputDecoration("Confirm password"),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: _buttonStyle(),
                onPressed: () async {
                  final fullName = _signUpNameController.text.trim();
                  final userId = _studentIdController.text.trim();
                  final email = _signUpEmailController.text.trim();
                  final password = _signUpPasswordController.text.trim();
                  final confirmPassword = _confirmPasswordController.text.trim();

                  if (fullName.isEmpty || userId.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                    Get.snackbar("Error", "All fields are required");
                    return;
                  }

                  if (password != confirmPassword) {
                    Get.snackbar("Error", "Passwords do not match");
                    return;
                  }

                  final AuthService _authService = AuthService();
                  bool alreadyExists = await _authService.isEmailRegistered(email, password);

                  if (alreadyExists) {
                    Get.snackbar("Error", "Email already registered");
                    return;
                  }
                  bool userIdExists = await AuthService().isUserIdTaken(userId.toUpperCase());

                  if (userIdExists) {
                    Get.snackbar('Error', 'User ID already taken. Try another one.');
                    return;
                  }


                  String? otp = await _authService.sendOtp(email);
                  if (otp != null) {
                    final signUpModel = SignUpModel(
                      fullName: fullName,
                      userId: userId.toUpperCase(),
                      email: email,
                      password: password,
                    );

                    Get.to(() => OTPverification(
                      email: email,
                      signUpModel: signUpModel,
                      sentOtp: otp,
                    ));
                  } else {
                    Get.snackbar("Error", "Failed to send OTP. Try again.");
                  }
                },
                // Placeholder
                child: Text("Sign Up", style: TextStyle(fontSize: 16.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 12.w), // Reduce height here
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide.none,
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}
