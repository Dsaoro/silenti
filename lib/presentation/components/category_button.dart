import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  const CategoryButton(
      {super.key, required this.child, required this.onPressed});
  final Widget child;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
          width: 150,
          height: 54,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(27),
              right: Radius.circular(27),
            ),
          ),
          child: TextButton(
            onPressed: onPressed,
            child: child,
          )),
    );
  }
}
