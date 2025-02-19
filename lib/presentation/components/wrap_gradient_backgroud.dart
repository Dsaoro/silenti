import 'package:flutter/material.dart';

import '../../core/enums/silenti_colors.dart';

class WrapGradientBackground extends StatelessWidget {
  const WrapGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: [
              0.1,
              0.7,
            ],
            colors: [
              SilentiColors.primary,
              SilentiColors.dark,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
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
