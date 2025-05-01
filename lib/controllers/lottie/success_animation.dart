import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class SuccessAnimation extends StatefulWidget {
  @override
  _SuccessAnimationState createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/lotties/success_lottie.json',
      height: 80,
      controller: _controller,
      onLoaded: (composition) {
        _controller
          ..duration = composition.duration
          ..forward(); // Play once
      },
    );
  }
}
