import 'package:flutter/material.dart';

class PrimaryTextButton extends StatefulWidget {

  final VoidCallback onPressed;
  final String text;
  
  const PrimaryTextButton({
    super.key,
    required this.onPressed,
    required this.text});

  @override
  State<PrimaryTextButton> createState() => _PrimaryTextButtonState();
}

class _PrimaryTextButtonState extends State<PrimaryTextButton> {

    TextStyle get _style => TextStyle(
    fontSize: 16
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 25.0
      ),
      child: TextButton(
        onPressed: widget.onPressed, 
        child: Text(
          widget.text,
          style: _style,
        )
      ),
    );
  }
}