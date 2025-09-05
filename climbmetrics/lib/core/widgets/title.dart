import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/widgets/alert_dialog.dart';
import 'package:flutter/material.dart';

Widget standardTitleWidget({
    required BuildContext context,
    required String title,
    required bool hasAlertDialog,
    bool circularTop = true,
    Key? key,
    String? titleText,
    String? content,
    String? closeText,
  }) {
    Widget titleWidget;
    double width = MediaQuery.of(context).size.width;

    if (hasAlertDialog) {
      titleWidget = Container(
        width: width,
        
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.only(
            topLeft:  Radius.circular(circularTop == true ? TitleWidgetConstant.borderRadius : 0),
            topRight: Radius.circular(circularTop == true ? TitleWidgetConstant.borderRadius : 0)
          )
        ),
        
        child: Padding(
          padding: EdgeInsets.all(TitleWidgetConstant.padding),
          child: Stack(
            children: [
              
              Align(
                alignment: Alignment(1,0),
                child: IconButton(
                  onPressed: () {
                    standardAlertDialog(
                      context: context, 
                      titleText: titleText ?? '', 
                      content: content ?? '', 
                      closeText: closeText ?? 'Ok'
                    );
                  }, 
                  icon: Icon(
                    Icons.help_rounded,
                    size: IconConstant.mediumSize
                  )
                )
              ),
              
              Align(
                alignment: Alignment(-1,0),
                child: Text(
                  key: key,
                  title,
                  style: Theme.of(context).textTheme.titleLarge
                ),
              ),

            ],
          ),
        ),
      );
    } else {
      titleWidget = Container(
        width: width,
        
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(circularTop == true ? TitleWidgetConstant.borderRadius : 0),
            topRight: Radius.circular(circularTop == true ? TitleWidgetConstant.borderRadius : 0)
          )
        ),
        child: Padding(
          padding: EdgeInsets.all(TitleWidgetConstant.padding),
          child: Stack(
            children: [
        
              Align(
                alignment: Alignment(-1,0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge
                ),
              ),

            ],
          ),
        ),
      );
    }
    
    return titleWidget;
  }