import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/utils/generate_id.dart';
import 'package:climbmetrics/core/widgets/loading.dart';
import 'package:climbmetrics/core/widgets/modal_bottom_sheet.dart';
import 'package:climbmetrics/core/widgets/snackbar.dart';
import 'package:climbmetrics/core/widgets/text_field.dart';
import 'package:climbmetrics/core/widgets/title.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_link_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_model.dart';
import 'package:climbmetrics/models/project_library/project_libary_model.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_list_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_list_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_notifier.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:climbmetrics/viewmodels/project_library/project_library_list_notifier.dart';
import 'package:climbmetrics/viewmodels/project_library/project_library_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class BoulderingRouteListTile extends ConsumerStatefulWidget {
  
  final ErrorState boulderingRouteListErrorState;
  final BoulderingRouteModel? boulderingRoute;
  final BoulderingRouteNotifier boulderingRouteNotifier;
  final DatabaseNotifier databaseNotifier;
  final bool isInProjectLibrary;
  final List<ProjectLibraryModel>? projectLibraryList;
  final ProjectLibraryModel? projectLibrary;
  final BoulderingRouteListNotifier? boulderingRouteListNotifier;
  
  const BoulderingRouteListTile({
    super.key,
    required this.boulderingRouteListErrorState,
    this.boulderingRoute,
    required this.boulderingRouteNotifier,
    required this.databaseNotifier,
    required this.isInProjectLibrary,
    this.projectLibraryList,
    this.projectLibrary,
    this.boulderingRouteListNotifier
  });

  @override
  ConsumerState<BoulderingRouteListTile> createState() => _BoulderingRouteListTileState();
}

class _BoulderingRouteListTileState extends ConsumerState<BoulderingRouteListTile> {

  Widget _buildTrailingWidget({
    required BuildContext context,
  }) {
    Widget trailingWidget;

    final List<ProjectLibraryModel>? projectLibraryList = widget.projectLibraryList;
    final BoulderingRouteModel? boulderingRoute = widget.boulderingRoute;
    final DatabaseNotifier databaseNotifier = widget.databaseNotifier;
    final bool isInProjectLibrary = widget.isInProjectLibrary;
    final String routeID = boulderingRoute!.routeID!;
    final ProjectLibraryModel? projectLibrary = widget.projectLibrary;
    final BoulderingRouteListNotifier? boulderingRouteListNotifier = widget.boulderingRouteListNotifier;

    if (isInProjectLibrary) {
      int projectLibraryID = projectLibrary!.projectLibraryID;
      
      trailingWidget = PopupMenuButton(
        key: Key('inProjectLibraryPopupMenuButton$routeID'),
        onSelected: (String value) async {

          if (value == ListTileConstant.deleteMenuValue) {
            
            ErrorState errorState = await databaseNotifier.deleteCurrentProjectLibraryContains(routeID, projectLibraryID);

            if (!context.mounted) {
                return;
            }

            standardSnackBar(
              context: context, 
              nullCheckList: [errorState], 
              successText: 'Bouldering Route Removed', 
              failureText: 'An Error Occurred'
            );

            Future.delayed(Duration(seconds: 1), () {
              boulderingRouteListNotifier!.getProjectBoulderingRouteList(projectLibraryID);
            });
          }

          if (value == ListTileConstant.archiveMenuValue) {
            
            ErrorState errorState = await databaseNotifier.archiveCurrentBoulderingRoute(routeID);

            if (!context.mounted) {
                return;
            }

            standardSnackBar(
              context: context, 
              nullCheckList: [errorState], 
              successText: 'Bouldering Route Archived', 
              failureText: 'An Error Occurred'
            );
          }

        },

        itemBuilder: (context) {
          return [

            PopupMenuItem(
              key: Key('archivePopupMenuItem$routeID'),
              value: ListTileConstant.archiveMenuValue,
              child: Text(
                'Mark Complete',
                style: Theme.of(context).textTheme.bodySmall,
              )
            ),

            PopupMenuItem(
              key: Key('deletePopupMenuItem$routeID'),
              value: ListTileConstant.deleteMenuValue,
              child: Text(
                'Delete',
                style: Theme.of(context).textTheme.bodySmall,
              )
            ),

          ];
        },
        iconSize: IconConstant.mediumSize,
      );
    } else {
      trailingWidget = IconButton(
        key: Key('isNotInProjectLibraryAddIconButton$routeID'),
        onPressed: () {
          insertBoulderingRouteModalBottomSheet(
            context: context, 
            projectLibraryList: projectLibraryList, 
            boulderingRoute: boulderingRoute, 
            databaseNotifier: databaseNotifier
          );
        }, 
        icon: Icon(
          Icons.add,
          size: IconConstant.mediumSize,
        )
      );
    }

    return trailingWidget;
  }

  Widget _buildListTile({
    required BuildContext context,
  }) {
    Widget listTile;
    double width = MediaQuery.of(context).size.width;
    
    ErrorState boulderingRouteListErrorState = widget.boulderingRouteListErrorState;
    BoulderingRouteModel? boulderingRoute = widget.boulderingRoute;
    BoulderingRouteNotifier boulderingRouteNotifier = widget.boulderingRouteNotifier;
    
    if (
      widget.boulderingRouteListErrorState.isNull() && 
      boulderingRoute != null
      ) {
      
      String? routeID = boulderingRoute.routeID;
      String name = boulderingRoute.name;
      String colour = boulderingRoute.colour;
      int grade = boulderingRoute.officialDifficultyRating;

      listTile = Stack(
        children: [
          
          Align(
            alignment: Alignment(-1,-1),
            child: Container(
              height: ListTileConstant.barHeight,
              width: width / 2,

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  
                  topLeft: Radius.circular(ListTileConstant.borderRadius),
                  bottomRight: Radius.circular(ListTileConstant.borderRadius)
                
                ),
                boxShadow: [

                  BoxShadow(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    offset: ListTileConstant.longShadowOffset
                  ),

                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    offset: ListTileConstant.shortShadowOffset
                  )

                ]
              ),

            ),
          ),

          Container(
            height: ListTileConstant.height,
            width: width,
          
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ListTileConstant.borderRadius),
              border: Border.all(
          
                color: Theme.of(context).colorScheme.primaryContainer,
                width: ListTileConstant.borderWidth
          
              ),
            ),
          
            child: ListTile(
              key: Key('boulderingRouteListTile$routeID'),
              contentPadding: EdgeInsets.only(
                top: ListTileConstant.topPadding,
                left: ListTileConstant.padding
              ),
              
              title: Text(
                name,
                style: Theme.of(context).textTheme.titleLarge
              ),
          
              subtitle: Text(
                'Grade: V$grade\nColour: ${title(colour)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          
              onTap: () => boulderingRouteNotifier.selectBoulderingRoute(boulderingRoute),
          
            ),
          ),

          Align(
            alignment: Alignment(1,1),
            child: Padding(
              padding: EdgeInsets.all(ListTileConstant.padding),
              child: _buildTrailingWidget(
                context: context
              )
            ),
          )
        
        ],
      );
    } else if (boulderingRouteListErrorState.isLoading()) {
      listTile = shimmerBlock(
        height: ListTileConstant.height
      );
    } else {
      listTile = whiteBlock(
        context: context,
        height: ListTileConstant.height
      );
    }

    return listTile;
  } 

  @override
  Widget build(BuildContext context) {
    return _buildListTile(
      context: context, 
    );
  }
}


class ProjectLibraryListTile extends ConsumerStatefulWidget {

  final ErrorState projectLibraryListErrorState;
  final ProjectLibraryModel? projectLibrary;
  final ProjectLibraryNotifier projectLibraryNotifier;
  final ProjectLibraryListNotifier projectLibraryListNotifier;
  
  const ProjectLibraryListTile({
    super.key,
    required this.projectLibraryListErrorState,
    required this.projectLibrary,
    required this.projectLibraryNotifier,
    required this.projectLibraryListNotifier,
  });

  @override
  ConsumerState<ProjectLibraryListTile> createState() => _ProjectLibraryListTileState();
}

class _ProjectLibraryListTileState extends ConsumerState<ProjectLibraryListTile> {
  
  Widget _buildListTile({
    required BuildContext context,
  }) {
    Widget listTile;
    double width = MediaQuery.of(context).size.width;

    ErrorState projectLibraryListErrorState = widget.projectLibraryListErrorState;
    ProjectLibraryModel? projectLibrary = widget.projectLibrary;
    ProjectLibraryNotifier projectLibraryNotifier = widget.projectLibraryNotifier;
    ProjectLibraryListNotifier projectLibraryListNotifier = widget.projectLibraryListNotifier;

    if (
      projectLibraryListErrorState.isNull() && 
      projectLibrary != null
      ) {
      
      String name = projectLibrary.name;
      String? date = projectLibrary.date;
      String? tag = projectLibrary.tag ?? '';

      listTile = Stack(
        children: [
          
          Align(
            alignment: Alignment(-1,-1),
            child: Container(
              height: ListTileConstant.barHeight,
              width: width / 2,

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  
                  topLeft: Radius.circular(ListTileConstant.borderRadius),
                  bottomRight: Radius.circular(ListTileConstant.borderRadius)
                
                ),
                boxShadow: [

                  BoxShadow(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    offset: ListTileConstant.longShadowOffset
                  ),

                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    offset: ListTileConstant.shortShadowOffset
                  )

                ]
              ),

            ),
          ),

          Container(
            height: ListTileConstant.height,
            width: width,
          
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ListTileConstant.borderRadius),
              border: Border.all(
          
                color: Theme.of(context).colorScheme.primaryContainer,
                width: ListTileConstant.borderWidth
          
              ),
            ),
          
            child: ListTile(
              key: Key('projectLibraryTile${projectLibrary.projectLibraryID}'),
              contentPadding: EdgeInsets.only(
                top: ListTileConstant.topPadding,
                left: ListTileConstant.padding
              ),
              
              title: Text(
                name,
                style: Theme.of(context).textTheme.titleMedium
              ),
          
              subtitle: Text(
                'Created: $date\nTag: $tag',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          
              onTap: () => projectLibraryNotifier.selectCurrentProjectLibrary(projectLibrary)
          
            ),
          ),

          Align(
            alignment: Alignment(1,1),
            child: Padding(
              padding: EdgeInsets.all(ListTileConstant.padding),
              child: PopupMenuButton(
                key: Key('projectLibraryListTilePopupMenuButton${projectLibrary.projectLibraryID}'),
                onSelected: (String value) async {

                  if (value == ListTileConstant.deleteMenuValue) {
                      
                    ErrorState errorState = await projectLibraryListNotifier.deleteCurrentProjectLibrary(projectLibrary.projectLibraryID);

                    if (!context.mounted) {
                        return;
                    }

                    standardSnackBar(
                      context: context, 
                      nullCheckList: [errorState], 
                      successText: 'Project Library Removed', 
                      failureText: 'An Error Occurred'
                    );

                    Future.delayed(Duration(milliseconds: 500), () {
                        projectLibraryListNotifier.getCurrentProjectLibraryList();
                    });
                  }
                },

                itemBuilder: (context) {
                  return [

                    PopupMenuItem(
                      key: Key('projectLibraryListTileDeletePopupMenuItem${projectLibrary.projectLibraryID}'),
                      value: ListTileConstant.deleteMenuValue,
                      child: Text(
                        'Delete',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ),

                  ];
                },
                iconSize: IconConstant.mediumSize,
              ),
            ),
          )
        
        ],
      );
    } else if (projectLibraryListErrorState.isLoading()) {
      listTile = shimmerBlock(
        height: ListTileConstant.height
      );
    } else {
      listTile = whiteBlock(
        context: context,
        height: ListTileConstant.height
      );
    }

    return listTile;
  }
  
  @override
  Widget build(BuildContext context) {

    return _buildListTile(
      context: context, 
    );
  }
}


class CreateProjectLibraryListTile extends ConsumerStatefulWidget {

  final ProjectLibraryListNotifier projectLibraryListNotifier;
  
  const CreateProjectLibraryListTile({
    super.key,
    required this.projectLibraryListNotifier
  });

  @override
  ConsumerState<CreateProjectLibraryListTile> createState() => _CreateProjectLibraryListTileState();
}

class _CreateProjectLibraryListTileState extends ConsumerState<CreateProjectLibraryListTile> {
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  String? nameErrorText;

  Future<dynamic> _modalBottomSheet({
    required BuildContext context,
    required ProjectLibraryListNotifier projectLibraryListNotifier,
  }) {
    double height = MediaQuery.of(context).size.height;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        String? localNameErrorText = nameErrorText;
        return StatefulBuilder(
          builder: (context, modalState) {
            return SizedBox(
              height: height * 0.75,
              child: Column(
                children: [
                  
                  Padding(
                    padding: EdgeInsets.only(bottom: ModalSheetConstant.paddingLarge),
                    child: standardTitleWidget(
                      context: context, 
                      title: 'Add Project Library', 
                      hasAlertDialog: false,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: ModalSheetConstant.paddingLarge),
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      child: standardTextField(
                        key: Key('projectNameTextField'),
                        controller: _nameController, 
                        errorText: localNameErrorText, 
                        labelText: 'Project Name'
                      )
                    )
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: ModalSheetConstant.paddingLarge),
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      child: standardTextField(
                        key: Key('projectTagTextField'),
                        controller: _tagController, 
                        errorText: null, 
                        labelText: 'Tag'
                      )
                    )
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: ModalSheetConstant.paddingLarge),
                    child: Container(
                      
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        border: Border.all(
                          width: IconConstant.borderWidth,
                          color: IconConstant.borderColor
                        ),
                        shape: BoxShape.circle
                      ),
                      
                      child: IconButton(
                        key: Key('projectLibrarySubmitButton'),
                        onPressed: () async {
                          
                          final String name = _nameController.text.trim();
                          final String? tag = _tagController.text.trim().isEmpty ? null : _tagController.text.trim();

                          if (name.isEmpty) {
                            modalState(() {
                              localNameErrorText = 'Empty entry';
                            });
                            
                            return;
                          }
                          
                          ErrorState projectLibraryListNotifierState = await projectLibraryListNotifier.insertCurrentProjectLibrary(name, tag);
                          await projectLibraryListNotifier.getCurrentProjectLibraryList();

                          if (!context.mounted) {
                            return;
                          }

                          standardSnackBar(
                            context: context, 
                            nullCheckList: [projectLibraryListNotifierState], 
                            successText: 'Project Library Added', 
                            failureText: SnackBarConstant.failureText
                          );

                          _nameController.clear();
                          _tagController.clear();
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.add,
                          size: IconConstant.mediumSize,
                        )
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  } 

  Widget _buildListTile({
    required BuildContext context,
  }) {
    Widget listTile;
    double width = MediaQuery.of(context).size.width;

    ProjectLibraryListNotifier projectLibraryListNotifier = widget.projectLibraryListNotifier;

    listTile = Stack(
      children: [
        
        Align(
          alignment: Alignment(0,0),
          child: Padding(
            padding: EdgeInsets.all(ListTileConstant.height / 3),
            child: Icon(
              Icons.add,
              size: IconConstant.mediumSize
            )
          ),
        ),

        Align(
          alignment: Alignment(-1,-1),
          child: Container(
            height: ListTileConstant.barHeight,
            width: width / 2,

            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.only(
                
                topLeft: Radius.circular(ListTileConstant.borderRadius),
                bottomRight: Radius.circular(ListTileConstant.borderRadius)
              
              ),
              boxShadow: [

                BoxShadow(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  offset: ListTileConstant.longShadowOffset
                ),

                BoxShadow(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  offset: ListTileConstant.shortShadowOffset
                )

              ]
            ),

          ),
        ),

        Container(
            height: ListTileConstant.height,
            width: width,
          
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ListTileConstant.borderRadius),
              border: Border.all(
          
                color: Theme.of(context).colorScheme.primaryContainer,
                width: ListTileConstant.borderWidth
          
              ),
            ),
          
            child: ListTile(
              key: Key('createProjectLibraryListTile'),

              onTap: () {
                _modalBottomSheet(
                  context: context, 
                  projectLibraryListNotifier: projectLibraryListNotifier
                );
              }

            ),
          ),

        
      
      ],
    );

    return listTile;
  }

  @override
  Widget build(BuildContext context) {
    return _buildListTile(
      context: context
    );
  }
}


class BoulderingWallLinkListTile extends ConsumerStatefulWidget {

  final ErrorState boulderingWallLinkListErrorState;
  final BoulderingWallLinkModel? boulderingWallLink;
  final BoulderingWallLinkNotifier boulderingWallLinkNotifier;
  final DatabaseNotifier databaseNotifier;
  final BoulderingWallLinkListNotifier boulderingWallLinkListNotifier;
  
  const BoulderingWallLinkListTile({
    super.key,
    required this.boulderingWallLinkListErrorState,
    required this.boulderingWallLink,
    required this.boulderingWallLinkNotifier,
    required this.databaseNotifier,
    required this.boulderingWallLinkListNotifier
  });

  @override
  ConsumerState<BoulderingWallLinkListTile> createState() => _BoulderingWallListTileState();
}

class _BoulderingWallListTileState extends ConsumerState<BoulderingWallLinkListTile> {

  
   Widget _buildListTile({
    required BuildContext context,
  }) {
    Widget listTile;
    double width = MediaQuery.of(context).size.width;

    ErrorState boulderingWallLinkListErrorState = widget.boulderingWallLinkListErrorState;
    BoulderingWallLinkModel? boulderingWallLink = widget.boulderingWallLink;
    BoulderingWallLinkNotifier boulderingWallLinkNotifier = widget.boulderingWallLinkNotifier;
    BoulderingWallLinkListNotifier boulderingWallLinkListNotifier = widget.boulderingWallLinkListNotifier;

    if (
      boulderingWallLinkListErrorState.isNull() && 
      boulderingWallLink != null
      ) {
      
      String boulderingWallID = boulderingWallLink.boulderingWallID;
      String displayName = boulderingWallLink.displayName;
      String city = boulderingWallLink.city;
      String postcode = boulderingWallLink.postcode;
      String street = boulderingWallLink.street;
      String address = '$street, $city, $postcode';

      listTile = Stack(
        children: [
          
          Align(
            alignment: Alignment(-1,-1),
            child: Container(
              height: ListTileConstant.barHeight,
              width: width / 2,

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  
                  topLeft: Radius.circular(ListTileConstant.borderRadius),
                  bottomRight: Radius.circular(ListTileConstant.borderRadius)
                
                ),
                boxShadow: [

                  BoxShadow(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    offset: ListTileConstant.longShadowOffset
                  ),

                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    offset: ListTileConstant.shortShadowOffset
                  )

                ]
              ),

            ),
          ),

          Container(
            height: ListTileConstant.height,
            width: width,
          
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ListTileConstant.borderRadius),
              border: Border.all(
          
                color: Theme.of(context).colorScheme.primaryContainer,
                width: ListTileConstant.borderWidth
          
              ),
            ),
          
            child: ListTile(
              key: Key('boulderingWallListTile$boulderingWallID'),
              contentPadding: EdgeInsets.only(
                top: ListTileConstant.topPadding,
                left: ListTileConstant.padding
              ),
              
              title: Text(
                displayName,
                style: Theme.of(context).textTheme.titleMedium
              ),
          
              subtitle: Text(
                address,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          
              onTap: () => boulderingWallLinkNotifier.selectBoulderingWallLink(boulderingWallLink)
          
            ),
          ),

          Align(
            alignment: Alignment(1,1),
            child: Padding(
              padding: EdgeInsets.all(ListTileConstant.padding),
              child: PopupMenuButton(
                key: Key('boulderingWallListTilePopupMenuButton$boulderingWallID'),
                onSelected: (String value) async {

                  if (value == ListTileConstant.deleteMenuValue) {
                      
                    ErrorState errorState = await boulderingWallLinkListNotifier.deleteCurrentBoulderingWallLink(boulderingWallID);

                    if (!context.mounted) {
                        return;
                    }

                    standardSnackBar(
                      context: context, 
                      nullCheckList: [errorState], 
                      successText: 'Bouldering Wall Link Removed', 
                      failureText: SnackBarConstant.failureText
                    );

                    Future.delayed(ListTileConstant.getDelay, () {
                        boulderingWallLinkListNotifier.getCurrentBoulderingWallLinkList();
                    });
                  }
                },

                itemBuilder: (context) {
                  return [

                    PopupMenuItem(
                      key: Key('boulderingWallListTileDeletePopupMenuItem$boulderingWallID'),
                      value: ListTileConstant.deleteMenuValue,
                      child: Text(
                        'Delete',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ),

                  ];
                },
                iconSize: IconConstant.mediumSize,
              ),
            ),
          )
        
        ],
      );
    } else if (boulderingWallLinkListErrorState.isLoading()) {
      listTile = shimmerBlock(
        height: ListTileConstant.height
      );
    } else {
      listTile = whiteBlock(
        context: context,
        height: ListTileConstant.height
      );
    }

    return listTile;
  }
  
  @override
  Widget build(BuildContext context) {
    
    return _buildListTile(context: context);
  }
}


class BoulderingWallSearchListTile extends ConsumerStatefulWidget {
  
  final BoulderingWallLinkListNotifier boulderingWallLinkListNotifier;
  final String? displayName;
  final Map<String,bool>? isLinkedMap;
  final ErrorState boulderingWallSearchErrorState;
  final BoulderingWallModel? boulderingWall;

  const BoulderingWallSearchListTile({
    super.key,
    required this.boulderingWallLinkListNotifier,
    required this.displayName,
    required this.isLinkedMap,
    required this.boulderingWallSearchErrorState,
    required this.boulderingWall
  });

  @override
  ConsumerState<BoulderingWallSearchListTile> createState() => _BoulderingWallSearchListTileState();
}

class _BoulderingWallSearchListTileState extends ConsumerState<BoulderingWallSearchListTile> {
  
   Widget _buildTrailingWidget({
    required BuildContext context,
  }) {
    Widget trailingWidget;

    final BoulderingWallLinkListNotifier boulderingWallLinkListNotifier = widget.boulderingWallLinkListNotifier;
    final BoulderingWallModel? boulderingWall = widget.boulderingWall;
    final String? displayName = widget.displayName;
    final Map<String,bool>? isLinkedMap = widget.isLinkedMap;
    final bool isLinked;

    if (isLinkedMap == null || boulderingWall == null) {
      isLinked = false;
    } else {
      String boulderingWallID = boulderingWall.boulderingWallID!;
      isLinked = isLinkedMap[boulderingWallID] == true ? true : false;
    }

    if (
    !isLinked &&
    boulderingWall != null
    ) {
      
      final String boulderingWallID = boulderingWall.boulderingWallID!;
      final String city = boulderingWall.city;
      final String postcode = boulderingWall.postcode;
      final String street = boulderingWall.street;

      trailingWidget = IconButton(
        key: Key('addBoulderingWallButton$boulderingWallID'),
        onPressed: () async {

          ErrorState insertErrorState = await boulderingWallLinkListNotifier.insertCurrentBoulderingWallLink(
            boulderingWallID, 
            displayName!, 
            city, 
            postcode, 
            street
          );

          await boulderingWallLinkListNotifier.getCurrentBoulderingWallLinkList();

          if (!context.mounted) {
            return;
          }

          standardSnackBar(
            context: context, 
            nullCheckList: [insertErrorState], 
            successText: 'Bouldering Wall Added', 
            failureText: 'An Error Occurred'
          );

          if (insertErrorState.isNull()) {
            Navigator.of(context).pop();
          }               
        }, 
        icon: Icon(
          Icons.add_rounded,
          size: IconConstant.mediumSize
        )
      );
    } else {
      trailingWidget = Icon(
        Icons.check_rounded,
        size: IconConstant.mediumSize,
      );
    }

    return trailingWidget;
  }

  Widget _buildListTile({
    required BuildContext context,
  }) {
    Widget listTile;
    double width = MediaQuery.of(context).size.width;
    
    final String? displayName = widget.displayName;
    final Map<String,bool>? isLinkedMap = widget.isLinkedMap;
    final ErrorState boulderingWallSearchErrorState = widget.boulderingWallSearchErrorState;
    final BoulderingWallModel? boulderingWall = widget.boulderingWall;

    if (
      boulderingWallSearchErrorState.isNull() && 
      boulderingWall != null &&
      displayName != null &&
      isLinkedMap != null
      ) {
      
      String boulderingWallID = boulderingWall.boulderingWallID!;
      String city = boulderingWall.city;
      String postcode = boulderingWall.postcode;
      String street = boulderingWall.street;
      String address = '$street, $city, $postcode';


      listTile = Stack(
        children: [
          
          Align(
            alignment: Alignment(-1,-1),
            child: Container(
              height: ListTileConstant.barHeight,
              width: width / 2,

              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  
                  topLeft: Radius.circular(ListTileConstant.borderRadius),
                  bottomRight: Radius.circular(ListTileConstant.borderRadius)
                
                ),
                boxShadow: [

                  BoxShadow(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    offset: ListTileConstant.longShadowOffset
                  ),

                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    offset: ListTileConstant.shortShadowOffset
                  )

                ]
              ),

            ),
          ),

          Container(
            height: ListTileConstant.height,
            width: width,
          
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ListTileConstant.borderRadius),
              border: Border.all(
          
                color: Theme.of(context).colorScheme.primaryContainer,
                width: ListTileConstant.borderWidth
          
              ),
            ),
          
            child: ListTile(
              key: Key('boulderingWallListTile$boulderingWallID'),
              contentPadding: EdgeInsets.only(
                top: ListTileConstant.topPadding,
                left: ListTileConstant.padding
              ),
              
              title: Text(
                key: Key('boulderingWallCompanyDisplayName'),
                displayName,
                style: Theme.of(context).textTheme.titleLarge
              ),
          
              subtitle: Text(
                key: Key('boulderingWallAddress'),
                address,
                style: Theme.of(context).textTheme.bodySmall,
              ),   
            ),
          ),

          Align(
            alignment: Alignment(1,1),
            child: Padding(
              padding: EdgeInsets.all(ListTileConstant.padding),
              child: _buildTrailingWidget(
                context: context, 
              )
            ),
          )
        
        ],
      );
    } else if (boulderingWallSearchErrorState.isLoading()) {
      listTile = shimmerBlock(
        height: ListTileConstant.height
      );
    } else {
      listTile = whiteBlock(
        context: context,
        height: ListTileConstant.height
      );
    }

    return listTile;
  } 
  
  @override
  Widget build(BuildContext context) {
    return _buildListTile(
      context: context
    );
  }
}