import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // تأكد من استيراد هذه المكتبة ل `Navigator`
import 'package:system_pvc/constant/color.dart';

Widget buttonBack(BuildContext context, void Function(bool) onBack) {
  return InkWell(
    onTap: () {
      onBack(true);
    },
    child: Container(
      decoration: BoxDecoration(
          color: ColorApp.gray,
          borderRadius: BorderRadius.circular(10000)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30.0 , vertical: 13),
      child: Container(
        child: Text(
          "رجوع",
          style: TextStyle(
            color: ColorApp.black,
          ),
        ),
      ),
    ),
  );
}
