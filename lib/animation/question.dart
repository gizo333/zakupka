import 'package:flutter/material.dart';

class AnimatedQuestionMarkIcon extends StatefulWidget {
  @override
  _AnimatedQuestionMarkIconState createState() =>
      _AnimatedQuestionMarkIconState();
}

class _AnimatedQuestionMarkIconState extends State<AnimatedQuestionMarkIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
      child: Icon(Icons.help_outline, size: 16),
    );
  }
}
