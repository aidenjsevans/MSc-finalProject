import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/core/widgets/app_bar.dart';
import 'package:climbmetrics/core/widgets/bottom_navigation_bar.dart';
import 'package:climbmetrics/core/widgets/loading.dart';
import 'package:climbmetrics/core/widgets/title.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/services/metrics/metrics_service.dart';
import 'package:climbmetrics/viewmodels/database/database_provider.dart';
import 'package:climbmetrics/viewmodels/database/database_state.dart';
import 'package:climbmetrics/viewmodels/project_archive/project_archive_notifier_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class MetricListView extends ConsumerStatefulWidget {
  const MetricListView({super.key});

  @override
  ConsumerState<MetricListView> createState() => _MetricListViewState();
}

class _MetricListViewState extends ConsumerState<MetricListView> {

  late final ProviderSubscription<dynamic> authSubscription;
  late final ProviderSubscription<DatabaseState> databaseSubscription;
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    
    final authStateCheck = StateCheck.auth();
    authSubscription = authStateCheck.check(
      context: context, 
      ref: ref
    );

    databaseSubscription = ref.listenManual<DatabaseState>(
      databaseNotifierProvider, 
      (previous, next) {
        if (_hasRedirected) {
          return;
        }
        if (next == DatabaseState.error) {
          _hasRedirected = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(fatalErrorRoute);
          });            
        } else if (next == DatabaseState.closed) {
          _hasRedirected = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(loginRoute);
          });           
        }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectArchiveNotifier = ref.read(projectArchiveNotifierProvider.notifier);
      projectArchiveNotifier.getCurrentArchivedBoulderingRouteList();
    });
  }

  @override
  void dispose() {
    authSubscription.close();
    databaseSubscription.close();
    super.dispose();
  }

/// Builds a [Widget] detailing the hardest route a climber has completed
/// 
/// Returns a [Widget]
  Widget buildHardestBoulderingRoute({
    required BuildContext context,
    required ErrorState archiveErrorState,
    required List<BoulderingRouteModel>? boulderingRouteList,
    double borderRadius = 10
    }) {
      Widget body;
      Widget text;
      double width = MediaQuery.of(context).size.width;
      
      final (
        ErrorState metricsErrorState, 
        BoulderingRouteModel? hardestBoulderingRoute
        ) = MetricsService.getHardestRoute(boulderingRouteList);
      
      if (metricsErrorState.isNull() && hardestBoulderingRoute != null) {
        text = Text(
          key: Key('hardestRouteText'),
          'Difficulty rating: V${hardestBoulderingRoute.officialDifficultyRating}',
          style: Theme.of(context).textTheme.titleLarge
        );
      } else if (metricsErrorState.state == MetricsError.boulderingWallListEmpty) {
        text = Text(
          'No route archived',
          style: Theme.of(context).textTheme.titleLarge
        );
      } else {
        text = Text('');
      }

      if (archiveErrorState.isNull()) {
        body = Column(
          children: [

            Align(
              alignment: Alignment(-1,0),
              child: Container(
                height: 30,
                width: width / 2,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius) 
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
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    'Top Route',
                    style: Theme.of(context).textTheme.titleLarge
                  ),
                ),
              ),
            ),

            Container(
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                  bottomRight: Radius.circular(borderRadius)
                ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  width: 5
                )
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.black,
                      size: 75,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                    child: Center(
                      child: text,
                    ),
                  )
                
                ],
              ),
            ),
          ],
        );
      } else if (archiveErrorState.isLoading()) {
        body = Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 250,
            width: double.infinity,
            color: Colors.white,
          ),
        );
      } else {
        body = Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Theme.of(context).colorScheme.primaryContainer,
              width: 5
            )
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Icon(
                  Icons.archive_rounded,
                  color: Colors.black,
                  size: 75,
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                child: Center(
                  child: text,
                ),
              )
            ],
          ),
        );
      }

      return body;
    }

/// Builds a [BarChart] to display the total number of completed routes for each grade
/// 
/// Returns a [Widget]
  Widget buildTotalBarChart({
    required BuildContext context,
    required ErrorState archiveErrorState,
    List<BoulderingRouteModel>? boulderingRouteList,
    double padding = 10
  }) {
    double width = MediaQuery.of(context).size.width;
    
    if (archiveErrorState.isNull() && boulderingRouteList != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: Column(
          children: [

            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: standardTitleWidget(
                context: context, 
                title: 'Total Grade Count',
                hasAlertDialog: true,
                titleText: 'Total Grade Count',
                content: BarChartConstant.totalDescription,
                closeText: 'Ok'
              ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: SizedBox(
                key: Key('totalBarChart'),
                height: width,
                width: width,
                child: MetricsService.createBarChart(
                  context: context,
                  boulderingRouteList: boulderingRouteList
                ),
              ),
            )
          
          ],
        )  
      );
    } else if (archiveErrorState.isLoading()) {
      return shimmerBlock(
        height: width
      );
    } else {
      return whiteBlock(
        context: context,
        height: width,
        icon: Icons.bar_chart_rounded,
        iconSize: 100,
        hasBorder: true
      );
    }
  }

/// Builds a [BarChart] to display the yearly number of completed routes for each grade
/// 
/// Returns a [Widget]
  Widget buildYearBarChart({
    required BuildContext context,
    required ErrorState archiveErrorState,
    List<BoulderingRouteModel>? boulderingRouteList,
    List<String>? dateList,
    double padding = 10,
  }) {
    double width = MediaQuery.of(context).size.width;

    if (archiveErrorState.isNull() && boulderingRouteList != null && dateList != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: Column(
          children: [

            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: standardTitleWidget(
                context: context, 
                title: '${DateTime.now().year} Grade Count',
                hasAlertDialog: true,
                titleText: '${DateTime.now().year} Grade Count',
                content: BarChartConstant.yearDescription,
                closeText: 'Ok'
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: SizedBox(
                key: Key('yearBarChart'),
                height: width,
                width: width,
                child: MetricsService.createYearBarChart(
                  context: context,
                  boulderingRouteList: boulderingRouteList,
                  dateList: dateList
                )
              ),
            )

          ],
        )
      );
    } else if (archiveErrorState.isLoading()) {
      return shimmerBlock(
        height: width
      );
    } else {
      return whiteBlock(
        context: context,
        height: width,
        icon: Icons.bar_chart_rounded,
        iconSize: 100,
        hasBorder: true
      );
    }
  }

/// Builds a [BarChart] to display the monthly number of completed routes for each grade
/// 
/// Returns a [Widget]
  Widget buildMonthBarChart({
    required BuildContext context,
    required ErrorState archiveErrorState,
    List<BoulderingRouteModel>? boulderingRouteList,
    List<String>? dateList,
    double padding = 10,
  }) {
    double width = MediaQuery.of(context).size.width;

    if (archiveErrorState.isNull() && boulderingRouteList != null && dateList != null) {
      return Column(
        children: [

          Padding(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: standardTitleWidget(
              context: context, 
              title: '${DateFormat.MMMM().format(DateTime.now())} Grade Count',
              hasAlertDialog: true,
              titleText: '${DateFormat.MMMM().format(DateTime.now())} Grade Count',
              content: BarChartConstant.monthDescription,
              closeText: 'Ok'
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: SizedBox(
              key: Key('monthBarChart'),
              height: width,
              width: width,
              child: MetricsService.createMonthBarChart(
                context: context,
                boulderingRouteList: boulderingRouteList,
                dateList: dateList
              )
            ),
          ),

        ],
      ); 
    } else if (archiveErrorState.isLoading()) {
      return shimmerBlock(
        height: width
      );
    } else {
      return whiteBlock(
        context: context,
        height: width,
        icon: Icons.bar_chart_rounded,
        iconSize: 100,
        hasBorder: true
      );
    }
  }

/// Builds a [RadarChart] to display the styles of completed completed routes
/// 
/// Returns a [Widget]
  Widget buildTotalRadarChart({
    required BuildContext context,
    required ErrorState archiveErrorState,
    List<BoulderingRouteModel>? boulderingRouteList,
    double padding = 10,
  }) {
    double width = MediaQuery.of(context).size.width;

    if (boulderingRouteList != null) {
      return Column(
        children: [

          Padding(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: standardTitleWidget(
              context: context, 
              title: 'Style Composition',
              hasAlertDialog: true,
              titleText: 'Style Composition',
              content: RadarChartConstant.description,
              closeText: 'Ok'
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: SizedBox(
              key: Key('radarChart'),
              height: width,
              width: width,
              child: MetricsService.createRadarChart(
                context: context,
                boulderingRouteList: boulderingRouteList
              ),
            ),
          )
        
        ],
      );
    } else if (archiveErrorState.isLoading()) {
      return shimmerBlock(
        height: width
      );
    } else {
      return whiteBlock(
        context: context,
        height: width,
        icon: Icons.bar_chart_rounded,
        iconSize: 100,
        hasBorder: true
      );
    }
  }

/// Builds a [PieChart] to display the styles of completed completed routes
/// 
/// Returns a [Widget]
  Widget buildTotalPieChart({
    required ErrorState archiveErrorState,
    List<BoulderingRouteModel>? boulderingRouteList,
    double padding = 10,
  }) {
    double width = MediaQuery.of(context).size.width;

    if (boulderingRouteList != null) {
      return Column(
        children: [
          
          Padding(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: SizedBox(
              key: Key('pieChart'),
              height: width,
              width: width,
              child: PieChartWidget(
                boulderingRouteList: boulderingRouteList
              ),
            )
          )

        ],
      );
    } else if (archiveErrorState.isLoading()) {
      return shimmerBlock(
        height: width
      );
    } else {
      return whiteBlock(
        context: context,
        height: width,
        icon: Icons.bar_chart_rounded,
        iconSize: 100,
        hasBorder: true
      );
    }
  }

/// Builds a [LineChart] to display the hardest route completed each month during the current year
/// 
/// Returns a [Widget]
  Widget buildLineChart({
    required BuildContext context,
    required ErrorState archiveErrorState,
    List<BoulderingRouteModel>? boulderingRouteList,
    List<String>? dateList,
    double padding = 10,
  }) {
    double width = MediaQuery.of(context).size.width;

    if (archiveErrorState.isNull() && boulderingRouteList != null && dateList != null) {
      return Column(
        children: [

          Padding(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: standardTitleWidget(
              context: context, 
              title: '${DateTime.now().year} Grade Progress',
              hasAlertDialog: true,
              titleText: '${DateTime.now().year} Grade Progress',
              content: LineChartConstant.description,
              closeText: 'Ok'
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: padding),
            child: SizedBox(
              key: Key('lineChart'),
              height: width,
              width: width,
              child: MetricsService.createProgressLineChart(
                context: context,
                boulderingRouteList: boulderingRouteList,
                dateList: dateList
              )
            ),
          ),
        
        ],
      );
    } else if (archiveErrorState.isLoading()) {
      return shimmerBlock(
        height: width
      );
    } else {
      return whiteBlock(
        context: context,
        height: width,
        icon: Icons.bar_chart_rounded,
        iconSize: 100,
        hasBorder: true
      );
    }
  }

/// Builds the body [Widget]
/// 
/// Returns a [Widget]
  Widget buildBody({
    required BuildContext context,
    required ErrorState archiveErrorState,
    List<BoulderingRouteModel>? boulderingRouteList,
    List<String>? dateList,
    double padding = 10,
    }) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          children: [
            
            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: buildHardestBoulderingRoute(
                context: context,
                archiveErrorState: archiveErrorState,
                boulderingRouteList: boulderingRouteList,
              ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: buildTotalBarChart(
                context: context,
                archiveErrorState: archiveErrorState,
                boulderingRouteList: boulderingRouteList
              ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: buildYearBarChart(
                context: context,
                archiveErrorState: archiveErrorState,
                boulderingRouteList: boulderingRouteList,
                dateList: dateList
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: buildMonthBarChart(
                context: context,
                archiveErrorState: archiveErrorState,
                boulderingRouteList: boulderingRouteList,
                dateList: dateList
              ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: buildTotalRadarChart(
                context: context,
                archiveErrorState: archiveErrorState,
                boulderingRouteList: boulderingRouteList
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: padding),
              child: buildTotalPieChart(
                archiveErrorState: archiveErrorState, 
                boulderingRouteList: boulderingRouteList
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(
                top: 20
              ),
              child: buildLineChart(
                context: context,
                archiveErrorState: archiveErrorState,
                boulderingRouteList: boulderingRouteList,
                dateList: dateList
              ),
            )
          ],
        ),
      );
    }

  @override
  Widget build(BuildContext context) {

    final (
      ErrorState archiveErrorState,
      List<String>? dateList,
      List<BoulderingRouteModel>? boulderingRouteList) = ref.watch(projectArchiveNotifierProvider
    );
    
    return Scaffold(
      appBar: PrimaryAppBar(
        title: 'Your metrics'
      ),
      body: SingleChildScrollView(
        child: buildBody(
          context: context, 
          archiveErrorState: archiveErrorState,
          boulderingRouteList: boulderingRouteList,
          dateList: dateList
        )
      ),
      bottomNavigationBar: PrimaryBottomNaviagtionBar(),
    );
  }
}
