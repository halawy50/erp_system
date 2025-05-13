import 'package:flutter/material.dart';

class SelectableTextWrapper extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const SelectableTextWrapper(
      this.text, {
        this.style,
        this.textAlign,
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      style: style,
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}
