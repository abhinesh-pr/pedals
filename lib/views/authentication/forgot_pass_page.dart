// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../services/auth_service.dart';
// import '../../viewmodels/auth_model.dart';
// import '../users/dashboard.dart';
//
// class OTPVerificationPage extends StatefulWidget {
//   final SignUpModel signUpModel;
//   final String sentOtp;
//
//   const OTPVerificationPage({
//     Key? key,
//     required this.signUpModel,
//     required this.sentOtp,
//   }) : super(key: key);
//
//   @override
//   State<OTPVerificationPage> createState() => _OTPVerificationPageState();
// }
//
// class _OTPVerificationPageState extends State<OTPVerificationPage> {
//   final List<TextEditingController> otpControllers =
//   List.generate(6, (_) => TextEditingController());
//   final AuthService _authService = AuthService();
//   bool isLoading = false;
//
//   void _verifyOtp() async {
//     setState(() => isLoading = true);
//
//     String otp = otpControllers.map((controller) => controller.text).join();
//     String result = await _authService.signUpUserWithOtp(
//       signUpModel: widget.signUpModel,
//       enteredOtp: otp,
//       sentOtp: widget.sentOtp,
//     );
//
//     setState(() => isLoading = false);
//
//     if (result == "success") {
//       Get.snackbar("Success", "Account created successfully!");
//       Get.offAll(Dashboard(username: 'Mee', email: 'myself',)); // or wherever you navigate after success
//     } else {
//       Get.snackbar("Error", result, snackPosition: SnackPosition.BOTTOM);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: null, // No AppBar in the second page design
//       body: SingleChildScrollView(
//         child: Container(
//           height: MediaQuery.of(context).size.height,
//           padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.background,
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "Enter OTP",
//                 style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                     color: Theme.of(context).colorScheme.primary),
//               ),
//               SizedBox(height: 20),
//               Text("A verification code has been sent to ${widget.signUpModel.email}"),
//               SizedBox(height: 30),
//               _buildOtpFields(),
//               SizedBox(height: 20),
//               isLoading
//                   ? CircularProgressIndicator()
//                   : ElevatedButton(
//                 onPressed: _verifyOtp,
//                 child: Text(
//                   "Verify OTP",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//               SizedBox(height: 20),
//               TextButton(
//                 onPressed: () {
//                   // Handle resend OTP action
//                 },
//                 child: Text("Resend OTP"),
//               ),
//               SizedBox(height: 20),
//               TextButton(
//                 onPressed: () => Get.off(() => LoginPage()),
//                 child: Text("Back to Login"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOtpFields() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: List.generate(6, (index) {
//         return SizedBox(
//           width: 40,
//           child: TextField(
//             controller: otpControllers[index],
//             keyboardType: TextInputType.number,
//             textAlign: TextAlign.center,
//             maxLength: 1,
//             decoration: InputDecoration(
//               counterText: "",
//               border: OutlineInputBorder(),
//             ),
//             onChanged: (value) {
//               if (value.length == 1 && index < 5) {
//                 FocusScope.of(context).nextFocus();
//               }
//             },
//           ),
//         );
//       }),
//     );
//   }
// }
