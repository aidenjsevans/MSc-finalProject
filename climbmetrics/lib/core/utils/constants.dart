//  AUTHENTICATION---------------------------------------------------------------------------------------------

import 'package:climbmetrics/models/bouldering/bouldering_difficulty_distribution_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_style_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_facilities_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const loginRoute = '/login/';
const registrationRoute = '/registration/';
const initRoute = '/';
const emailVerificationRoute = '/email_verification/';
const fatalErrorRoute = '/error/';
const emailVerificationTime = Duration(seconds: 10);

//-------------------------------------------------------------------------------------------------------------


//  DATABASE---------------------------------------------------------------------------------------------------

const databaseLoadingRoute = '/database_loading/';
const dbName = 'user.db';
const dbPasswordKey = 'dbPasswordKey';
const charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()-_=+[]{}';

const Map<String, String> boulderingCompanies = {
  'redGoat': '4c8529a9-6a6a-4ff1-8bcf-e2b8f1e52703' 
};

const String userTableName = 'standard_user';
const String idCountTableName = 'id_count';
const String projectLibraryTableName = 'project_library';
const String projectLibraryContainsTableName = 'pl_contains';
const String boulderingRouteTableName = 'bouldering_route';
const String boulderingWallLinkedTableName = 'bw_linked';
const String projectArchiveContainsTableName = 'pa_contains';

//-------------------------------------------------------------------------------------------------------------


//  SQL STATEMENTS---------------------------------------------------------------------------------------------

const String standardUserSQL = (
  '''
  CREATE TABLE IF NOT EXISTS "standard_user" (
    "user_id"	TEXT NOT NULL,
    "email"	TEXT NOT NULL UNIQUE,
    "username"	TEXT,
    PRIMARY KEY("user_id")
  );
  '''
);

const String boulderingRouteSQL = (
  '''
  CREATE TABLE IF NOT EXISTS "bouldering_route" (
    "route_id"	TEXT NOT NULL,
    "name"	TEXT NOT NULL,
    "setter"	TEXT NOT NULL,
    "is_setter_anonymous"	INTEGER NOT NULL,
    "official_difficulty_rating"	INTEGER NOT NULL,
    "community_difficulty_rating"	TEXT NOT NULL,
    "colour"	TEXT NOT NULL,
    "likes"	INTEGER NOT NULL,
    "dislikes"	INTEGER NOT NULL,
    "rating"	REAL NOT NULL,
    "attempts"	INTEGER NOT NULL,
    "styles"	TEXT NOT NULL,
    "is_current"	INTEGER NOT NULL,
    "date_set"	TEXT NOT NULL,
    PRIMARY KEY("route_id"),
    CHECK("is_setter_anonymous" IN (0, 1)),
    CHECK("is_current" IN (0, 1))
  );
  '''
);

const String projectLibrarySQL = (
  '''
  CREATE TABLE IF NOT EXISTS "project_library" (
    "user_id"	TEXT,
    "pl_id"	INTEGER,
    "name"	TEXT NOT NULL,
    "date" TEXT NOT NULL,
    "tag" TEXT,
    PRIMARY KEY("pl_id","user_id"),
    FOREIGN KEY("user_id") REFERENCES "standard_user"("user_id") ON DELETE CASCADE
  );
  '''
);

const String projectLibraryContainsSQL = (
  '''
  CREATE TABLE IF NOT EXISTS "pl_contains" (
    "user_id"	TEXT NOT NULL,
    "route_id"	TEXT NOT NULL,
    "pl_id"	INTEGER NOT NULL,
    PRIMARY KEY("user_id","route_id","pl_id")
  );
  '''
);

/*
    FOREIGN KEY("pl_id", "user_id") REFERENCES "project_library"("pl_id", "user_id") ON DELETE CASCADE,
    FOREIGN KEY("route_id") REFERENCES "bouldering_route"("route_id") ON DELETE CASCADE
*/

const String projectArchiveContainsSQL = (
  '''
  CREATE TABLE IF NOT EXISTS "pa_contains" (
    "user_id"	TEXT NOT NULL,
    "route_id"	TEXT NOT NULL,
    "date"	TEXT NOT NULL,
    PRIMARY KEY("user_id","route_id"),
    FOREIGN KEY("route_id") REFERENCES "bouldering_route"("route_id"),
    FOREIGN KEY("user_id") REFERENCES "standard_user"("user_id") ON DELETE CASCADE
  );
  '''
);

const String boulderingWallLinkedSQL = (
  '''
  CREATE TABLE "bw_linked" (
    "bw_id"	TEXT NOT NULL,
    "user_id"	TEXT NOT NULL,
    "display_name" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "postcode" TEXT NOT NULL,
    "street" TEXT NOT NULL,
    PRIMARY KEY("bw_id","user_id"),
    FOREIGN KEY("user_id") REFERENCES "standard_user"("user_id") ON DELETE CASCADE
  );
  '''
);

const String idCountSQL = (
  '''
  CREATE TABLE IF NOT EXISTS "id_count" (
    "id"	INTEGER NOT NULL,
    "name"	TEXT NOT NULL,
    PRIMARY KEY("name")
  );
  '''
);

//-------------------------------------------------------------------------------------------------------------


//  CLOUD------------------------------------------------------------------------------------------------------

const String boulderingRouteCollectionName = 'bouldering_route';
const String boulderingWallCompanyCollectionName = 'bouldering_wall_company';
const String boulderingWallCompanyContainsCollectionName = 'bouldering_wall_company_contains';
const String boulderingWallContainsCollectionName = 'bouldering_wall_contains';
const String boulderingRouteReviewsCollectionName = 'bouldering_route_reviews';
const String boulderingRouteLikesCollectionName = 'bouldering_route_likes';
const String boulderingRouteDislikesCollectionName = 'bouldering_route_dislikes';
const String boulderingRouteCommunityDifficultyCollectionName = 'bouldering_route_community_difficulty';

//-------------------------------------------------------------------------------------------------------------


//  PROJECT LIBRARY--------------------------------------------------------------------------------------------

const projectLibraryListRoute = '/project_libraries/';
const projectLibraryRoute = '/project_libraries/project_library/';

//-------------------------------------------------------------------------------------------------------------


//  BOULDERING WALL--------------------------------------------------------------------------------------------

const boulderingWallListRoute = '/bouldering_walls/';
const boulderingWallRoute = '/bouldering_wall/';
const boulderingWallSearchResultRoute = '/bouldering_walls_result/';
const qrScannerRoute = '/scanner/';

final BoulderingWallFacilitiesModel boulderingWallFacilities = BoulderingWallFacilitiesModel();

//-------------------------------------------------------------------------------------------------------------


//  BOULDERING ROUTE-------------------------------------------------------------------------------------------

const boulderingRouteRoute = '/bouldering_route/';

final BoulderingStylesModel boulderingStyle = BoulderingStylesModel();
final BoulderingDifficultyDistributionModel communityDifficultyRating = BoulderingDifficultyDistributionModel();


//-------------------------------------------------------------------------------------------------------------

//  METRICS----------------------------------------------------------------------------------------------------

const metricListRoute = '/metrics/';

//-------------------------------------------------------------------------------------------------------------

//  WIDGETS---------------------------------------------------------------------------------------------------------

abstract class ListTileConstant {

  static const double borderWidth = 5;
  static const double borderRadius = 10;

  static const double padding = 10;
  static const double topPadding = 50;
  
  static const double height = 150;
  
  static const double barHeight = 50;

  static const Offset shortShadowOffset = Offset(15,0);
  static const Offset longShadowOffset = Offset(35,0);

  static const String archiveMenuValue = 'archive';
  static const String deleteMenuValue = 'delete';

  static const Duration getDelay = Duration(microseconds: 500);

}

abstract class IconConstant {

  static const double veryLargeSize = 80;
  static const double largeSize = 60;
  static const double mediumSize = 45;
  static const double smallSize = 20;

  static const Color color = Colors.black;
  static const Color borderColor = Colors.black;

  static const double borderWidth = 3;

}

abstract class ListViewConstant {

  static const double smallPadding = 10;
  static const double mediumPadding = 15;
  static const double largePadding = 20;

}

abstract class WidgetConstant {
  
  static const double borderWidth = 5;
  static const double borderRadius = 10;
  
  static const double iconBorderWidth = 3;
  
  static const double padding = 10;
  
  static const double listTileHeight = 60;
  static const double listTileBarHeight = 20;
  
  static const Offset shortShadowOffset = Offset(15,0);
  static const Offset longShadowOffset = Offset(35,0);
}

abstract class ModalSheetConstant {

  static const double borderWidth = 5;
  static const double borderRadius = 10;
  static const double leftBorderRadius = 10;
  static const double rightBorderRadius = 40;

  static const double projectLibraryHeight = 60;
  static const double projectLibraryWidth = 75;

  static const double padding = 5;
  static const double paddingLarge = 15;

}

abstract class SnackBarConstant {

  static const Color successColour = Color.fromARGB(255,164,222,153);
  static const Color failureColour = Color.fromARGB(255,219,149,149);

  static const Duration duration = Duration(seconds: 2);

  static const String failureText = 'An Error Occurred';

}

abstract class TitleWidgetConstant {

  static const double borderRadius = 10;

  static const double padding = 10;

  static const double height = 60;

}

abstract class TextFieldConstant {

  static const Color primaryErrorColor = Colors.redAccent;
  static const Color secondaryErrorColor = Color.fromARGB(150, 255, 82, 82);
  static const Color primaryColor = Colors.black;
  static const Color secondaryColor = Color.fromARGB(150, 0, 0, 0);
  static const Color tertiaryColor = Color.fromARGB(200, 0, 0, 0);

  static const  double borderWidth = 3;

  static const double primaryFontSize = 24;
  static const double secondaryFontSize = 16;

}

abstract class BarChartConstant {

  static const double barRodWidth = 10;
  static const double axisNameSize = 30;

  static const String totalDescription = 
    '''
    This bar chart reflects the total number of routes you have completed.\n
    Each rod is the number of routes you have completed for a specific grade (V-Scale).\n
    When pressed, the rods will display the grade alongside the count.
    ''';
  
  static const String yearDescription = 
    '''
    This bar chart reflects the total number of routes you have completed this year.\n
    Each rod is the number of routes you have completed for a specific grade (V-Scale).\n
    When pressed, the rods will display the grade alongside the count.
    ''';

  static const String monthDescription = 
    '''
    This bar chart reflects the total number of routes you have completed this month.\n
    Each rod is the number of routes you have completed for a specific grade (V-Scale).\n
    When pressed, the rods will display the grade alongside the count.
    ''';
  
  
  static const String communityDescription =
    '''
    This bar chart reflects the community grade for this route.\n
    Each rod is the total number of ratings for a specific grade that has been given by other users.\n
    The darker rod represents the official grade of the route.\n
    When pressed, the rods will display the grade alongside the count.\n
    You too can give it a rating by pressing the "Want to leave a review? Click Here" button, found just above the chart.
    ''';

  static const String countTitle = 'Count';
  static const String gradeTitle = 'Grade (V-Scale)';

  static const Color tooltipColor = Colors.white;
  
  static const Color highlightColor = Color.fromARGB(200, 0, 0, 0);

}

abstract class LineChartConstant {

  static const double tooltipMargin = 50;
  static const Color tooltipColor = Colors.white;

  static const double minX = 0;
  static const double maxX = 11;
  static const double minY = 0;
  static const double maxY = 17;

  static const double dotRadius = 5;

  static const description = 
  '''
  This line chart represents the hardest route you completed each month this year.\n
  This chart helps to highlight the progress you have made this year.\n
  When pressed, the line chart dot will display the month alongside the highest grade.

  ''';

}

abstract class RadarChartConstant {

  static const double entryRadius = 5;
  
  static const Color gridBorderColor = Color.fromARGB(200, 0, 0, 0);
  static const double gridBorderWidth = 1;

  static const RadarShape radarShape = RadarShape.polygon;
  static const Color radarBackgroundColor = Colors.transparent;

  static const double titlePositionPercentageOffset = 0.1;

  static const int tickCount = 1;
  static const Color tickBorderColor = Color.fromARGB(200, 0, 0, 0);
  static const Color tickTextColor = Colors.transparent;

  static const String description = 
  '''
  The radar chart represents the style breakdown of all the routes you have completed.\n
  The abbreviations are:\n
  CR - Crimpy\n
  S - Slabby\n
  O - Overhung\n
  CO - Compression\n
  D - Dyno\n
  T - Technical\n
  M - Mantle\n
  This chart helps to highlight your strengths, but may also help you to identify areas to improve on.\n
  The pie chart gives the count and percentage for each of these styles.\n
  When pressed, the pie chart segments will display the style count alongside its total percentage.

  ''';

}

abstract class PieChartConstant {

  static const Color slabColor = Color.fromARGB(255, 158, 147, 217);
  static const Color overhungColor = Color.fromARGB(255, 147, 217, 167);
  static const Color compressionColor = Color.fromARGB(255, 219, 149, 149);
  static const Color dynoColor = Color.fromARGB(255, 219, 166, 149);
  static const Color technicalColor = Color.fromARGB(255, 219, 149, 184);
  static const Color mantleColor = Color.fromARGB(255, 153, 222, 220);

  static double sectionSpace = 10;
  static double centerSpaceRadius = 0;

}

abstract class RouteStyleConstant {

  static const String description = 
  '''
  Each of these terms describes a style of route:\n
  Crimpy - involves small edges and holds \n
  Slabby - the wall on which the route is found is not fully vertical\n
  Overhung - the wall on which the route is found angles outward forming an overhang\n
  Compression - the route requires a climber to user opposing forces to hold on to and move between holds\n
  Dyno - the route requires a dynamic movement using momentum to get to the next hold\n
  Technical - the route requires particular precision\n
  Mantle - the route requires the climber to push themselves over a horizontal ledge\n
  A route can contain many of these styles.\n
  A tick means that this style is present within the route, whilst an X means it is not.

  ''';

}

abstract class RouteReviewConstant {

  static const String description = 
  '''
  This scale represents what grade you think this route is.
  ''';
}

//-------------------------------------------------------------------------------------------------------------