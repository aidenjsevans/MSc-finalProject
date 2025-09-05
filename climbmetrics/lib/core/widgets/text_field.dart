import 'package:climbmetrics/core/utils/constants.dart';
import 'package:flutter/material.dart';

Widget standardTextField({
  required TextEditingController controller,
  required String? errorText,
  required String labelText,
  bool obscureText = false,
  int maxLines = 1,
  Key? key
}) {
  return TextField(
    key: key,
    obscureText: obscureText,
    controller: controller,
    maxLines: maxLines,
    style: TextStyle(
      fontSize: TextFieldConstant.primaryFontSize
    ),
    decoration: InputDecoration(
      labelText: errorText ?? labelText,
      labelStyle: TextStyle(
        color: errorText != null ? TextFieldConstant.primaryErrorColor : TextFieldConstant.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: TextFieldConstant.secondaryFontSize
      ),
      
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: errorText != null ? TextFieldConstant.secondaryErrorColor : TextFieldConstant.secondaryColor,
          width: TextFieldConstant.borderWidth
        )
      ),
      
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: errorText != null ? TextFieldConstant.primaryErrorColor : TextFieldConstant.tertiaryColor,
          width: TextFieldConstant.borderWidth
        )
      ),
    ),
  );
}