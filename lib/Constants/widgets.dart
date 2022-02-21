import 'package:flutter/material.dart';

const SizedBox sizedBox = SizedBox(height: 30);
loader({required BuildContext context, required bool isShow}) {
  if (isShow) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  } else if (!isShow) {
    Navigator.pop(context);
  }
}
