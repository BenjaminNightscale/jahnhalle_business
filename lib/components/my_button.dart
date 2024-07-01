import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function() onTap;
  final String text;
  final Color? color; // Make color optional
  final bool outlined;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color, // No default value here
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Theme.of(context).colorScheme.primary; // Use primary color if no color is provided

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : buttonColor,
          borderRadius: BorderRadius.circular(10),
          border: outlined ? Border.all(color: buttonColor) : null,
        ),
        child: Center(
          child: Text(
            text,
            style: outlined
                ? Theme.of(context).textTheme.labelSmall?.copyWith(color: buttonColor)
                : Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
