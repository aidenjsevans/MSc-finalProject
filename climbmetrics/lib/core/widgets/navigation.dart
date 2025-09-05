import 'package:climbmetrics/core/utils/constants.dart';
import 'package:flutter/material.dart';

Widget standardNavigation({
  required BuildContext context,
  required String topText,
  required String bottomText,
  required IconData icon,
  required String route,
}) {
  Widget navigation;

  navigation = Stack(
    children: [
      
      Align(
        alignment: Alignment(0,-0.5),
        child: Text(
          topText,
          style: Theme.of(context).textTheme.bodyLarge
        ),
      ),

      Align(
        alignment: Alignment(0,-0.25),
        child: Icon(
          Icons.arrow_downward_rounded,
          size: IconConstant.veryLargeSize,
          color: IconConstant.color,
        ),
      ),

      Align(
        alignment: Alignment(0,0),
        child: Container(
          
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primaryContainer,
            border: Border.all(
              color: IconConstant.borderColor,
              width: IconConstant.borderWidth
            )
          ),
          
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                route, 
                (route) => false
              );
            }, 
            icon: Icon(
              icon,
              size: IconConstant.largeSize,
            )
          ),
        ),
      ),

      Align(
        alignment: Alignment(0,0.25),
        child: Text(
          bottomText,
          style: Theme.of(context).textTheme.bodyLarge
        ),
      ),
    
    ],
  );

  return navigation;
}