import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/widgets/snackbar.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/models/project_library/project_libary_model.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:flutter/material.dart';

Widget insertBoulderingRouteIconButton({
  required BuildContext context,
  required DatabaseNotifier databaseNotifier,
  required BoulderingRouteModel? boulderingRoute,
  required ProjectLibraryModel? projectLibrary,
}) {
  
  Widget iconButton;

  if (boulderingRoute != null && projectLibrary != null) {

    String routeID = boulderingRoute.routeID!;
    int projectLibraryID = projectLibrary.projectLibraryID;
    
    iconButton = IconButton(
      key: Key('insertBoulderingRouteIconButton$projectLibraryID'),
      onPressed: () async {
        
        ErrorState insertBoulderingRouteErrorState = await databaseNotifier.insertBoulderingRoute(boulderingRoute);
        ErrorState insertProjectLibraryErrorState = await databaseNotifier.insertCurrentProjectLibraryContains(routeID,projectLibraryID);

        if (!context.mounted) {
          return;
        }

        final nullCheckList = [
          insertBoulderingRouteErrorState, 
          insertProjectLibraryErrorState
          ];

        standardSnackBar(
          context: context, 
          nullCheckList: nullCheckList, 
          successText: 'Bouldering route added', 
          failureText: SnackBarConstant.failureText
        );

        Navigator.of(context).pop();
      }, 
      icon: Icon(
        Icons.add,
        size: IconConstant.mediumSize,
      )
    );
  } else {
    iconButton = SizedBox(
      height: IconConstant.mediumSize,
      width: IconConstant.mediumSize,
    );
  }
  
  return iconButton;
}

