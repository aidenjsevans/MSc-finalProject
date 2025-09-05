import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:flutter/material.dart';

  ScaffoldFeatureController standardSnackBar({
    required BuildContext context,
    required List<ErrorState> nullCheckList,
    required String successText,
    required String failureText,
  }) {
    Widget snackBarContent;
    bool isSuccess = true;
    Key key;

    for (ErrorState errorState in nullCheckList) {
      if (errorState.isNotNull()) {
        isSuccess = false;
      }
    }

    if (isSuccess) {
      key = Key('successSnackBar');
      snackBarContent = Text(
        successText,
        style: Theme.of(context).textTheme.titleMedium
      );
    } else {
      key = Key('failureSnackBar');
      snackBarContent = Text(
        failureText,
        style: Theme.of(context).textTheme.titleMedium
      );
    }

    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: key,
        content: snackBarContent,
        backgroundColor: isSuccess ? SnackBarConstant.successColour: SnackBarConstant.failureColour,
        duration: SnackBarConstant.duration,
      )
    );
  }