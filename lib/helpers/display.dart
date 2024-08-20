import 'package:flutter/material.dart';

void displayDialogAndroid(BuildContext context, String title, String title2) {
  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 20,
          title: Text(title),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.circular(15)),
          content: Text(title2),
          actions: [
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Colors.red),
                )),
          ],
        );
      });
}
