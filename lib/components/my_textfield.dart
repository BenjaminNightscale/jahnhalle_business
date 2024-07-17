import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FocusNode? focusNode;
  final int? maxLines; // Add maxLines parameter
  final VoidCallback? onTap; // Add onTap callback

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.focusNode,
    this.maxLines = 1, // Default value for maxLines
    this.onTap, // Add onTap to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          focusNode: focusNode,
          maxLines: maxLines, // Set maxLines
          minLines: maxLines, // Set minLines
          style: Theme.of(context).textTheme.displayMedium,
          decoration: InputDecoration(
            labelText: hintText,
            labelStyle: Theme.of(context).textTheme.bodySmall,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 1,
              ),
            ),
            filled: true,
            fillColor: Colors.black,
          ),
          onTap: onTap, // Set onTap callback
        ),
      ),
    );
  }
}
