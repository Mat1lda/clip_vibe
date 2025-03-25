import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonTextCustom extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Alignment alignment;
  final int? maxLines;
  final double height;
  final String fontFamily;
  final int fontWeight;
  final VoidCallback onPress;

  ButtonTextCustom(
    this.text,
    this.fontSize,
    this.color,
    this.alignment,
    this.maxLines,
    this.height,
    this.fontFamily,
    this.fontWeight,
    this.onPress,
  );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      alignment: Alignment.topLeft,
      child: TextButton(
        onPressed: onPress,
        child: Text(
            text,
            style: TextStyle(
              color: color,
              height: height,
              fontSize: fontSize,
              fontWeight: FontWeight.bold
            )),
      ),
    );
  }
}
