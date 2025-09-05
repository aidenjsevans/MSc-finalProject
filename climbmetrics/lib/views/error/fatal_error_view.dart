import 'package:flutter/material.dart';

class FatalErrorView extends StatelessWidget {
  const FatalErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('A fatal error occured'),
      ),
    );
  }
}