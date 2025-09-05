import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/utils/generate_id.dart';
import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/core/utils/observers.dart';
import 'package:climbmetrics/core/widgets/app_bar.dart';
import 'package:climbmetrics/core/widgets/list_tile.dart';
import 'package:climbmetrics/core/widgets/loading.dart';
import 'package:climbmetrics/core/widgets/title.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_facilities_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_model.dart';
import 'package:climbmetrics/models/project_library/project_libary_model.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_provider.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_provider.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:climbmetrics/viewmodels/database/database_provider.dart';
import 'package:climbmetrics/viewmodels/project_library/project_library_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class BoulderingWallView extends ConsumerStatefulWidget {
  const BoulderingWallView({super.key});

  @override
  ConsumerState<BoulderingWallView> createState() => _BoulderingWallViewState();
}

class _BoulderingWallViewState extends ConsumerState<BoulderingWallView> with RouteAware {

  late final ProviderSubscription<(ErrorState,BoulderingRouteModel?)> boulderingRouteSubscription;
  late final ProviderSubscription<dynamic> authSubscription;

  @override
  void initState() {
    super.initState();

    final authStateCheck = StateCheck.auth();
    authSubscription = authStateCheck.check(
      context: context, 
      ref: ref
    );

    boulderingRouteSubscription = ref.listenManual(
      boulderingRouteNotifierProvider, 
      (previous, next) {
        final(
          ErrorState nextRouteErrorState,
          BoulderingRouteModel? nextBoulderingRoute
          ) = next;

        if (nextRouteErrorState.isSelected() && nextBoulderingRoute != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamed(boulderingRouteRoute);
          });          
        }
      }
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final boulderingWallLink = ref.read(boulderingWallLinkNotifierProvider);
      final String boulderingWallID = boulderingWallLink!.boulderingWallID;
      
      final projectLibraryListNotifier = ref.read(projectLibraryListNotifierProvider.notifier);
      projectLibraryListNotifier.getCurrentProjectLibraryList();

      final boulderingRouteListNotifier = ref.read(boulderingRouteListNotifierProvider.notifier);
      boulderingRouteListNotifier.fetchBoulderingRouteListByBoulderingWallID(boulderingWallID);

      final boulderingWallNotifier = ref.read(boulderingWallNotifierProvider.notifier);
      boulderingWallNotifier.fetchBoulderingWallByBoulderingWallID(boulderingWallID);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
    boulderingRouteSubscription.close();
  }

  @override
  void didPop() {
    final boulderingWallNotifier = ref.read(boulderingWallNotifierProvider.notifier);
    boulderingWallNotifier.reset();
  }

/// Builds a trailing [Widget] that, upon being pressed, will show a modal bottom sheet. This
/// modal bottom sheet allows a user to add a [BoulderingRouteModel] to a project library
/// 
/// Returns a [Widget]. If the user has no project libraries, the returned [Widget] is null
  Widget? buildTrailingWidget(
    BuildContext context,
    ErrorState projectLibraryListErrorState, 
    List<ProjectLibraryModel>? projectLibraryList,
    BoulderingRouteModel boulderingRoute,
    DatabaseNotifier databaseNotifier) {
      if (projectLibraryList == null) {
        return null;
      }
      Widget trailing = IconButton(
        onPressed: () {
          showModalBottomSheet(
            context: context, 
            builder: (context) {
              return ListView.builder(
                itemCount: projectLibraryList.length,
                itemBuilder: (context, index) {
                  final projectLibrary = projectLibraryList[index];
                  return ListTile(
                    leading: Icon(Icons.folder_copy_rounded),
                    title: Text(projectLibrary.name),
                    trailing: IconButton(
                      onPressed: () async {
                        ErrorState routeErrorState = await databaseNotifier.insertBoulderingRoute(boulderingRoute);
                        if (routeErrorState.isNull()) {
                          await databaseNotifier.insertCurrentProjectLibraryContains(
                            boulderingRoute.routeID!, 
                            projectLibrary.projectLibraryID
                          );
                        }
                      },
                      icon: Icon(Icons.add)
                    ),
                  );
                }
              );
            }
          );
        },
        icon: Icon(Icons.add),   
      );
      return trailing;
    }

/// Builds a tile containing a piece of bouldering wall information
/// 
/// Returns a [Widget]
  Widget buildInfoTile({
    required ErrorState boulderingWallErrorState,
    required String titleText,
    required String text,
    double borderRadius = 5,
    double padding = 5,
  }) {
    Widget infoTile;
    double width = MediaQuery.of(context).size.width;
    
    if (boulderingWallErrorState.isNull()) {
      infoTile = Column(
        children: [
          
          Align(
            alignment: Alignment(-1,0),
            child: Container(
              
              width: width / 2,
              
              decoration: BoxDecoration(
                
                color: Theme.of(context).colorScheme.primaryContainer,
                
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(borderRadius),
                  ),
                boxShadow: [
                  
                  BoxShadow(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    offset: Offset(35, 0)
                  ),
                  
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    offset: Offset(15, 0)
                  ),
                ]
              ),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Text(
                  titleText,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),

          Container(
            width: width,
            decoration: BoxDecoration(
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        ],
      );
    } else if (boulderingWallErrorState.isLoading()) {
      infoTile = shimmerBlock(
        height: 100
      );
    } else {
      infoTile = whiteBlock(
        context: context, 
        height: 100
      );
    }

    return infoTile;
  }

/// Builds a a description set by a bouldering wall
/// 
/// Returns a [Widget]
  Widget buildDescriptionTile({
    required ErrorState boulderingWallErrorState,
    required String? displayName,
    required BoulderingWallModel? boulderingWall,
    double borderRadius = 10,
    double borderWidth = 5,
    double padding = 10,
  }) {
    
    Widget descriptionTile;
    double width = MediaQuery.of(context).size.width;

    if (
    boulderingWallErrorState.isNull() && 
    displayName != null && 
    boulderingWall != null
    ) {
      
      String text = boulderingWall.description;

      descriptionTile = Container(
      width: width,
      
      decoration: BoxDecoration(
        
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius)
        ),
        
        border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer,
          width: borderWidth
        )
      ),
      child: Column(
        children: [
          
          SizedBox(
            width: width,
            
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  } else if (boulderingWallErrorState.isLoading()) {
    descriptionTile = shimmerBlock(
      height: 300
    );
  } else {
    descriptionTile = whiteBlock(
      context: context, 
      height: 300
    );
  }
  
  return descriptionTile; 
  }

/// Builds a [Column] of the bouldering wall information
/// 
/// Returns a [Widget]
  Widget buildBasicInformation({
    required BuildContext context,
    required ErrorState boulderingWallErrorState,
    required BoulderingWallModel? boulderingWall,
    double borderRadius = 10,
    double borderWidth = 5,
  }) {
    
    Widget basicInformation;
    double width = MediaQuery.of(context).size.width;

    if (boulderingWall != null) {
      
      String email = boulderingWall.email;
      String phone = boulderingWall.phone;
      String city = title(boulderingWall.city);
      String street = boulderingWall.street;
      String postcode = boulderingWall.postcode;
      String address = '$street, $city, $postcode';

      basicInformation = Container(
        
        width: width,
        
        decoration: BoxDecoration(
          
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(borderRadius),
            bottomRight: Radius.circular(borderRadius)
          ),
          
          border: Border.all(
            color: Theme.of(context).colorScheme.primaryContainer,
            width: borderWidth
          )
        ),
        child: Column(
          children: [

            SizedBox(
              width: width,
              child: Column(
                children: [
                  
                  buildInfoTile(
                    boulderingWallErrorState: boulderingWallErrorState,
                    titleText: 'Email', 
                    text: email
                  ),
                  
                  buildInfoTile(
                    boulderingWallErrorState: boulderingWallErrorState,
                    titleText: 'Phone', 
                    text: phone
                  ),
                  
                  buildInfoTile(
                    boulderingWallErrorState: boulderingWallErrorState,
                    titleText: 'Address', 
                    text: address
                  ),
              
                ],
              ),
            ),
          ],
        ),
      );
    } else if (boulderingWallErrorState.isLoading()) {
      basicInformation = shimmerBlock(
        height: 500
      );
    } else {
      basicInformation = whiteBlock(
        context: context, 
        height: 500
      );
    }

    return basicInformation;
  }

/// Builds the body [Widget]
/// 
/// Returns a [Widget]
  Widget buildBody({
    required BuildContext context,
    required ErrorState boulderingWallErrorState,
    required String? displayName,
    required BoulderingWallModel? boulderingWall,
    required ErrorState boulderingRouteListErrorState,
    required List<BoulderingRouteModel>? boulderingRouteList,
    required BoulderingRouteNotifier boulderingRouteNotifier,
    required List<ProjectLibraryModel>? projectLibraryList,
    required DatabaseNotifier databaseNotifier,
    double padding = 10
  }) {
    Widget body;
    double height = MediaQuery.of(context).size.height;

    if (
    boulderingRouteListErrorState.isNull() &&
    boulderingRouteList != null
    ) {
      body = ListView(
        key: Key('boulderingWallListView'),
        children: [

          Padding(
            padding: EdgeInsets.only(top: padding),
            child: standardTitleWidget(
              context: context, 
              title: 'Wall Information', 
              hasAlertDialog: false,
              circularTop: false
            ),
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: buildBasicInformation(
              context: context, 
              boulderingWall: boulderingWall,
              boulderingWallErrorState: boulderingWallErrorState
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: padding),
            child: standardTitleWidget(
              context: context, 
              title: 'Facilities', 
              hasAlertDialog: false
            ),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: buildFacilitiesTile(
              boulderingWallErrorState: boulderingWallErrorState,
              displayName: displayName,
              boulderingWall: boulderingWall
            ),  
          ),

          Padding(
            padding: EdgeInsets.only(top: padding),
            child: standardTitleWidget(
              context: context, 
              title: 'About Us', 
              hasAlertDialog: false
            ),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: buildDescriptionTile(
              boulderingWallErrorState: boulderingWallErrorState,
              displayName: displayName,
              boulderingWall: boulderingWall
            ),  
          ),

          Padding(
            padding: EdgeInsets.only(top: padding),
            child: standardTitleWidget(
              context: context, 
              title: 'Bouldering Routes', 
              hasAlertDialog: false,
              circularTop: false
            ),
          ),

          for (final boulderingRoute in boulderingRouteList)

          Padding(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: BoulderingRouteListTile(
              boulderingRouteListErrorState: boulderingRouteListErrorState, 
              boulderingRouteNotifier: boulderingRouteNotifier, 
              databaseNotifier: databaseNotifier,
              boulderingRoute: boulderingRoute,
              isInProjectLibrary: false,
              projectLibraryList: projectLibraryList,
            )
          )
          
        ],
      );
    } else {
      body = Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: height / 3,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0)
          ),
        ),
      );
    }
    
    return body;
  }

/// Builds a [Column] indicating the availabe
/// 
/// Returns a [Widget]
  Widget buildFacilitiesTile({
    required ErrorState boulderingWallErrorState,
    required String? displayName,
    required BoulderingWallModel? boulderingWall,
    double borderRadius = 10,
    double borderWidth = 5,
    double padding = 10,
    double iconSize = 40,
  }) {
    Widget facilitiesTile;

    if (
      boulderingWall != null &&
      boulderingWallErrorState.isNull() &&
      displayName != null
      ) {
      final BoulderingWallFacilitiesModel facilities = boulderingWall.facilities;

      facilitiesTile = Container(
        
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(borderRadius),
            bottomRight: Radius.circular(borderRadius),
          ),
          
          border: Border.all(
            color: Theme.of(context).colorScheme.primaryContainer,
            width: borderWidth
          )
        ),
        child: Column(
          children: [
            
            Padding(
              padding: EdgeInsets.all(padding),
              child: Stack(
                children: [
                  
                  Align(
                    alignment: Alignment(-0.6,0),
                    child: Text(
                      'Toilet',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ),
              
                  Align(
                    alignment: Alignment(-1,0),
                    child: Icon(
                      Icons.wc_rounded,
                      size: iconSize,
                    ),
                  ),
              
                  Align(
                    alignment: Alignment(0,0),
                    child: facilities.hasToilet ?   
                    Icon(Icons.check, size: iconSize, color: Colors.green) : 
                    Icon(Icons.close, size: iconSize, color: Colors.red)
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(padding),
              child: Stack(
                children: [
                 
                  Align(
                    alignment: Alignment(-0.6,0),
                    child: Text(
                      'Shower',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ),
              
                  Align(
                    alignment: Alignment(-1,0),
                    child: Icon(
                      Icons.shower_rounded,
                      size: iconSize,
                    ),
                  ),
              
                  Align(
                    alignment: Alignment(0,0),
                    child: facilities.hasShower ?  
                    Icon(Icons.check, size: iconSize, color: Colors.green) : 
                    Icon(Icons.close, size: iconSize, color: Colors.red)
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(padding),
              child: Stack(
                children: [
                  
                  Align(
                    alignment: Alignment(-0.6,0),
                    child: Text(
                      'Gym',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ),
              
                  Align(
                    alignment: Alignment(-1,0),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: iconSize,
                    ),
                  ),
              
                  Align(
                    alignment: Alignment(0,0),
                    child: facilities.hasGym ?   
                    Icon(Icons.check, size: iconSize, color: Colors.green) : 
                    Icon(Icons.close, size: iconSize, color: Colors.red)
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(padding),
              child: Stack(
                children: [
                  
                  Align(
                    alignment: Alignment(-0.6,0),
                    child: Text(
                      'Food',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ),
              
                  Align(
                    alignment: Alignment(-1,0),
                    child: Icon(
                      Icons.ramen_dining_rounded,
                      size: iconSize,
                    ),
                  ),
              
                  Align(
                    alignment: Alignment(0,0),
                    child: facilities.hasFood ?   
                    Icon(Icons.check, size: iconSize, color: Colors.green) : 
                    Icon(Icons.close, size: iconSize, color: Colors.red)
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(padding),
              child: Stack(
                children: [
                  
                  Align(
                    alignment: Alignment(-0.6,0),
                    child: Text(
                      'Parking',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ),
              
                  Align(
                    alignment: Alignment(-1,0),
                    child: Icon(
                      Icons.local_parking_rounded,
                      size: iconSize,
                    ),
                  ),
              
                  Align(
                    alignment: Alignment(0,0),
                    child: facilities.hasParking ?  
                    Icon(Icons.check, size: iconSize, color: Colors.green) : 
                    Icon(Icons.close, size: iconSize, color: Colors.red)
                  ),
                ],
              ),
            ),
          ],
        ),

      );
    } else if (boulderingWallErrorState.isLoading()) {
      facilitiesTile = shimmerBlock(
        height: 400
      );
    } else {
      facilitiesTile = whiteBlock(
        context: context, 
        height: 400
      );
    }

    return facilitiesTile;
  }

  @override
  Widget build(BuildContext context) {
    
    final (
      ErrorState boulderingRouteListErrorState,
      List<BoulderingRouteModel>? boulderingRouteList
      ) = ref.watch(boulderingRouteListNotifierProvider);
    
    final (
      ErrorState projectLibraryListErrorState,
      List<ProjectLibraryModel>? projectLibraryList
      ) = ref.watch(projectLibraryListNotifierProvider);

    final (
      ErrorState boulderingWallErrorState,
      String? displayName,
      BoulderingWallModel? boulderingWall,
    ) = ref.watch(boulderingWallNotifierProvider);

    final databaseNotifier = ref.read(databaseNotifierProvider.notifier);
    final boulderingRouteNotifier = ref.read(boulderingRouteNotifierProvider.notifier);

    return Scaffold(
      appBar: PrimaryAppBar(
        title: 'Bouldering Wall'
      ),
      body: buildBody(
        context: context, 
        boulderingWall: boulderingWall,
        boulderingWallErrorState: boulderingWallErrorState,
        displayName: displayName,
        boulderingRouteListErrorState: boulderingRouteListErrorState, 
        boulderingRouteList: boulderingRouteList, 
        boulderingRouteNotifier: boulderingRouteNotifier,
        projectLibraryList: projectLibraryList,
        databaseNotifier: databaseNotifier
      ),
      floatingActionButton: FloatingActionButton(
        key: Key('qrCodeFloatingActionButton'),
        onPressed: () {
          Navigator.of(context).pushNamed(qrScannerRoute);
        },
        child: Icon(
          Icons.qr_code_rounded,
          color: Colors.black,
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    ); 
  }
}