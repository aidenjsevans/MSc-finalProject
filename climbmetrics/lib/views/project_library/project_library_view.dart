import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/core/utils/observers.dart';
import 'package:climbmetrics/core/widgets/app_bar.dart';
import 'package:climbmetrics/core/widgets/list_tile.dart';
import 'package:climbmetrics/core/widgets/navigation.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/models/project_library/project_libary_model.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_list_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_provider.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:climbmetrics/viewmodels/database/database_provider.dart';
import 'package:climbmetrics/viewmodels/project_library/project_library_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectLibraryView extends ConsumerStatefulWidget {
  const ProjectLibraryView({super.key});

  @override
  ConsumerState<ProjectLibraryView> createState() => _ProjectLibraryViewState();
}

class _ProjectLibraryViewState extends ConsumerState<ProjectLibraryView> with RouteAware {
  
  late final ProviderSubscription<dynamic> authSubscription;
  late final ProviderSubscription<dynamic> databaseSubscription;
  late final ProviderSubscription<(ErrorState,BoulderingRouteModel?)> boulderingRouteSubscription;

  bool hasNavigated = false;

  Widget buildListView({
    required BuildContext context,
    required ErrorState boulderingRouteListErrorState,
    required List<BoulderingRouteModel>? boulderingRouteList,
    required BoulderingRouteNotifier boulderingRouteNotifier,
    required DatabaseNotifier databaseNotifier,
    required ProjectLibraryModel projectLibrary,
    required BoulderingRouteListNotifier boulderingRouteListNotifier
  }) {
    Widget body;

    if (boulderingRouteList != null) {
      
      body = ListView.builder(
        
        itemCount: boulderingRouteList.length,
        itemBuilder: (context, index) {
          
          final boulderingRoute = boulderingRouteList[index];

          return Padding(
            padding: EdgeInsets.symmetric(vertical: ListViewConstant.mediumPadding),
            child: BoulderingRouteListTile(
              boulderingRouteListErrorState: boulderingRouteListErrorState, 
              boulderingRoute: boulderingRoute, 
              boulderingRouteNotifier: boulderingRouteNotifier, 
              databaseNotifier: databaseNotifier,
              isInProjectLibrary: true,
              projectLibrary: projectLibrary,
              boulderingRouteListNotifier: boulderingRouteListNotifier,

            )
          );
        }
      );
    } else {
      body  = Align(
        alignment: Alignment(0,0),
        child: standardNavigation(
          context: context, 
          topText: "No routes", 
          bottomText: "Tap the icon to get started",
          icon: Icons.corporate_fare_rounded, 
          route: boulderingWallListRoute
        )
      );
    }

    return body;
  }

  @override
  void initState() {
    super.initState();

    final authStateCheck = StateCheck.auth();
    authSubscription = authStateCheck.check(
      context: context, 
      ref: ref
    );
    
    final databaseStateCheck = StateCheck.database();
    databaseSubscription = databaseStateCheck.check(
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
          hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamed(boulderingRouteRoute);
          });          
        }
      }
    );

    final (
      ErrorState projectLibraryErrorState, 
      ProjectLibraryModel? projectLibrary
    ) = ref.read(projectLibraryNotifierProvider);
    
    final boulderingRouteListNotifier = ref.read(boulderingRouteListNotifierProvider.notifier);
    boulderingRouteListNotifier.getProjectBoulderingRouteList(projectLibrary!.projectLibraryID);
  }

  @override
  void dispose() {
    authSubscription.close();
    databaseSubscription.close();
    boulderingRouteSubscription.close();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final (
      ErrorState projectLibraryErrorState,
      ProjectLibraryModel? projectLibrary
      ) = ref.watch(projectLibraryNotifierProvider);
    
    final (
      ErrorState boulderingRouteListErrorState,
      List<BoulderingRouteModel>? boulderingRouteList
      ) = ref.watch(boulderingRouteListNotifierProvider);

    final boulderingRouteNotifier = ref.read(boulderingRouteNotifierProvider.notifier);
    final databaseNotifier = ref.read(databaseNotifierProvider.notifier);
    final boulderingRouteListNotifier = ref.read(boulderingRouteListNotifierProvider.notifier);
  
    return Scaffold(
      appBar: PrimaryAppBar(
        title: projectLibrary!.name
      ),
      body: buildListView(
        context: context, 
        boulderingRouteListErrorState: boulderingRouteListErrorState, 
        boulderingRouteList: boulderingRouteList,
        boulderingRouteNotifier: boulderingRouteNotifier,
        databaseNotifier: databaseNotifier,
        projectLibrary: projectLibrary,
        boulderingRouteListNotifier: boulderingRouteListNotifier
      )
    );
  }  
}
