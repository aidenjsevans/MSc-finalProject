import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/core/utils/observers.dart';
import 'package:climbmetrics/core/widgets/app_bar.dart';
import 'package:climbmetrics/core/widgets/list_tile.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_model.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_list_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoulderingWallSearchResultView extends ConsumerStatefulWidget {
  
  const BoulderingWallSearchResultView({super.key});

  @override
  ConsumerState<BoulderingWallSearchResultView> createState() => _BoulderingWallSearchResultViewState();

}

class _BoulderingWallSearchResultViewState extends ConsumerState<BoulderingWallSearchResultView> with RouteAware {

  late final ProviderSubscription<dynamic> authSubscription;

  @override
  void initState() {
    super.initState();

    final authStateCheck = StateCheck.auth();
    authSubscription = authStateCheck.check(
      context: context, 
      ref: ref
    );
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
  }

/// Builds a [ListView] of the bouldering wall search results
/// 
/// Returns a [Widget]
  Widget buildListView({
    required BuildContext context,
    required ErrorState boulderingWallSearchErrorState,
    required List<BoulderingWallModel>? boulderingWallSearchList,
    required String? displayName,
    required BoulderingWallLinkListNotifier boulderingWallLinkListNotifier,
    required Map<String,bool>? isLinkedMap,
  }) {
    Widget body;

    if (boulderingWallSearchList != null) {
      body = ListView(
        children: [
          
          for (final boulderingWall in boulderingWallSearchList)
          
          Padding(
            padding: EdgeInsets.only(top: ListViewConstant.mediumPadding),
            child: BoulderingWallSearchListTile(
              boulderingWallLinkListNotifier: boulderingWallLinkListNotifier, 
              displayName: displayName, 
              isLinkedMap: isLinkedMap, 
              boulderingWallSearchErrorState: boulderingWallSearchErrorState, 
              boulderingWall: boulderingWall
            )
          ),
        ],
      );
    } else if (boulderingWallSearchErrorState.state == DatabaseError.boulderingWallLinkListNotFound) {
      body = ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {

          return Padding(
            padding: EdgeInsets.only(top: ListViewConstant.mediumPadding),
            child: Container(
              padding: EdgeInsets.all(15),
              child: Center(
                child: Text('No linked bouldering walls'),
              ),
            )
          );
        }
      );
    } else {
      body = Padding(
        padding: EdgeInsets.only(top: ListViewConstant.mediumPadding),
        child: Container(
          padding: EdgeInsets.all(15),
          child: Center(
            child: CircularProgressIndicator()
          ),
        )
      );
    }

    return body;
  }

  @override
  Widget build(BuildContext context) {
    
    final (
      ErrorState boulderingWallSearchErrorState,
      String? displayName,
      List<BoulderingWallModel>? boulderingWallSearchList,
      Map<String,bool>? isLinkedMap
      ) = ref.watch(boulderingWallSearchNotifierProvider);

    final boulderingWallLinkListNotifier = ref.read(boulderingWallLinkListNotifierProvider.notifier);

    return Scaffold(
      appBar: PrimaryAppBar(
        title: 'Search result'
      ),
      body: buildListView(
        context: context,
        isLinkedMap: isLinkedMap,
        boulderingWallSearchErrorState: boulderingWallSearchErrorState, 
        boulderingWallSearchList: boulderingWallSearchList, 
        displayName: displayName, 
        boulderingWallLinkListNotifier: boulderingWallLinkListNotifier
      ),
    );
        
  }
}