import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/core/utils/observers.dart';
import 'package:climbmetrics/core/widgets/app_bar.dart';
import 'package:climbmetrics/core/widgets/bottom_navigation_bar.dart';
import 'package:climbmetrics/core/widgets/list_tile.dart';
import 'package:climbmetrics/core/widgets/loading.dart';
import 'package:climbmetrics/models/project_library/project_libary_model.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_provider.dart';
import 'package:climbmetrics/viewmodels/project_library/project_library_list_notifier.dart';
import 'package:climbmetrics/viewmodels/project_library/project_library_notifier.dart';
import 'package:climbmetrics/viewmodels/project_library/project_library_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectLibraryListView extends ConsumerStatefulWidget {
  const ProjectLibraryListView({super.key});

  @override
  ConsumerState<ProjectLibraryListView> createState() => _ProjectLibraryListViewState();
}

class _ProjectLibraryListViewState extends ConsumerState<ProjectLibraryListView> with RouteAware {
  
  late final ProviderSubscription<dynamic> authSubscription;
  late final ProviderSubscription<dynamic> databaseSubscription;
  late final ProviderSubscription<(ErrorState, ProjectLibraryModel?)> projectLibrarySubscription;
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  
  String? nameErrorText;

/// Builds a [ListView] of a list of [ProjectLibraryModel]
/// 
/// Returns a [Widget]
  Widget buildListView({
    required BuildContext context,
    required ErrorState projectLibraryListErrorState,
    required List<ProjectLibraryModel>? projectLibraryList,
    required ProjectLibraryNotifier projectLibraryNotifier,
    required ProjectLibraryListNotifier projectLibraryListNotifier,
  }) {
    Widget body;

    if (
      projectLibraryList != null) {
      body = ListView(
        children: [
          
          for (ProjectLibraryModel projectLibrary in projectLibraryList) 
          
          Padding(
            padding: EdgeInsets.only(top: ListViewConstant.mediumPadding),
            child: ProjectLibraryListTile(
              projectLibraryListErrorState: projectLibraryListErrorState, 
              projectLibrary: projectLibrary, 
              projectLibraryNotifier: projectLibraryNotifier, 
              projectLibraryListNotifier: projectLibraryListNotifier
            )
          ),

          Padding(
            padding: EdgeInsets.only(top: ListViewConstant.mediumPadding),
            child: CreateProjectLibraryListTile(
              projectLibraryListNotifier: projectLibraryListNotifier
            )
          )
        
        ],
      );
    } else if (projectLibraryListErrorState.state == DatabaseError.userHasNoProjectLibrary) {
      body = ListView(
        children: [
          
          Padding(
            padding: EdgeInsets.only(top: ListViewConstant.mediumPadding),
            child: CreateProjectLibraryListTile(
              projectLibraryListNotifier: projectLibraryListNotifier
            )
          )
        
        ]
      );
    } else if (projectLibraryListErrorState.isLoading()) {
      body = shimmerBlock(
        height: ListTileConstant.height
      );
    } else {
      body = whiteBlock(
        context: context, 
        height: ListTileConstant.height
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

    projectLibrarySubscription = ref.listenManual<(ErrorState, ProjectLibraryModel?)>(
      projectLibraryNotifierProvider, 
      (previous, next) {
        final (
          ErrorState projectLibraryErrorState, 
          ProjectLibraryModel? projectLibrary
          ) = next;

        if (projectLibraryErrorState.isSelected() && projectLibrary != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamed(projectLibraryRoute);
          });            
        }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final boulderingWallNotifier = ref.read(boulderingWallNotifierProvider.notifier);
      boulderingWallNotifier.reset();

      final projectLibraryListNotifier = ref.read(projectLibraryListNotifierProvider.notifier);
      projectLibraryListNotifier.getCurrentProjectLibraryList();
    });
  }

  @override
  void dispose() {
    authSubscription.close();
    databaseSubscription.close();
    projectLibrarySubscription.close();
    routeObserver.unsubscribe(this);
    nameController.dispose();
    super.dispose();
  } 
  
  @override
  void didPopNext() {
    
    final projectLibraryNotifier = ref.read(projectLibraryNotifierProvider.notifier);
    projectLibraryNotifier.reset();

    setState(() {
      nameErrorText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final (
      ErrorState projectLibraryListErrorState, 
      List<ProjectLibraryModel>? projectLibraryList
      ) = ref.watch(projectLibraryListNotifierProvider);
    
    final projectLibraryListNotifier = ref.read(projectLibraryListNotifierProvider.notifier);
    final projectLibraryNotifier = ref.read(projectLibraryNotifierProvider.notifier);

    return Scaffold(
      appBar: PrimaryAppBar(
        title: 'Your Project Libraries'
      ),
      body: buildListView(
        context: context, 
        projectLibraryListErrorState: projectLibraryListErrorState, 
        projectLibraryList: projectLibraryList,
        projectLibraryNotifier: projectLibraryNotifier,
        projectLibraryListNotifier: projectLibraryListNotifier
      ),
      bottomNavigationBar: PrimaryBottomNaviagtionBar(),
    );
  }  
}



