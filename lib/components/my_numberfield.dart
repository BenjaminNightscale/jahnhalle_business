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
    this.isInteger = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: Theme.of(context).textTheme.displayMedium,
        keyboardType: TextInputType.numberWithOptions(
          decimal: !isInteger,
        ),
        inputFormatters: <TextInputFormatter>[
          isInteger
              ? FilteringTextInputFormatter.digitsOnly
              : FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d*')),
        ],
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: hintText,
          labelStyle: Theme.of(context).textTheme.bodyMedium,
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
      ),
    );
  }
}
