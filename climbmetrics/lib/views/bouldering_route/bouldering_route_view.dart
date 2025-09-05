import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/utils/generate_id.dart';
import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/core/utils/observers.dart';
import 'package:climbmetrics/core/widgets/app_bar.dart';
import 'package:climbmetrics/core/widgets/loading.dart';
import 'package:climbmetrics/core/widgets/modal_bottom_sheet.dart';
import 'package:climbmetrics/core/widgets/snackbar.dart';
import 'package:climbmetrics/core/widgets/text_field.dart';
import 'package:climbmetrics/core/widgets/title.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_style_model.dart';
import 'package:climbmetrics/models/project_library/project_libary_model.dart';
import 'package:climbmetrics/services/metrics/metrics_service.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_provider.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:climbmetrics/viewmodels/database/database_provider.dart';
import 'package:climbmetrics/viewmodels/project_library/project_library_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoulderingRouteView extends ConsumerStatefulWidget {
  const BoulderingRouteView({super.key});

  @override
  ConsumerState<BoulderingRouteView> createState() => _BoulderingRouteViewState();
}

class _BoulderingRouteViewState extends ConsumerState<BoulderingRouteView> with RouteAware {

  late final ProviderSubscription<dynamic> authSubscription;
  final double initialRating = 1;
  final double minRating = 1;
  double? rating = 1;
  double? difficultyRating;
  double? officialGrade;
  bool isSubmitLoading = false;
  bool isHasLikeLoading = false;
  final controller = TextEditingController();
  bool hasLiked = false;
  bool hasDisliked = false;
  
  @override
  void initState() {
    super.initState();

    final authStateCheck = StateCheck.auth();
    authSubscription = authStateCheck.check(
      context: context, 
      ref: ref
    );

    final boulderingRouteState = ref.read(boulderingRouteNotifierProvider);
    final boulderingRouteNotifier = ref.read(boulderingRouteNotifierProvider.notifier);
    
    final (
    ErrorState initErrorState, 
    BoulderingRouteModel? boulderingRoute
    ) = boulderingRouteState;

    if (initErrorState.isSelected() && boulderingRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        boulderingRouteNotifier.cloudSyncBoulderingRoute(boulderingRoute);
        getHasLikedOrDisliked(boulderingRoute.routeID!);
      });
    }

    if (boulderingRoute != null) {
      setState(() {
        officialGrade = boulderingRoute.officialDifficultyRating.toDouble();
        difficultyRating = boulderingRoute.officialDifficultyRating.toDouble();
      });
    } else {
      setState(() {
        officialGrade = 0;
        difficultyRating = 0;
      });
    }  
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPop() {
    final boulderingRouteNotifier = ref.read(boulderingRouteNotifierProvider.notifier);
    boulderingRouteNotifier.reset();
  }

  void getHasLikedOrDisliked(String routeID) async {

    setState(() {
      isHasLikeLoading = true;
    });

    final boulderingRouteNotifier = ref.read(boulderingRouteNotifierProvider.notifier);

    final (
      ErrorState hasLikedErrorState, 
      String? likeID
      ) = await boulderingRouteNotifier.hasLiked(routeID);
    
    if (hasLikedErrorState.isNull() && likeID != null) {

      setState(() {
        isHasLikeLoading = false;
        hasLiked = true;
      });
      
      return;
    }

    final (
      ErrorState hasDislikedErrorState, 
      String? dislikeID
      ) = await boulderingRouteNotifier.hasDisliked(routeID);

    if (hasDislikedErrorState.isNull() && dislikeID != null) {
      
      setState(() {
        isHasLikeLoading = false;
        hasDisliked = true;
      });
      
      return;
    }
  }

/// Builds the community grade [BarChart]
/// 
/// Returns a [Widget]
  Widget buildBarChart({
    required BuildContext context,
    required ErrorState errorState,
    required BoulderingRouteModel? boulderingRoute,
    double padding = 10
    }) {
      double width = MediaQuery.of(context).size.width;

      if (errorState.isNull() && boulderingRoute != null) {
        return Column(
          children: [

            Padding(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: standardTitleWidget(
              context: context, 
              title: 'Commmunity Grade',
              hasAlertDialog: true,
              titleText: 'Commmunity Grade',
              content: BarChartConstant.communityDescription,
              closeText: 'Ok'
            ),
          ),
            

            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: SizedBox(
                height: width,
                width: width,
                child: MetricsService.createCommunityBarChart(
                  context: context,
                  grade: officialGrade!.toInt(),
                  boulderingDifficultyDistribution: boulderingRoute.communityDifficultyRating
                ),
              ),
            )
          
          ],
        );
      } else if (errorState.isLoading()) {
      return shimmerBlock(
        height: width
      );
    } else {
      return greyBlock(
        height: width
      );
    }
  } 

/// Builds the grade review [Slider]
/// 
/// Returns a [Widget]
  Widget buildSlider({
    required BuildContext context,
    }) {
      return StatefulBuilder(
        builder: (context, setSliderState) {
          return Slider(
            key: Key('reviewSlider'),
            value: difficultyRating!, 
            min: 0,
            max: 17,
            divisions: 17,
            label: 'V${difficultyRating!.round().toString()}',
            inactiveColor: Theme.of(context).colorScheme.primaryContainer,
            activeColor: Theme.of(context).colorScheme.tertiaryContainer ,
            onChanged: (double value) {
              setSliderState(() {});
              setState(() {
                difficultyRating = value;
              });
            },
          );
        }
      );
    }

/// Builds the 5 star [RatingBar]
/// 
/// Returns a [Widget] 
  Widget buildRatingBar({
    required BuildContext context
    }) {
    return RatingBar.builder(
      initialRating: initialRating,
      minRating: minRating,
      direction: Axis.horizontal,
      allowHalfRating: true,
      glow: false,
      unratedColor: Colors.amber.withAlpha(50),
      itemCount: 5,
      itemSize: 50,
      itemBuilder: (context, index) {
        return Icon(
          key: Key('starIcon$index'),
          Icons.star,
          color: Colors.amber,
        );
      }, 
      onRatingUpdate: (rating) {
        setState(() {
          rating = rating;
        });
      },
      updateOnDrag: true,
    );
  }

/// Builds a modal bottom sheet for the bouldering route review
/// 
/// Return a modal bottom sheet
  Future<dynamic> buildModalBottomSheet({
    required BuildContext context,
    required BoulderingRouteNotifier boulderingRouteNotifier,
    required BoulderingRouteModel boulderingRoute,
    double padding = 15,
  }) {
    double height = MediaQuery.of(context).size.height;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalState) {
            return SizedBox(
              height: height*0.9,
              child: Column(
                children: [
                  
                  Padding(
                    padding: EdgeInsets.only(bottom: padding),
                    child: standardTitleWidget(
                      key: Key('reviewTitle'),
                      context: context, 
                      title: 'Review', 
                      hasAlertDialog: false
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: padding),
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      child: standardTextField(
                        key: Key('reviewTextField'),
                        controller: controller, 
                        maxLines: 5,
                        errorText: null, 
                        labelText: 'Leave a review'
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: padding),
                    child: standardTitleWidget(
                      context: context, 
                      title: 'Rating (1-5) : ', 
                      hasAlertDialog: false,
                      circularTop: false
                    ),
                  ),

                  Padding(
                    key: Key('reviewRatingBar'),
                    padding: EdgeInsets.symmetric(vertical: padding),
                    child: buildRatingBar(
                      context: context
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: padding),
                    child: standardTitleWidget(
                      context: context, 
                      title: 'Grade (V-Scale) : ', 
                      hasAlertDialog: true,
                      circularTop: false,
                      titleText: 'Your Grading',
                      content: RouteReviewConstant.description,
                      closeText: 'Ok'
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: padding),
                    child: buildSlider(
                      context: context
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: padding),
                    child: ElevatedButton(
                      key: Key('submitReviewButton'),
                      onPressed: () async {
                        
                        setState(() {
                          isSubmitLoading = true;
                        });
                        
                        ErrorState reviewState = await boulderingRouteNotifier.uploadCurrentBoulderingRouteReview(
                          boulderingRoute.routeID!, 
                          rating!, 
                          controller.text
                        );
                    
                        ErrorState difficultyErrorState = await boulderingRouteNotifier.uploadCurrentBoulderingRouteCommunityDifficultyRating(
                          boulderingRoute.routeID!, 
                          difficultyRating!.toInt()
                        );
                    
                        setState(() {
                          isSubmitLoading = false;
                        });
                    
                        if (!context.mounted) {
                          return;
                        }

                        standardSnackBar(
                          context: context, 
                          nullCheckList: [reviewState, difficultyErrorState], 
                          successText: 'Review submitted', 
                          failureText: 'An Error Occurred'
                        );

                        Navigator.pop(context);
                      }, 
                      child: isSubmitLoading == true ? CircularProgressIndicator() : Text('Submit', style: Theme.of(context).textTheme.titleLarge)
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

/// Builds the review [TextButton]
/// 
/// Returns a [Widget]
  Widget buildTextButton({
    required BuildContext context,
    required ErrorState errorState,
    required BoulderingRouteModel? boulderingRoute,
    required BoulderingRouteNotifier boulderingRouteNotifier,
    double padding = 10,
  }) {
    Widget? textButton;

    if (errorState.isNull() && boulderingRoute != null) {
      textButton = TextButton(
        key: Key('reviewTextButton'),
        onPressed: () {
          buildModalBottomSheet(
            context: context,
            boulderingRoute: boulderingRoute,
            boulderingRouteNotifier: boulderingRouteNotifier
          );
        }, 
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Text(
            'Want to leave a review? Click here',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
            ),
          ),
        )
      );
    } else if (errorState.isLoading()) {
      textButton = TextButton(
        onPressed: () {}, 
        child: CircularProgressIndicator()
      );
    } else {
      textButton = TextButton(
        onPressed: () {}, 
        child: Text('')
      );
    }
    return textButton;
  }

/// Builds the like [IconButton]
/// 
/// Returns a [Widget]
  Widget buildLikeButton({
    required BuildContext context,
    required BoulderingRouteNotifier boulderingRouteNotifier,
    required BoulderingRouteModel? boulderingRoute,
    double iconSize = 50,
  }) {
    Widget likeButton;
    Color color;
    void Function() onPressed;

    if (boulderingRoute != null) {
      if (hasLiked == true) {
        color = Colors.green;
        onPressed = () {};
      } else {
        String routeID = boulderingRoute.routeID!;
        color = Colors.black;
        onPressed = () async {

          final (
            ErrorState hasDislikedErrorState,
            String? id
            ) = await boulderingRouteNotifier.hasDisliked(routeID);
          
          if (id != null) {
            await boulderingRouteNotifier.removeLikeOrDislikeByID(id, false);
          }

          ErrorState likeErrorState = await boulderingRouteNotifier.uploadCurrentBoulderingRouteLikeOrDislike(routeID, true);

          if (likeErrorState.isNull() && hasDislikedErrorState.isNull()) {
            setState(() {
              hasLiked = true;
              hasDisliked = false;
            });
          }

          if (!context.mounted) {
            return;
          }

          standardSnackBar(
            context: context, 
            nullCheckList: [likeErrorState, hasDislikedErrorState], 
            successText: 'You Liked This Route', 
            failureText: 'An Error Occurred'
          );

          return;
        };
      }

      likeButton = IconButton(
        key: Key('likeButton'),
        onPressed: onPressed, 
        icon: Icon(
          Icons.thumb_up_alt_rounded,
          size: iconSize,
          color: color,
        )
      );
    } else {
      likeButton = whiteBlock(
        context: context,
        height: iconSize,
        width: iconSize
      );
    }

    return likeButton;
  }

/// Builds the dislike [IconButton]
/// 
/// Returns a [Widget]
  Widget buildDislikeButton({
    required BuildContext context,
    required BoulderingRouteNotifier boulderingRouteNotifier,
    required BoulderingRouteModel? boulderingRoute,
    double iconSize = 50
  }) {
    Widget dislikeButton;
    Color color;
    void Function() onPressed;

    if (boulderingRoute != null) {
      if (hasDisliked == true) {
        color = Colors.red;
        onPressed = () {};
      } else {
        String routeID = boulderingRoute.routeID!;
        color = Colors.black;
        onPressed = () async {

          final (
            ErrorState hasLikedErrorState,
            String? id
            ) = await boulderingRouteNotifier.hasLiked(routeID);
          
          if (id != null) {
            await boulderingRouteNotifier.removeLikeOrDislikeByID(id, true);
          }

          ErrorState dislikeErrorState = await boulderingRouteNotifier.uploadCurrentBoulderingRouteLikeOrDislike(routeID, false);

          if (dislikeErrorState.isNull() && hasLikedErrorState.isNull()) {
            setState(() {
              hasLiked = false;
              hasDisliked = true;
            });
          }

          if (!context.mounted) {
            return;
          }

          standardSnackBar(
            context: context, 
            nullCheckList: [dislikeErrorState, hasLikedErrorState], 
            successText: 'You Disliked This Route', 
            failureText: 'An Error Occurred'
          );

          return;
        };
      }

      dislikeButton = IconButton(
        key: Key('dislikeButton'),
        onPressed: onPressed, 
        icon: Icon(
          Icons.thumb_down_alt_rounded,
          size: iconSize,
          color: color,
        )
      );
    } else {
      dislikeButton = whiteBlock(
        context: context,
        height: iconSize,
        width: iconSize
      );
    }
    
    return dislikeButton;
  }

/// Builds a [Container] of route information
/// 
/// Returns a [Widget]
  Widget buildRouteInformationChild({
    required ErrorState errorState,
    required BoulderingRouteModel? boulderingRoute,
    double verticalPadding = 0,
    double height = 100,
    String attribute = 'routeID',
    double borderRadius = 10,

  }) {
    
    Widget routeInformationchild;
    double width = MediaQuery.of(context).size.width;

    if (errorState.isNull() && boulderingRoute != null) {
      String headingText;
      String text;

      String routeID = boulderingRoute.routeID!;
      String name = boulderingRoute.name;
      String setter = boulderingRoute.setter;
      int officialDifficultyRating = boulderingRoute.officialDifficultyRating;
      String colour = boulderingRoute.colour;
      int likes = boulderingRoute.likes;
      int dislikes = boulderingRoute.dislikes;
      double rating = boulderingRoute.rating;
      bool isCurrent = boulderingRoute.isCurrent;
      String dateSet = boulderingRoute.dateSet;

      switch (attribute) {
        case 'routeID':
        headingText = 'Route ID';
        text = routeID;
        case 'name':
        headingText = 'Name';
        text = name;
        case 'setter':
        headingText = 'Setter';
        text = title(setter);
        case 'officialDifficultyRating':
        headingText = 'Grade';
        text = 'V$officialDifficultyRating';
        case 'colour':
        headingText = 'Colour';
        text = title(colour);
        case 'likes':
        headingText = 'Likes';
        text = likes.toString();
        case 'dislikes':
        headingText = 'Dislikes';
        text = dislikes.toString();
        case 'rating':
        headingText = 'Rating';
        text = rating != 0 ? '${rating.toStringAsFixed(2)}  /  5' : 'None';
        case 'styles':
        headingText = 'Styles';
        text = 'Styles: ${boulderingRoute.styles}';
        case 'isCurrent':
        headingText = 'Active';
        text = isCurrent ? 'Yes' : 'No';
        case 'dateSet':
        headingText = 'Date';
        text = dateSet;
        default:
        text = '';
        headingText = '';
      }
      
      routeInformationchild = Stack(
        children: [
          
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Theme.of(context).colorScheme.primaryContainer,
                width: 5
              )
            ),
            child: Align(
              alignment: Alignment(0.6,0),
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleLarge
              ),
            ),
          ),
          
          Container(
            height: height,
            width: width / 3,
            
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10)
              ),
              
              color: Theme.of(context).colorScheme.primaryContainer,
              
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
            child: Align(
              alignment: Alignment(0,0),
              child: Text(
                headingText,
                style: Theme.of(context).textTheme.titleLarge
              ),
            ),
          )
        ],
      );
    } else if (errorState.isLoading()) {
      routeInformationchild = shimmerBlock(
        height: height
      );
    } else {
      routeInformationchild = whiteBlock(
        context: context,
        height: height
      );
    }

    return routeInformationchild;
  }

/// Builds a [Column] of route information [Widget]
/// 
/// Returns a [Widget]
  Widget buildRouteInformation({
    required BuildContext context,
    required ErrorState errorState,
    required BoulderingRouteModel? boulderingRoute,
    required List<ProjectLibraryModel>? projectLibraryList,
    required DatabaseNotifier databaseNotifier,
    double verticalPadding = 10,
    double childContainerVerticalPadding = 5,
    double childVerticalPadding = 10
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding
      ),
      child: Column(
        children: [

          Padding(
            padding: EdgeInsets.symmetric(vertical: childVerticalPadding),
            child: boulderingRoute == null ? shimmerBlock(height: 50) :
            Stack(
              children: [
                
                Align(
                  alignment: Alignment(-1,0),
                  child: standardTitleWidget(
                  context: context, 
                  title: boulderingRoute.name, 
                  hasAlertDialog: false,
                  circularTop: false
                  ),
                ),

                Align(
                  alignment: Alignment(0.8,0),
                  child: IconButton(
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
                      size: 40,
                    )
                  ),
                )

              ]
            )
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: childVerticalPadding),
            child: buildRouteInformationChild(
              errorState: errorState, 
              boulderingRoute: boulderingRoute,
              verticalPadding: childContainerVerticalPadding,
              attribute: 'officialDifficultyRating'
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: childVerticalPadding),
            child: buildRouteInformationChild(
              errorState: errorState, 
              boulderingRoute: boulderingRoute,
              verticalPadding: childContainerVerticalPadding,
              attribute: 'colour'
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: childVerticalPadding),
            child: standardTitleWidget(
              context: context, 
              title: 'Route Styles', 
              hasAlertDialog: true,
              titleText: 'Route Styles',
              content: RouteStyleConstant.description,
              closeText: 'Ok'
            ),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: childVerticalPadding),
            child: buildStylesTile(
              boulderingRoute: boulderingRoute
            ),
          ),
          
          Padding(
            padding: EdgeInsets.symmetric(vertical: childVerticalPadding),
            child: buildRouteInformationChild(
              errorState: errorState, 
              boulderingRoute: boulderingRoute,
              verticalPadding: childContainerVerticalPadding,
              attribute: 'likes'
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: childVerticalPadding),
            child: buildRouteInformationChild(
              errorState: errorState, 
              boulderingRoute: boulderingRoute,
              verticalPadding: childContainerVerticalPadding,
              attribute: 'dislikes'
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: childVerticalPadding),
            child: buildRouteInformationChild(
              errorState: errorState, 
              boulderingRoute: boulderingRoute,
              verticalPadding: childContainerVerticalPadding,
              attribute: 'rating'
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: childVerticalPadding),
            child: buildRouteInformationChild(
              errorState: errorState, 
              boulderingRoute: boulderingRoute,
              verticalPadding: childContainerVerticalPadding,
              attribute: 'isCurrent'
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: childVerticalPadding),
            child: buildRouteInformationChild(
              errorState: errorState, 
              boulderingRoute: boulderingRoute,
              verticalPadding: childContainerVerticalPadding,
              attribute: 'dateSet'
            ),
          ),

        ],
      ) ,
    );
  }

/// Builds the body [Widget]
/// 
/// Returns a [Widget]
  Widget buildBody({
    required BuildContext context,
    required ErrorState errorState,
    required BoulderingRouteModel? boulderingRoute,
    required BoulderingRouteNotifier boulderingRouteNotifier,
    required List<ProjectLibraryModel>? projectLibraryList,
    required DatabaseNotifier databaseNotifier,
    }) {
      Widget body;

      body = ListView(
        children: [
          
          buildRouteInformation(
            context: context, 
            errorState: errorState, 
            boulderingRoute: boulderingRoute,
            projectLibraryList: projectLibraryList,
            databaseNotifier: databaseNotifier
          ),
          
          buildTextButton(
            context: context, 
            errorState: errorState, 
            boulderingRoute: boulderingRoute, 
            boulderingRouteNotifier: boulderingRouteNotifier
          ),

          Stack(
            children: [
              
              Align(
                alignment: Alignment(-0.5,0),
                child: buildLikeButton(
                  context: context, 
                  boulderingRouteNotifier: boulderingRouteNotifier, 
                  boulderingRoute: boulderingRoute
                ),
              ),

              Align(
                alignment: Alignment(0.5,0),
                child: buildDislikeButton(
                  context: context, 
                  boulderingRouteNotifier: boulderingRouteNotifier, 
                  boulderingRoute: boulderingRoute
                ),
              ),
            
            ],
          ),

          buildBarChart(
            context: context,
            errorState: errorState,
            boulderingRoute: boulderingRoute
          ),
          
        ],
      );
      return body;
    }

/// Builds a [Column] indicating the styles of a route
/// 
/// Returns a [Widget]
  Widget buildStylesTile({
    required BoulderingRouteModel? boulderingRoute,
    double borderRadius = 10,
    double borderWidth = 5,
    double padding = 10,
    double iconSize = 40
  }) {
    Widget stylesTile;
    double width = MediaQuery.of(context).size.width;

    if (boulderingRoute != null) {
      final BoulderingStylesModel styles = boulderingRoute.styles;

      stylesTile = Container(
        
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
                    alignment: Alignment(-1,0),
                    child: Text(
                      'Crimpy',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ),
              
                  Align(
                    alignment: Alignment(0,0),
                    child: styles.isCrimpy ?  
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
                    alignment: Alignment(-1,0),
                    child: Text(
                      'Slabby',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ),
    
                  Align(
                    alignment: Alignment(0,0),
                    child: styles.isSlabby ?  
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
                    alignment: Alignment(-1,0),
                    child: Text(
                      'Overhung',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ),
            
                  Align(
                    alignment: Alignment(0,0),
                    child: styles.isOverhung ?  
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
                    alignment: Alignment(-1,0),
                    child: Text(
                      'Compression',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ),

                  Align(
                    alignment: Alignment(0,0),
                    child: styles.isCompression ?  
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
                    alignment: Alignment(-1,0),
                    child: Text(
                      'Dyno',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ),

                  Align(
                    alignment: Alignment(0,0),
                    child: styles.isDyno ?  
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
                    alignment: Alignment(-1,0),
                    child: Text(
                      'Technical',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ),

                  Align(
                    alignment: Alignment(0,0),
                    child: styles.isTechy ?  
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
                    alignment: Alignment(-1,0),
                    child: Text(
                      'Mantle',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ),

                  Align(
                    alignment: Alignment(0,0),
                    child: styles.isMantle ?  
                    Icon(Icons.check, size: iconSize, color: Colors.green) : 
                    Icon(Icons.close, size: iconSize, color: Colors.red)
                  ),
                
                ],
              ),
            ),

          ],
        ),
      );
    } else {
      stylesTile = SizedBox(
        width: width,
        height: 200,
      );
    }

    return stylesTile;
  }

  @override
  Widget build(BuildContext context) {
    
    final (
      ErrorState routeErrorState, 
      BoulderingRouteModel? boulderingRoute
      ) = ref.watch(boulderingRouteNotifierProvider);

    final (
      ErrorState projectLibraryListErrorState,
      List<ProjectLibraryModel>? projectLibraryList
      ) = ref.watch(projectLibraryListNotifierProvider);

    final boulderingRouteNotifier = ref.read(boulderingRouteNotifierProvider.notifier);
    final databaseNotifier = ref.read(databaseNotifierProvider.notifier);

    return Scaffold(
      appBar: PrimaryAppBar(
        title: 'Bouldering Route'
      ),
      body: buildBody(
        context: context, 
        errorState: routeErrorState, 
        boulderingRoute: boulderingRoute,
        boulderingRouteNotifier: boulderingRouteNotifier,
        projectLibraryList: projectLibraryList,
        databaseNotifier: databaseNotifier
      ),
    );
  }
}
