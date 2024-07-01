import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyNumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final bool isInteger;

  const MyNumberTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.isInteger = true, // Standardmäßig Ganzzahl
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.numberWithOptions(
          decimal: !isInteger,
        ),
        inputFormatters: <TextInputFormatter>[
          isInteger
              ? FilteringTextInputFormatter.digitsOnly
              : FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
        ],
        textInputAction:
            TextInputAction.done, // Set the action button to 'done'
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
