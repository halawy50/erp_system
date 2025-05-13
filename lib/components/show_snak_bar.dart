
import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message, {Color? backgroundColor}) {
  final snackBar = SnackBar(
    content: Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0), // تقليل الحشو لجعل الـ SnackBar أصغر
      child: Text(message),
    ),
    backgroundColor: backgroundColor ?? Colors.black87,
    duration: Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // إضافة حدود مستديرة لتحسين الشكل
    ),
    margin: EdgeInsets.all(16), // إضافة هامش لتجنب التصاق الـ SnackBar بالأطراف
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
