import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/widgets/icon_button.dart';
import 'package:climbmetrics/core/widgets/navigation.dart';
import 'package:climbmetrics/core/widgets/title.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/models/project_library/project_libary_model.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:flutter/material.dart';

Future<dynamic> insertBoulderingRouteModalBottomSheet({

    required BuildContext context,
    required List<ProjectLibraryModel>? projectLibraryList,
    required BoulderingRouteModel? boulderingRoute,
    required DatabaseNotifier databaseNotifier,
    double heightFactor = 0.9,
    double widthFactor = 0.8,
  }) {
    Widget projectLibraryDisplay;
    double height = MediaQuery.of(context).copyWith().size.height;

    if (projectLibraryList == null) {

      projectLibraryDisplay = Padding(
        padding: EdgeInsets.only(top: ModalSheetConstant.padding),
        child: standardNavigation(
          context: context, 
          topText: "You haven't created a library yet", 
          bottomText: 'Tap the icon to get started', 
          icon: Icons.folder_rounded, 
          route: projectLibraryListRoute
        ),
      );

    } else {
      projectLibraryDisplay = FractionallySizedBox(
        
        widthFactor: heightFactor,
        heightFactor: widthFactor,
        
        child: ListView(
          children: [
            
            for (final projectLibrary in projectLibraryList)
            
            Padding(
              padding: EdgeInsets.symmetric(vertical: ModalSheetConstant.padding),
              child: Container(
                height: ModalSheetConstant.projectLibraryHeight,
                
                decoration: BoxDecoration(
                  
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(ModalSheetConstant.leftBorderRadius),
                    bottomLeft: Radius.circular(ModalSheetConstant.leftBorderRadius),
                    topRight: Radius.circular(ModalSheetConstant.rightBorderRadius),
                    bottomRight: Radius.circular(ModalSheetConstant.rightBorderRadius)
                  ),
                  
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    width: IconConstant.borderWidth
                  ),
                ),
                child: Stack(
                  children: [
                    
                    Align(
                      alignment: Alignment(-0.9,0),
                      child: Text(
                        projectLibrary.name,
                        style: Theme.of(context).textTheme.titleLarge
                      ),
                    ),
                    
                    Align(
                      alignment: Alignment(0.95,0),
                      child: insertBoulderingRouteIconButton(
                        context: context, 
                        databaseNotifier: databaseNotifier, 
                        boulderingRoute: boulderingRoute, 
                        projectLibrary: projectLibrary
                      )
                    ),
                  ],
                )
              ),
            )
          ],
        ),
      );
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: height * 0.75,
          child: Stack(
            children: [
          
              FractionallySizedBox(
                widthFactor: 1,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(ModalSheetConstant.borderRadius),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      width: ModalSheetConstant.borderWidth
                    )
                  ),
                ),
              ),

              Align(
                alignment: Alignment(0,1),
                child: projectLibraryDisplay
              ),
          
              SizedBox(
                height: TitleWidgetConstant.height,
                child: Padding(
                  padding: EdgeInsets.only(bottom: ModalSheetConstant.padding),
                  child: standardTitleWidget(
                    context: context, 
                    title: 'Add Project', 
                    hasAlertDialog: false
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

