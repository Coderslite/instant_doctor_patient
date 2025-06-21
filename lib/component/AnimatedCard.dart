import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final Color color1;
  final Color color2;
  const AnimatedCard(
      {super.key,
      required this.child,
      required this.color1,
      required this.color2});
  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  late Color color1;
  late Color color2;
  handleGetColors() {
    color1 = widget.color1;
    color2 = widget.color2;
    gradientColors.add(
      [color1, color2],
    );
    gradientColors.add(
      [color2, color1],
    );
  }

  final List<List<Color>> gradientColors = [];
  int colorIndex = 0;
  late Timer _colorChangeTimer;

  @override
  void initState() {
    super.initState();
    handleGetColors();
    _startGradientAnimation();
  }

  @override
  void dispose() {
    _colorChangeTimer.cancel();
    super.dispose();
  }

  void _startGradientAnimation() {
    _colorChangeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        colorIndex = (colorIndex + 1) % gradientColors.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors[colorIndex],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage("assets/images/sol_bg.png"),
          fit: BoxFit.cover,
          opacity: 0.03,
        ),
      ),
      child: widget.child,
    );
  }
}
