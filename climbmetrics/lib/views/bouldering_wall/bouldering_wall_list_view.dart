import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/core/utils/observers.dart';
import 'package:climbmetrics/core/widgets/app_bar.dart';
import 'package:climbmetrics/core/widgets/bottom_navigation_bar.dart';
import 'package:climbmetrics/core/widgets/list_tile.dart';
import 'package:climbmetrics/core/widgets/text_field.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_link_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_model.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_list_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_provider.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_search_notifier.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:climbmetrics/viewmodels/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoulderingWallListView extends ConsumerStatefulWidget {
  const BoulderingWallListView({super.key});

  @override
  ConsumerState<BoulderingWallListView> createState() => _BoulderingWallListViewState();
}

class _BoulderingWallListViewState extends ConsumerState<BoulderingWallListView> with RouteAware {

  late final ProviderSubscription<BoulderingWallLinkModel?> boulderingWallLinkSubscription;
  late final ProviderSubscription<dynamic> authSubscription;
  late final ProviderSubscription<(ErrorState, String?, List<BoulderingWallModel>?, Map<String,bool>?)> boulderingWallSearchListSubscription;
  
  final TextEditingController _nameController = TextEditingController();
  
  String? _errorText;
  bool _isSearchLoading = false;

/// Builds a [ListView] of the search bar and bouldering wall list tiles
/// 
/// Returns a [Widget]
  Widget buildListView({
  required BuildContext context,
  required ErrorState boulderingWallLinkListErrorState,
  required List<BoulderingWallLinkModel>? boulderingWallLinkList,
  required BoulderingWallLinkNotifier boulderingWallLinkNotifier,
  required DatabaseNotifier databaseNotifier,
  required BoulderingWallLinkListNotifier boulderingWallLinkListNotifier,
  required BoulderingWallSearchNotifier boulderingWallSearchNotifier,
}) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  Widget body;

  if (boulderingWallLinkListErrorState.isNull() && boulderingWallLinkList != null) {
    body = ListView(
      children: [
        
        Padding(
          padding: EdgeInsets.only(top: ListViewConstant.mediumPadding),
          child: buildSearchBar(boulderingWallSearchNotifier),
        ),
        
        for (final boulderingWallLink in boulderingWallLinkList)
        
        Padding(
          padding: EdgeInsets.only(top:  ListViewConstant.mediumPadding),
          child: BoulderingWallLinkListTile(
            boulderingWallLinkListErrorState: boulderingWallLinkListErrorState, 
            boulderingWallLink: boulderingWallLink, 
            boulderingWallLinkNotifier: boulderingWallLinkNotifier, 
            databaseNotifier: databaseNotifier, 
            boulderingWallLinkListNotifier: boulderingWallLinkListNotifier
          )
        ),
      ],
    );
  } else if (boulderingWallLinkListErrorState.isLoading()) {
    body =  SizedBox(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  } else {
    body = SizedBox(
      child: ListView(
        children: [

        Padding(
          padding: EdgeInsets.only(top:  ListViewConstant.mediumPadding),
          child: buildSearchBar(boulderingWallSearchNotifier),
        ),

          Padding(
            padding: EdgeInsets.only(top:  ListViewConstant.mediumPadding),
            child: SizedBox(
              height: height,
              width: width,
              
              child: Stack(
                children: [
                  
                  Align(
                    alignment: Alignment(0,-0.9),
                    child: Text(
                      key: Key('noBoulderingWallsText'),
                      'No Linked Bouldering Walls',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge
                    ),
                  ),
                  
                  Align(
                    alignment: Alignment(0,-0.6),
                    child: Icon(
                      Icons.search_rounded,
                      size: IconConstant.largeSize,
                    )
                  ),

                  Align(
                    alignment: Alignment(0,-0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Text(
                        'Try searching for your local climbing wall. Get started with the search bar at the top',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  )

                ],
              ),
            ),
          ),
        ],
      ),
    );
  } 
  
  return body;
}

/// Builds the [SearchBar], which is used to search for a bouldering wall by company name
/// 
/// Returns a [Widget]
  Widget buildSearchBar(
    BoulderingWallSearchNotifier boulderingWallSearchNotifier
  ) {
    double width = MediaQuery.of(context).size.width;
    String? localErrorText = _errorText;

    return StatefulBuilder(
      builder: (context, searchState) {
        return SizedBox(
          width: width,
          child: Stack(
            children: [
              
              Align(
                alignment: Alignment(-0.85,0),
                child: SizedBox(
                  width: width / 1.25,
                  child: standardTextField(
                    key: Key('boulderingWallSearchTextField'),
                    controller: _nameController, 
                    errorText: localErrorText, 
                    labelText: 'Company Name'
                  )
                ),
              ),
        
              Align(
                alignment: Alignment(0.9,0),
                child: IconButton(
                  key: Key('searchButton'),
                  onPressed: () async {
                    String companyName = _nameController.text.trim();

                    setState(() {
                      _isSearchLoading = true;
                    });
                    searchState(() => {});

                    if (companyName.isEmpty) {
                      setState(() {
                        _errorText = 'Empty entry';
                        _isSearchLoading = false;
                      });
                      searchState(() => {});
                      _nameController.clear();
                      return;
                    }

                    ErrorState searchErrorState = await boulderingWallSearchNotifier.fetchBoulderingWallListByCompanyName(companyName);

                    _nameController.clear();
                    
                    setState(() {
                      _errorText = null;
                      _isSearchLoading = false;
                    });

                    if (!context.mounted) {
                      return;
                    }

                    if (searchErrorState.state == CloudError.companyNotFound) {
                      setState(() {
                        _errorText = "Company '$companyName' not found";
                        _isSearchLoading = false;
                      });
                      searchState(() => {});
                      _nameController.clear();
                      return;
                    }

                  }, 
                  icon: _isSearchLoading ? CircularProgressIndicator() : 
                  Icon(
                    Icons.arrow_circle_right,
                    size: 40
                  )
                ),
              ),
            ],
          ),
        );
      }
    );  
  }

  @override
  void initState() {
    super.initState();

    final focusNode = FocusNode();
    focusNode.unfocus();

    final authStateCheck = StateCheck.auth();
    authSubscription = authStateCheck.check(
      context: context, 
      ref: ref
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final boulderingWallLinkListNotifier = ref.read(boulderingWallLinkListNotifierProvider.notifier);
      boulderingWallLinkListNotifier.getCurrentBoulderingWallLinkList();
    });
    
    boulderingWallLinkSubscription = ref.listenManual(
      boulderingWallLinkNotifierProvider, 
      (previous, next) {
        if (next != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamed(boulderingWallRoute);
          });   
        }
      }
    );
    
    boulderingWallSearchListSubscription = ref.listenManual(
      boulderingWallSearchNotifierProvider, 
      (previous, next) {
        
        final (
          ErrorState nextSearchErrorState, 
          String? nextDisplayName, 
          List<BoulderingWallModel>? boulderingWallList,
          Map<String,bool>? isLinkedMap) = next;
        
        if (
          nextSearchErrorState.isNull() && 
          nextDisplayName != null && 
          boulderingWallList != null
        ) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushNamed(boulderingWallSearchResultRoute);
          });
        }
      }
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    boulderingWallLinkSubscription.close();
    boulderingWallSearchListSubscription.close();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
  
    final boulderingWallNotifier = ref.read(boulderingWallNotifierProvider.notifier);
    final boulderingWallLinkNotifier = ref.read(boulderingWallLinkNotifierProvider.notifier);
    final boulderingWallSearchListNotifier = ref.read(boulderingWallSearchNotifierProvider.notifier);
  
    boulderingWallNotifier.reset();
    boulderingWallLinkNotifier.reset();
    boulderingWallSearchListNotifier.reset();
  }

  @override
  Widget build(BuildContext context) {
    
    final (
      ErrorState boulderingWallLinkListErrorState, 
      List<BoulderingWallLinkModel>? boulderingWallLinkList
      ) = ref.watch(boulderingWallLinkListNotifierProvider);
    
    final boulderingWallSearchNotifier = ref.read(boulderingWallSearchNotifierProvider.notifier);
    final databaseNotifier = ref.read(databaseNotifierProvider.notifier);
    final boulderingWallLinkListNotifier = ref.read(boulderingWallLinkListNotifierProvider.notifier);
    final boulderingWallLinkNotifier = ref.read(boulderingWallLinkNotifierProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PrimaryAppBar(
        title: 'Bouldering walls'
      ),
      body: buildListView(
        context: context, 
        boulderingWallLinkListErrorState: boulderingWallLinkListErrorState, 
        boulderingWallLinkList: boulderingWallLinkList, 
        boulderingWallLinkNotifier: boulderingWallLinkNotifier, 
        databaseNotifier: databaseNotifier, 
        boulderingWallLinkListNotifier: boulderingWallLinkListNotifier, 
        boulderingWallSearchNotifier: boulderingWallSearchNotifier
      ),
      bottomNavigationBar: PrimaryBottomNaviagtionBar(),
    );
  }
}



