 import 'package:flutter/material.dart';

Future<dynamic> standardAlertDialog({
    required BuildContext context,
    required String titleText,
    required String content,
    required String closeText,
  }) {
    Future<dynamic> alertDialog;

    alertDialog = showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text(
            titleText,
            style: Theme.of(context).textTheme.titleMedium
          ),
          content: Text(
            content,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.left,
          ),
          actions: [
            TextButton(
              child: Text(closeText),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      }
    );

    return alertDialog;
  }