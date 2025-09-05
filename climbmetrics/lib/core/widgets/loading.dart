import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Shimmer shimmerBlock({
  required double height,
  double width = double.infinity,
  double padding = 10
}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: padding),
      height: height,
      width: width,
      color: Colors.white,
    ),
  );
}

Widget greyBlock({
  required double height,
  double width = double.infinity,
  double padding = 10,
  IconData? icon,
  double iconSize = 40
}) {
  Widget greyBlock;

  if (icon != null) {
    greyBlock = Container(
      height: height,
      width: width,
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
        ),
      ),
    );
  } else {
    greyBlock = Container(
      height: height,
      width: width,
      color: Colors.grey.shade300,
    );
  }

  return greyBlock;
}

Widget whiteBlock({
  required BuildContext context,
  required double height,
  double width = double.infinity,
  double padding = 10,
  IconData? icon,
  double iconSize = 40,
  double borderRadius = 10,
  double borderWidth = 5,
  bool hasBorder = false,
}) {
  Widget whiteBlock;

  if (icon != null && hasBorder == false) {
    whiteBlock = Container(
      height: height,
      width: width,
      color: Colors.white,
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
        ),
      ),
    );
  } else if (icon == null && hasBorder == false) {
    whiteBlock = Container(
      height: height,
      width: width,
      color: Colors.white,
    );
  } else if (icon != null && hasBorder == true) {
    whiteBlock = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer,
          width: borderWidth
        )
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
        ),
      ),
    );
  } else {
    whiteBlock = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer,
          width: borderWidth
        )
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
        ),
      ),
    );
  }

  return whiteBlock;
}


