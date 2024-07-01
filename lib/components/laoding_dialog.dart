import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  final bool isSuccess;
  final bool isError;

  const LoadingDialog({
    Key? key,
    this.message = 'Loading...',
    this.isSuccess = false,
    this.isError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isSuccess
                ? Icon(Icons.check_circle, color: Colors.green, size: 40)
                : isError
                    ? Icon(Icons.error, color: Colors.red, size: 40)
                    : CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
