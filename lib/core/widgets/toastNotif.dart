import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

String cleanMessage(String msg) {
  if (msg.length > 100) {
    return "${msg.substring(0, 100)}...";
  }
  return msg;
}

void showToast(
    BuildContext context,
    String title,
    String description,
    ToastificationType type,
    ) {
  final color = type.color;

  toastification.show(
    context: context,
    type: type,

    title: Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),

    description: Text(
      cleanMessage(description),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.white70,
        height: 1.3,
      ),
    ),

    backgroundColor: color.withOpacity(0.9),
    foregroundColor: Colors.white,

    autoCloseDuration: const Duration(seconds: 7),
    showProgressBar: true,
    progressBarTheme: ProgressIndicatorThemeData(color: Colors.white),
  );
}