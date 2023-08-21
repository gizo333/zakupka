import 'package:flutter/material.dart';

class SnackBarService {
  static const errorColor = Colors.red;
  static const okColor = Colors.green;

  static void showSnackBar(BuildContext context, String message, bool error) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: error ? errorColor : okColor,
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior
          .floating, // Этот параметр задает длительность отображения
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
