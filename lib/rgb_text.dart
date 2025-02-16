import 'package:flutter/material.dart';
import 'dart:ui';

class RGBText extends StatefulWidget {
  final String text;
  final TextStyle style;

  RGBText({required this.text, required this.style});

  @override
  _RGBTextState createState() => _RGBTextState();
}

class _RGBTextState extends State<RGBText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = _controller.drive(
      ColorTween(
        begin: Colors.red,
        end: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                _colorAnimation.value ?? Colors.red,
                Colors.green,
                Colors.blue,
              ],
              stops: [0.0, 0.5, 1.0],
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}
