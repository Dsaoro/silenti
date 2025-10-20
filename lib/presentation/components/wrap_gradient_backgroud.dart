import 'package:flutter/material.dart';

// ignore: must_be_immutable
class WrapGradientBackground extends StatelessWidget {
  WrapGradientBackground({super.key, required this.child, this.gradient});

  final Widget child;
  LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    LinearGradient defaultGradient = LinearGradient(
      stops: [
        0.1,
        0.7,
      ],
      colors: [
        Theme.of(context).colorScheme.surface,
        Theme.of(context).colorScheme.surface,
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
    return Stack(children: [
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient ?? defaultGradient,
        ),
      ),
      Center(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [child],
        ),
      ),
    ]);
  }
}
