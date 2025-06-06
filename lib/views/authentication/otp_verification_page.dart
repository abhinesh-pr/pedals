import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../services/auth_service.dart';
import '../../viewmodels/auth_model.dart';
import '../users/user_dashboard.dart';

class OTPverification extends StatefulWidget {
  final SignUpModel signUpModel;
  final String sentOtp;
  final String email;
  const OTPverification({ Key? key, required this.signUpModel,required this.email, required this.sentOtp }) : super(key: key);

  @override
  _OTPverificationState createState() => _OTPverificationState();
}

class _OTPverificationState extends State<OTPverification> {

  final AuthService _authService = AuthService();
  bool _isResendAgain = false;
  final bool _isVerified = false;
  bool isLoading = false;
  final bool _isLoading = false;

  String _code = '';

  late Timer _timer;
  int _start = 60;
  int _currentIndex = 0;

  void resend() {
    if (!mounted) return;
    setState(() {
      _isResendAgain = true;
    });

    const oneSec = Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (timer) {
      if (!mounted) return;
      setState(() {
        if (_start == 0) {
          _start = 60;
          _isResendAgain = false;
          timer.cancel();
        } else {
          _start--;
        }
      });
    });
  }

  // verify() {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   const oneSec = Duration(milliseconds: 2000);
  //   _timer = new Timer.periodic(oneSec, (timer) {
  //     setState(() {
  //       _isLoading = false;
  //       _isVerified = true;
  //     });
  //   });
  // }

  void _verifyOtp() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    String result = await _authService.signUpUserWithOtp(
      signUpModel: widget.signUpModel,
      enteredOtp: _code,
      sentOtp: widget.sentOtp,
    );
    if (!mounted) return;
    setState(() => isLoading = false);

    if (result == "success") {
      Get.snackbar("Success", "Account created successfully!");
      Get.offAll(UserDashboard(uemail: widget.email,)); // or wherever you navigate after success
    } else {
      Get.snackbar("Error", result, snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (!mounted) return;
      setState(() {
        _currentIndex++;

        if (_currentIndex == 3)
          _currentIndex = 0;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 250,
                    child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: AnimatedOpacity(
                              opacity: _currentIndex == 0 ? 1 : 0,
                              duration: Duration(seconds: 1,),
                              curve: Curves.linear,
                              child: Image.network('https://ouch-cdn2.icons8.com/eza3-Rq5rqbcGs4EkHTolm43ZXQPGH_R4GugNLGJzuo/rs:fit:784:784/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNjk3/L2YzMDAzMWUzLTcz/MjYtNDg0ZS05MzA3/LTNkYmQ0ZGQ0ODhj/MS5zdmc.png',),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: AnimatedOpacity(
                              opacity: _currentIndex == 1 ? 1 : 0,
                              duration: Duration(seconds: 1),
                              curve: Curves.linear,
                              child: Image.network('https://ouch-cdn2.icons8.com/pi1hTsTcrgVklEBNOJe2TLKO2LhU6OlMoub6FCRCQ5M/rs:fit:784:666/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvMzAv/MzA3NzBlMGUtZTgx/YS00MTZkLWI0ZTYt/NDU1MWEzNjk4MTlh/LnN2Zw.png',),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: AnimatedOpacity(
                              opacity: _currentIndex == 2 ? 1 : 0,
                              duration: Duration(seconds: 1),
                              curve: Curves.linear,
                              child: Image.network('https://ouch-cdn2.icons8.com/ElwUPINwMmnzk4s2_9O31AWJhH-eRHnP9z8rHUSS5JQ/rs:fit:784:784/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNzkw/Lzg2NDVlNDllLTcx/ZDItNDM1NC04YjM5/LWI0MjZkZWI4M2Zk/MS5zdmc.png',),
                            ),
                          )
                        ]
                    ),
                  ),
                  SizedBox(height: 30,),
                  FadeInDown(
                      duration: Duration(milliseconds: 500),
                      child: Text("Verification", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)),
                  SizedBox(height: 30,),
                  FadeInDown(
                    delay: Duration(milliseconds: 500),
                    duration: Duration(milliseconds: 500),
                    child: Text("Please enter the 4 digit code sent to \n ${widget.signUpModel.email}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade500, height: 1.5),),
                  ),
                  SizedBox(height: 30,),

                  // Verification Code Input
                  FadeInDown(
                    delay: Duration(milliseconds: 600),
                    duration: Duration(milliseconds: 500),
                    child: VerificationCode(
                      length: 4,
                      textStyle: TextStyle(fontSize: 20, color: Colors.black),
                      underlineColor: Colors.black,
                      keyboardType: TextInputType.number,
                      underlineUnfocusedColor: Colors.black,
                      onCompleted: (value) {
                        setState(() {
                          _code = value;
                        });
                      },
                      onEditing: (value) {},
                    ),
                  ),


                  SizedBox(height: 20,),
                  FadeInDown(
                    delay: Duration(milliseconds: 700),
                    duration: Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't resive the OTP?", style: TextStyle(fontSize: 14, color: Colors.grey.shade500),),
                        TextButton(
                            onPressed: () {
                              if (_isResendAgain) return;
                              resend();
                            },
                            child: Text(_isResendAgain ? "Try again in " + _start.toString() : "Resend", style: TextStyle(color: Colors.blueAccent),)
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 50,),
                  FadeInDown(
                    delay: Duration(milliseconds: 800),
                    duration: Duration(milliseconds: 500),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading || _isVerified ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600, // Active background color
                            disabledBackgroundColor: Colors.blue.shade300, // Disabled background color
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: _isLoading
                                ? SizedBox(
                              key: ValueKey("loading"),
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : _isVerified
                                ? Icon(
                              Icons.check_circle,
                              key: ValueKey("verified"),
                              color: Colors.white,
                              size: 28,
                            )
                                : Text(
                              "Verify",
                              key: ValueKey("verifyText"),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )

                  )
                ],)
          ),
        )
    );
  }
}