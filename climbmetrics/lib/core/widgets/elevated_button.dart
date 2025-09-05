import 'package:flutter/material.dart';

class PrimaryElevatedButton extends StatefulWidget {

  final VoidCallback? onPressed;
  final String text;
  
  const PrimaryElevatedButton({
    super.key,
    required this.onPressed,
    required this.text});

  @override
  State<PrimaryElevatedButton> createState() => _PrimaryElevatedButtonState();
}

class _PrimaryElevatedButtonState extends State<PrimaryElevatedButton> {
  
  TextStyle get _style => TextStyle(
    fontSize: 16
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.onPressed, 
        child: Text(
          widget.text,
          style: _style,
        )
      ),
    );
  }
}