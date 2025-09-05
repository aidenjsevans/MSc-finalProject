import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/bouldering/bouldering_difficulty_distribution_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_style_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The [MetricsService] provides various methods for the creation of graphs and metrics found on the metrics page
class MetricsService {

/// Creates a [BarChart] and takes a list of [BoulderingRouteModel] as an argument. More precisely, it uses [BoulderingDifficultyDistributionModel] of
/// each [BoulderingRouteModel] to get the total count of each grade. These counts dictate the height of each rod in the [BarChart]
/// 
/// Returns a [BarChart]
  static BarChart createBarChart({
    required BuildContext context,
    List<BoulderingRouteModel>? boulderingRouteList,
    Key? key 
    }) {
    
    Map<int,dynamic> gradeCount = BoulderingDifficultyDistributionModel().toIntKeyMap();
    
    if (boulderingRouteList != null) {
      for (final boulderingRoute in boulderingRouteList) {
        int grade = boulderingRoute.officialDifficultyRating;
        gradeCount[grade] = (gradeCount[grade]! + 1);
      }
    }
    
    final titlesData = FlTitlesData(
      
      bottomTitles: AxisTitles(
        axisNameWidget: Text(
          BarChartConstant.gradeTitle,
          style: Theme.of(context).textTheme.titleLarge
        ),
        axisNameSize: BarChartConstant.axisNameSize,
      ),
      
      leftTitles: AxisTitles(
        axisNameWidget: Text(
          BarChartConstant.countTitle,
          style: Theme.of(context).textTheme.titleLarge
        ),
        axisNameSize: BarChartConstant.axisNameSize,
      ),

      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
        ),
      ),

      topTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: Theme.of(context).textTheme.bodySmall,
            );
          } 
        ),
      ),
    );
    
    List<BarChartGroupData> barGroups = [];
    
    for (final entry in gradeCount.entries) {
      final groupData = BarChartGroupData(
        x: entry.key,
        barRods: [BarChartRodData(
          toY: entry.value.toDouble(),
          color: Theme.of(context).colorScheme.primaryContainer,
          width: BarChartConstant.barRodWidth
        )]
      );
      barGroups.add(groupData);
    }
    
    final barChart = BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => BarChartConstant.tooltipColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              
              final grade = group.x;
              final count = rod.toY.toInt().toString();

              return BarTooltipItem(
                'V$grade: $count',
                Theme.of(context).textTheme.titleLarge!
              );
            },
          ),
        ),
        titlesData: titlesData,
        borderData: FlBorderData(show: false),
        barGroups: barGroups
      )
    );
    return barChart;
  }

/// Creates a [BarChart], taking a list of [BoulderingRouteModel] and completion dates as arguments. It then calls the [createBarChart] method, giving
/// a list of [BoulderingRouteModel] completed during the current year as an argument.
/// 
/// Returns a [BarChart]
  static BarChart createYearBarChart({
    required BuildContext context,
    List<BoulderingRouteModel>? boulderingRouteList, 
    List<String>? dateList
    }) {
    
    final currYear = DateTime.now().year;
    final formatter = DateFormat('dd-MM-yyyy');

    List<BoulderingRouteModel> validBoulderingRouteList = [];

    if (boulderingRouteList == null || dateList == null) {
      return createBarChart(
        context: context,
        boulderingRouteList: null
      );
    }

    for (int i = 0; i < boulderingRouteList.length; i++ ) {
      final DateTime date = formatter.parse(dateList[i]);
      if (date.year == currYear) {
        validBoulderingRouteList.add(boulderingRouteList[i]);
      }
    }
    
    return createBarChart(
      context: context,
      boulderingRouteList: validBoulderingRouteList
    );
  }

/// Creates a [BarChart], taking a list of [BoulderingRouteModel] and completion dates as arguments. It then calls the [createBarChart] method, giving
/// a list of [BoulderingRouteModel] completed during the current month as an argument.
/// 
/// Returns a [BarChart]
  static BarChart createMonthBarChart({
    required BuildContext context,
    List<BoulderingRouteModel>? boulderingRouteList, 
    List<String>? dateList
    }) {
    
    final currYear = DateTime.now().year;
    final currMonth = DateTime.now().month;
    final formatter = DateFormat('dd-MM-yyyy');

    List<BoulderingRouteModel> validBoulderingRouteList = [];

    if (boulderingRouteList == null || dateList == null) {
      return createBarChart(
        context: context,
        boulderingRouteList: null
      );
    }

    for (int i = 0; i < boulderingRouteList.length; i++ ) {
      final DateTime date = formatter.parse(dateList[i]);
      if (date.year == currYear && date.month == currMonth) {
        validBoulderingRouteList.add(boulderingRouteList[i]);
      }
    }

    return createBarChart(
      context: context,
      boulderingRouteList: validBoulderingRouteList
    );
  }

/// Creates a [BarChart], taking a [BoulderingDifficultyDistributionModel] and official [grade] as arguments. It then extracts the
/// total count of each grade from the [BoulderingDifficultyDistributionModel]. The values of these counts dictate the height of each rod in the
/// [BarChart]. The rod that equates to the official [grade] is distinguished with a darker fill colour
/// 
/// Returns a [BarChart]
  static BarChart createCommunityBarChart({
    required BuildContext context,
    BoulderingDifficultyDistributionModel? boulderingDifficultyDistribution,
    required int grade,
    }) {
    
    boulderingDifficultyDistribution ??= BoulderingDifficultyDistributionModel();
    Map<int,dynamic> gradeCount = boulderingDifficultyDistribution.toIntKeyMap();

    final titlesData = FlTitlesData(
      
      bottomTitles: AxisTitles(
        axisNameWidget: Text(
          BarChartConstant.gradeTitle,
          style: Theme.of(context).textTheme.titleLarge
        ),
        axisNameSize: BarChartConstant.axisNameSize,
      ),
      
      leftTitles: AxisTitles(
        axisNameWidget: Text(
          BarChartConstant.countTitle,
          style: Theme.of(context).textTheme.titleLarge
        ),
        axisNameSize: BarChartConstant.axisNameSize,
      ),

      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
        ),
      ),

      topTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            
            final isOfficialGrade = value.toInt() == grade;

            final style = isOfficialGrade ? 
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ) :
            Theme.of(context).textTheme.bodySmall;


            return Text(
              
              value.toInt().toString(),
              style: style
            );
          } 
        ),
      ),

    );

    
    
    List<BarChartGroupData> barGroups = [];
    
    for (final entry in gradeCount.entries) {
      
      final isOfficialGrade = entry.key == grade;
      
      final color = isOfficialGrade ? 
      BarChartConstant.highlightColor : 
      Theme.of(context).colorScheme.primaryContainer;
      
      final groupData = BarChartGroupData(
        x: entry.key,
        barRods: [BarChartRodData(
          toY: entry.value.toDouble(),
          color: color,
          width: BarChartConstant.barRodWidth
        )]
      );
      barGroups.add(groupData);
    }
    
    final barChart = BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => BarChartConstant.tooltipColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              
              final grade = group.x;
              final count = rod.toY.toInt().toString();

              return BarTooltipItem(
                'V$grade: $count',
                Theme.of(context).textTheme.titleLarge!
              );
            },
          ),
        ),
        titlesData: titlesData,
        borderData: FlBorderData(show: false),
        barGroups: barGroups
      )
    );
    return barChart;
  }

/// Creates a [LineChart], taking a list of [BoulderingRouteModel] and completion dates as arguments. It then finds the hardest route completed for each
/// month during the current year. The grades of these routes form the [LineChart] spots.
/// 
/// Returns a [LineChart]
  static LineChart createProgressLineChart({
    required BuildContext context,
    List<BoulderingRouteModel>? boulderingRouteList, 
    List<String>? dateList
    }) {
 
    final currYear = DateTime.now().year;
    final formatter = DateFormat('dd-MM-yyyy');
    
    Map<int,String> monthMap = {
      0: 'Jan',
      1: 'Feb',
      2: 'Mar',
      3: 'Apr',
      4: 'May',
      5: 'Jun',
      6: 'Jul', 
      7: 'Aug',
      8: 'Sep',
      9: 'Oct',
      10: 'Nov',
      11: 'Dec'
    };
    
    Map<int,int?> monthlyHardestRoute = {};
    
    for (int i = 1; i < 13; i++) {
      monthlyHardestRoute[i] = null;
    }
    
    if (boulderingRouteList != null && dateList != null) {
      for (int i = 0; i < boulderingRouteList.length; i++) {
        final date = formatter.parse(dateList[i]);
        
        if (date.year == currYear) {
          final int grade = boulderingRouteList[i].officialDifficultyRating;

          if (monthlyHardestRoute[date.month] == null) {
            monthlyHardestRoute[date.month] = grade;
          } else if (grade > monthlyHardestRoute[date.month]!) {
            monthlyHardestRoute[date.month] = grade;
          } 
        }
      }
    }
    
    List<FlSpot> spots = [];

    for (var entry in monthlyHardestRoute.entries) {
      if (entry.value != null) {
        spots.add(FlSpot(entry.key-1, entry.value!.toDouble()));
      }
    }

    final lineChart = LineChart(
      LineChartData(

        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            
            tooltipMargin: LineChartConstant.tooltipMargin,
            getTooltipColor: (group) => LineChartConstant.tooltipColor,
            getTooltipItems: (touchedSpot) {
              
              List<LineTooltipItem?> tooltips = [];
              
              for (var spot in touchedSpot) {
                tooltips.add(
                  LineTooltipItem(
                    '${monthMap[spot.x.toInt()]}: V${spot.y.toInt()}',
                    Theme.of(context).textTheme.titleLarge!
                  )
                );
              }
              
              return tooltips;
            }

          )
        ),
  
        titlesData: FlTitlesData(
          
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              }
            )
          ),
          
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  monthMap[value]!,
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            )
          ),

          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('');
              },
            ),
          ),

          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('');
              },
            ),
          )
        ),
        
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        
        minX: LineChartConstant.minX,
        maxX: LineChartConstant.maxX,
        minY: LineChartConstant.minY,
        maxY: LineChartConstant.maxY,
        
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: Theme.of(context).colorScheme.secondaryContainer,
            isCurved: false,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: LineChartConstant.dotRadius,
                  color: Theme.of(context).colorScheme.primaryContainer,
                );
              }
            )
          ),
        ]
      )
    );

    return lineChart;
  }

/// Gets the [BoulderingRouteModel] with the highest grade from a list of [BoulderingRouteModel]
/// 
/// Returns a [BoulderingRouteModel] alongside an [ErrorState]. If the list of [BoulderingRouteModel] is empty,
/// the returned [BoulderingRouteModel] is null
  static (ErrorState,BoulderingRouteModel?) getHardestRoute(List<BoulderingRouteModel>? boulderingRouteList) {
    const String function = 'MetricsService.getHardestRoute()';
    
    if (boulderingRouteList == null) {
      ErrorState getErrorState = ErrorState.metrics(
        error: MetricsError.boulderingWallListEmpty, 
        function: function, 
        context: null
      );
      return (getErrorState, null);
    }
    
    if (boulderingRouteList.isEmpty) {
      ErrorState getErrorState = ErrorState.metrics(
        error: MetricsError.boulderingWallListEmpty, 
        function: function, 
        context: null
      );
      return (getErrorState, null);
    }
    
    BoulderingRouteModel? hardestBoulderingRoute;
    double highestDifficulty = double.negativeInfinity;
    
    for (final boulderingRoute in boulderingRouteList) {
      int difficulty = boulderingRoute.officialDifficultyRating;
      if (difficulty > highestDifficulty) {
        hardestBoulderingRoute = boulderingRoute;
        highestDifficulty = difficulty.toDouble();
      }
    }
    return (ErrorState.none(
      function: function,
      context: 'Route ID: ${hardestBoulderingRoute!.routeID}, Difficulty: V${hardestBoulderingRoute.officialDifficultyRating}'), hardestBoulderingRoute);
  }

/// Creates a [RadarChart] and takes a list of [BoulderingRouteModel] as an argument. It then finds the count of each style defined
/// within the [BoulderingStylesModel]. These counts form the data entries of the [RadarChart]
/// 
/// Returns a [RadarChart]
  static RadarChart createRadarChart({
    required BuildContext context,
    List<BoulderingRouteModel>? boulderingRouteList
    }) {
    
    const List<String> styleTitles = ['Crimp', 'Slab', 'Overhung', 'Compression', 'Dyno', 'Technical', 'Mantle'];
    const List<String> styleAbbreviationTitles = ['CR', 'S', 'O', 'CO', 'D', 'T', 'M'];
    Map<String,int> styleCount = {};
    
    for (final title in styleTitles) {
      styleCount[title] = 0;
    }
    
    if (boulderingRouteList != null) {
      for (final boulderingRoute in boulderingRouteList) {
        BoulderingStylesModel styles = boulderingRoute.styles;
        if (styles.isCrimpy == true) {
          styleCount['Crimp'] = (styleCount['Crimp']! + 1);
        }
        if (styles.isSlabby == true) {
          styleCount['Slab'] = (styleCount['Slab']! + 1);
        }
        if (styles.isOverhung == true) {
          styleCount['Overhung'] = (styleCount['Overhung']! + 1);
        }
        if (styles.isCompression == true) {
          styleCount['Compression'] = (styleCount['Compression']! + 1);
        }
        if (styles.isDyno == true) {
          styleCount['Dyno'] = (styleCount['Dyno']! + 1);
        }
        if (styles.isTechy == true) {
          styleCount['Technical'] = (styleCount['Technical']! + 1);
        }
        if (styles.isMantle == true) {
          styleCount['Mantle'] = (styleCount['Mantle']! + 1);
        }
      }
    }

    final List<RadarDataSet> dataSets = [
      RadarDataSet(
        fillColor: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.25),
        borderColor: Theme.of(context).colorScheme.secondaryContainer,
        entryRadius: RadarChartConstant.entryRadius,
        dataEntries: [
          RadarEntry(value: styleCount['Crimp']!.toDouble()),
          RadarEntry(value: styleCount['Slab']!.toDouble()),
          RadarEntry(value: styleCount['Overhung']!.toDouble()),
          RadarEntry(value: styleCount['Compression']!.toDouble()),
          RadarEntry(value: styleCount['Dyno']!.toDouble()),
          RadarEntry(value: styleCount['Technical']!.toDouble()),
          RadarEntry(value: styleCount['Mantle']!.toDouble())
        ]
      )
    ];

    int maxCount = 0;

    for (final entry in styleCount.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
      }
    }
    
    final radarChart = RadarChart(
      RadarChartData(

        isMinValueAtCenter: true,
        
        gridBorderData: BorderSide(
          color: RadarChartConstant.gridBorderColor,
          width: RadarChartConstant.gridBorderWidth
        ),
        
        dataSets: dataSets,
        
        radarTouchData: RadarTouchData(
          enabled: true

        ),
        
        radarShape: RadarShape.polygon,
        
        radarBackgroundColor: Colors.transparent,
        titlePositionPercentageOffset: RadarChartConstant.titlePositionPercentageOffset,
        
        getTitle: (index, angle) {
          return RadarChartTitle(
            text: styleAbbreviationTitles[index],
            
          );
        },
        
        tickCount: RadarChartConstant.tickCount,
        
        tickBorderData: BorderSide(
          color: RadarChartConstant.tickBorderColor
        ),
        
        ticksTextStyle: TextStyle(
          color: RadarChartConstant.tickTextColor
        )
      )
    );
    return radarChart;
  }

/// Creates a [PieChart] and takes a list of [BoulderingRouteModel] as an argument. It then finds the count of each style defined
/// within the [BoulderingStylesModel]. The fraction of each count is then calculated. These counts and fractions form the segments of the [PieChart]
/// 
/// Returns a [RadarChart]
  static PieChart createPieChart({
    required BuildContext context,
    required double radius,
    List<BoulderingRouteModel>? boulderingRouteList,
    }) {
    
    const List<String> styleTitles = ['Crimp', 'Slab', 'Overhung', 'Compression', 'Dyno', 'Technical', 'Mantle'];
    Map<String,int> styleCount = {};

    Map<String,Color> colorMap = {
      'Crimp': Theme.of(context).colorScheme.primaryContainer, 
      'Slab': PieChartConstant.slabColor, 
      'Overhung': PieChartConstant.overhungColor,
      'Compression': PieChartConstant.compressionColor,
      'Dyno': PieChartConstant.dynoColor,
      'Technical': PieChartConstant.technicalColor,
      'Mantle': PieChartConstant.mantleColor
      };
    
    for (final title in styleTitles) {
      styleCount[title] = 0;
    }

    int totalCount = 0;
    
    if (boulderingRouteList != null) {
      for (final boulderingRoute in boulderingRouteList) {
        BoulderingStylesModel styles = boulderingRoute.styles;
        
        if (styles.isCrimpy == true) {
          styleCount['Crimp'] = (styleCount['Crimp']! + 1);
          totalCount += 1;
        }
        
        if (styles.isSlabby == true) {
          styleCount['Slab'] = (styleCount['Slab']! + 1);
          totalCount += 1;
        }
        
        if (styles.isOverhung == true) {
          styleCount['Overhung'] = (styleCount['Overhung']! + 1);
          totalCount += 1;
        }
        
        if (styles.isCompression == true) {
          styleCount['Compression'] = (styleCount['Compression']! + 1);
          totalCount += 1;
        }
        
        if (styles.isDyno == true) {
          styleCount['Dyno'] = (styleCount['Dyno']! + 1);
          totalCount += 1;
        }
        
        if (styles.isTechy == true) {
          styleCount['Technical'] = (styleCount['Technical']! + 1);
          totalCount += 1;
        }
        
        if (styles.isMantle == true) {
          styleCount['Mantle'] = (styleCount['Mantle']! + 1);
          totalCount += 1;
        }
      }
    }

    final List<PieChartSectionData>  sections = [];
    final List<double> fractions = [];

    for (final entry in styleCount.entries) {

      final double fraction = (entry.value / totalCount) * 100;
      fractions.add(fraction);
      
      final pieChartSection = PieChartSectionData(
        value: entry.value.toDouble(),
        title: entry.key,
        radius: radius,
        color: colorMap[entry.key],
        titleStyle: Theme.of(context).textTheme.bodyMedium
      );
      sections.add(pieChartSection);
    }

    final pieChart = PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: ((FlTouchEvent event, pieTouchResponse) {
            if (
            !event.isInterestedForInteractions || 
            pieTouchResponse == null || 
            pieTouchResponse.touchedSection == null
            ) {
              
            }
          })
        ) ,
        
        sections: sections,
        sectionsSpace: 0,
        centerSpaceRadius: 0
      ),
    );


    return pieChart;
  }

}

/// A [StatefulWidget] that builds a [PieChart], taking a list of [BoulderingRouteModel] as a constructor argument. The [PieChartWidget] is
/// necessary to enable the on touch functionality of the [PieChart]
class PieChartWidget extends StatefulWidget {

  final List<BoulderingRouteModel>? boulderingRouteList;
  
  const PieChartWidget({
    super.key,
    required this.boulderingRouteList
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {

  int touchIndex = -1;

/// Creates and builds a [PieChart] and takes a list of [BoulderingRouteModel] as an argument. It then finds the count of each style defined
/// within the [BoulderingStylesModel]. The fraction of each count is then calculated. These counts and fractions form the segments of the [PieChart]
/// 
/// Returns a [RadarChart]
  PieChart buildPieChart({
    required BuildContext context
    }) {
    PieChart pieChart;
    double width = MediaQuery.of(context).size.width;

    List<BoulderingRouteModel>? boulderingRouteList = widget.boulderingRouteList;
    
    const List<String> styleTitles = ['Crimp', 'Slab', 'Overhung', 'Compression', 'Dyno', 'Technical', 'Mantle'];
    Map<String,int> styleCount = {};

    List<Color> colorList = [
      Theme.of(context).colorScheme.primaryContainer, 
      PieChartConstant.slabColor, 
      PieChartConstant.overhungColor,
      PieChartConstant.compressionColor,
      PieChartConstant.dynoColor,
      PieChartConstant.technicalColor,
      PieChartConstant.mantleColor
    ];
    
    for (final title in styleTitles) {
      styleCount[title] = 0;
    }

    int totalCount = 0;
    
    if (boulderingRouteList != null) {
      for (final boulderingRoute in boulderingRouteList) {
        BoulderingStylesModel styles = boulderingRoute.styles;
        
        if (styles.isCrimpy == true) {
          styleCount['Crimp'] = (styleCount['Crimp']! + 1);
          totalCount += 1;
        }
        
        if (styles.isSlabby == true) {
          styleCount['Slab'] = (styleCount['Slab']! + 1);
          totalCount += 1;
        }
        
        if (styles.isOverhung == true) {
          styleCount['Overhung'] = (styleCount['Overhung']! + 1);
          totalCount += 1;
        }
        
        if (styles.isCompression == true) {
          styleCount['Compression'] = (styleCount['Compression']! + 1);
          totalCount += 1;
        }
        
        if (styles.isDyno == true) {
          styleCount['Dyno'] = (styleCount['Dyno']! + 1);
          totalCount += 1;
        }
        
        if (styles.isTechy == true) {
          styleCount['Technical'] = (styleCount['Technical']! + 1);
          totalCount += 1;
        }
        
        if (styles.isMantle == true) {
          styleCount['Mantle'] = (styleCount['Mantle']! + 1);
          totalCount += 1;
        }
      }
    }

    final List<PieChartSectionData>  sections = [];
    final List<double> fractions = [];
    final List<int> counts = [];

    for (final entry in styleCount.entries) {

      final double fraction = (entry.value / totalCount) * 100;
      fractions.add(fraction);
      counts.add(entry.value);
      
    }

    for (int i = 0; i < counts.length; i++) {
      final bool isTouched = i == touchIndex;
      final radius = isTouched ? width / 2.25 : width / 2.5;
      final title = isTouched ? 'Count: ${counts[i]}\nWeight: ${fractions[i].toInt()}%' : styleTitles[i];

      final section = PieChartSectionData(
        value: counts[i].toDouble(),
        title: title,
        radius: radius,
        color: colorList[i],
        titleStyle: Theme.of(context).textTheme.bodyMedium
      );

      sections.add(section);
    }

    pieChart = PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: ((FlTouchEvent event, pieTouchResponse) {
            setState(() {
            if (
              !event.isInterestedForInteractions || 
              pieTouchResponse == null || 
              pieTouchResponse.touchedSection == null
              ) {
                touchIndex = -1;
                return;
              }
              touchIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          })    
        ) ,
        
        sections: sections,
        sectionsSpace: 0,
        centerSpaceRadius: 0
      ),
    );


    return pieChart;
  }

  @override
  Widget build(BuildContext context) {
    return buildPieChart(
      context: context
    );
  }
}

