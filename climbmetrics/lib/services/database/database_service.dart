import 'dart:io';
import 'dart:math';
import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/auth/standard_user_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_link_model.dart';
import 'package:climbmetrics/models/project_library/project_libary_model.dart';
import 'package:climbmetrics/models/project_library/project_library_contains_model.dart';
import 'package:climbmetrics/services/auth/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The [DatabaseService] provides various CRUD operations and utilities to interact with
/// the local SQLite database. It takes the [FirebaseAuthService] as a constructor argument so it can
/// use its services
class DatabaseService {

  Database? _database;
  final FirebaseAuthService _firebaseAuthService;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  DatabaseService(
    this._firebaseAuthService,
  );

//  UTILITY----------------------------------------------------------------------------------------------

/// Initialises the local SQL database
/// 
/// Returns the initialised [Database] alongside an [ErrorState]. If an error occurs, the returned
/// [Database] is null
  Future<(ErrorState,Database?)> initializeDB() async {
    final String function = 'DatabaseService.initializeDB()';
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = join(dir.path, dbName);
    final String dbPassword = await getPassword();    
    try {
      final Database database = await openDatabase(
        path,
        password: dbPassword,
        version: 1,
        onOpen: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
        }, 
        onCreate: (db, version) async {
          await db.execute(standardUserSQL);
          await db.execute(boulderingRouteSQL);
          await db.execute(projectLibrarySQL);
          await db.execute(projectLibraryContainsSQL);      
          await db.execute(projectArchiveContainsSQL);
          await db.execute(boulderingWallLinkedSQL);
          await db.execute(idCountSQL);
          await db.insert(
            'id_count', 
            {
              'name': 'projectLibrary',
              'id': 0
            }
          );        
        }
      );
      _database = database;
      return (ErrorState.none(function: function), database);
    } on DatabaseException catch (e) {
      if (e.isOpenFailedError()) {
        final openErrorState = ErrorState.database(
          error: DatabaseError.openFailed, 
          function: function, 
          context: 'Path: $path'
        );
        return (openErrorState, null);         
      } else if (e.isSyntaxError()) {
        final openErrorState = ErrorState.database(
          error: DatabaseError.syntaxError, 
          function: function, 
          context: null
        );
        return (openErrorState, null);        
      } else {
        final exceptionErrorState = ErrorState.database(
          error: DatabaseError.exception, 
          function: function, 
          context: e.toString()
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState, null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState, null);      
    }
  }

/// Getter for the local SQL database
/// 
/// If the database has already been initialised, the method will
/// return the [Database] alongside its [ErrorState]. Otherwise,
/// the method will call initializeDB()
  Future<(ErrorState,Database?)> get database async {
    if (_database == null) {
      return initializeDB();
    } else {
      return (ErrorState(), _database);
    }
  }

/// Deletes the local SQL database
/// 
/// Returns an [ErrorState]
  Future<ErrorState> deleteDB() async {
    final String function = 'DatabaseService.deleteDB()';
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = join(dir.path, dbName);    
    try {
      await deleteDatabase(path); 
      return ErrorState.none();
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState; 
    }
  }

/// Closes the local SQL database
/// 
/// Returns an [ErrorState]
  Future<ErrorState> closeDB() async {
    final String function = 'DatabaseService.closeDB()';
    if (_database != null) {
      try {
        await _database!.close();
        _database = null;
        return ErrorState.none(function: function);
      } on DatabaseException catch (e) {
        if (e.isDatabaseClosedError()) {
          final closeErrorState = ErrorState.database(
            error: DatabaseError.databaseAlreadyClosed, 
            function: function, 
            context: 'Path: ${_database!.path}'
          );
          return closeErrorState;
        } else {
          final exceptionErrorState = ErrorState.database(
            error: DatabaseError.exception, 
            function: function, 
            context: e.toString()
          );
          exceptionErrorState.toLog();
          return exceptionErrorState;
        }
      } on Exception catch (e) {
        final exceptionErrorState = ErrorState.database(
          error: DatabaseError.exception, 
          function: function, 
          context: e.toString()
        );
        exceptionErrorState.toLog();
        return exceptionErrorState; 
      } 
    } else {
      return ErrorState.database(
        error: DatabaseError.notInitialized,
        function: function,
        context: null
      );
    }
  } 

//-------------------------------------------------------------------------------------------------------


//  USER------------------------------------------------------------------------------------------------- 

/// Inserts a [StandardUserModel] into the standard_user table
/// 
/// Returns the [rowID] of the inserted [StandardUserModel] alongside an [ErrorState]. If
/// an error occurs, the returned [rowID] is 0
  Future<(ErrorState,int)> insertStandardUser(StandardUserModel user) async {
    final String function = 'DatabaseService.insertStandardUser()';
    final (ErrorState initErrorState, Database? db) = await database;
    if (initErrorState.isNotNull()) {
      return (initErrorState, 0);
    }
    try {
      final int rowID = await db!.insert(
        userTableName,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore
      );
      if (rowID != 0) {
        return (ErrorState.none(
          function: function,
          context: 'User ID: ${user.userID}'), rowID);
      } else {
        final insertErrorState = ErrorState.database(
          error: DatabaseError.userAlreadyInDatabase,
          function: function,
          context: 'User ID: ${user.userID}'
        );
        return (insertErrorState, 0);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState, 0);
    }
  }

/// Inserts a [StandardUserModel] into the standard_user table using the current session
/// [userID] value
/// 
/// Return an [ErrorState]
  Future<ErrorState> insertCurrentUser() async {
    final String function = 'DatabaseService.insertCurrentUser()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }
    final (ErrorState initErrorState, Database? db) = await database;
    if (initErrorState.isNotNull()) {
      return initErrorState;
    } 
    if (firebaseUser == null) {
      final errorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );
      return errorState;
    }
    final String userID = firebaseUser.uid;          
    final (ErrorState getErrorState, StandardUserModel? user) = await getStandardUserByID(userID);
    if (getErrorState.isNull()) {
      final errorState = ErrorState.database(
        error: DatabaseError.userAlreadyInDatabase, 
        function: function, 
        context: 'User ID: $userID'
      );
      return errorState;
    }
    final (ErrorState insertErrorState, int rowID) = await insertStandardUser(StandardUserModel.fromFirebaseUser(firebaseUser));
      return insertErrorState;
    }  

/// Gets a [StandardUserModel] from the standard_user table taking [userID] as an argument
/// 
/// Returns a [StandardUserModel] alongside an [ErrorState]. If an error occurs,
/// the returned [StandardUserModel] is null
  Future<(ErrorState,StandardUserModel?)> getStandardUserByID(String userID) async {
    final String function = 'DatabaseService.getStandardUserByID()';
    final (ErrorState initErrorState, Database? db) = await database;
    if (initErrorState.isNotNull()) {
      return (initErrorState, null);
    }
    try {
      final List<Map<String,dynamic>> maps = await db!.query(
        userTableName,
        where: 'user_id = ?',
        whereArgs: [userID],
        limit: 1
      );
      if (maps.isNotEmpty) {
        final user = StandardUserModel.fromMap(maps.first);
        return (ErrorState.none(function: function), user);
      } 
      final queryErrorState = ErrorState.database(
        error: DatabaseError.userNotFound, 
        function: 'DatabaseService.getStandardUserByID()',
        context: 'User ID: $userID'
      );
      return (queryErrorState, null);
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState, null);
    }
  }

//-------------------------------------------------------------------------------------------------------


//  PROJECT LIBRARY--------------------------------------------------------------------------------------

/// Gets a list of [ProjectLibraryModel] from the project_library table, taking [userID] as an argument
/// 
/// Returns a list of [ProjectLibraryModel] alongside an [ErrorState]. If an error occurs,
/// the returned list of [ProjectLibraryModel] is null
  Future<(ErrorState,List<ProjectLibraryModel>?)> getProjectLibraryListByUserID(String userID) async {
    
    final String function = 'DatabaseService.getProjectLibraryListByUserID()';
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState, null);
    }
    
    try {
      
      final List<Map<String,dynamic>> maps = await db!.query(
        projectLibraryTableName,
        where: 'user_id = ?',
        whereArgs: [userID]
      );
      
      if (maps.isEmpty) {
        final queryErrorState = ErrorState.database(
        error: DatabaseError.userHasNoProjectLibrary, 
        function: function, 
        context: 'user ID: $userID'
      );

      return (queryErrorState, null);
      }

      List<ProjectLibraryModel> projectLibraryList = [];
      
      for (final map in maps) {
        projectLibraryList.add(ProjectLibraryModel.fromMap(map));
      }
      
      return (ErrorState.none(function: function), projectLibraryList);          
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState, null);
    }
  }

/// Gets a list of [ProjectLibraryModel] from the project_library table, taking the current session [userID]
/// as an argument
/// 
/// Returns a list of [ProjectLibraryModel] alongside an [ErrorState]. If an error occurs,
/// the returned list of [ProjectLibraryModel] is null
  Future<(ErrorState,List<ProjectLibraryModel>?)> getCurrentProjectLibraryList() async {
    
    final String function = 'DatabaseService.getCurrentProjectLibraryList()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    
    if (userErrorState.isNotNull()) {
      return (userErrorState, null);
    }
    
    final (ErrorState initErrorState, Database? db) = await database; 
    if (initErrorState.isNotNull()) {
      return (initErrorState, null);
    } 
    
    if (firebaseUser == null) {
      final getErrorState = ErrorState.database(
          error: DatabaseError.notLoggedIn, 
          function: function, 
          context: null
      );
      
      return (getErrorState, null);
    }

    final String userID = firebaseUser.uid;          
    final (
      ErrorState getErrorState, 
      List<ProjectLibraryModel>? projectLibraryList
      ) = await getProjectLibraryListByUserID(userID);
    
    if (getErrorState.isNotNull()) {
      return (getErrorState, null);
    }
    
    final buffer = StringBuffer();
    buffer.writeln('\n\tUser ID: $userID');
    
    for (final projectLibrary in projectLibraryList!) {
      buffer.writeln('\tProject name: ${projectLibrary.name}, Project ID: ${projectLibrary.projectLibraryID}');
    }
    
    return (ErrorState.none(
      function: function,
      context: buffer.toString()
    ), projectLibraryList);
  } 

/// Gets a [ProjectLibraryModel] from the project_library table, taking [userID] and [projectLibraryID] as arguments
/// 
/// Returns a [ProjectLibraryModel] alongside and [ErrorState]. If an error occurs,
/// the returned [ProjectLibraryModel] is null
  Future<(ErrorState,ProjectLibraryModel?)> getProjectLibrary(String userID, int projectLibraryID) async {
    
    final String function = 'DatabaseService.getProjectLibrary()';
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState, null);
    }
    
    try{
      
      final maps = await db!.query(
        projectLibraryTableName,
        where: 'user_id = ? AND pl_id = ?',
        whereArgs: [userID, projectLibraryID],
        limit: 1
      );

      if (maps.isEmpty) {
        final queryErrorState = ErrorState.database(
          error: DatabaseError.projectLibraryNotFound, 
          function: function, 
          context: 'User ID: $userID, Project Library ID: $projectLibraryID'
        );

        return (queryErrorState, null);
      }
      
      return (ErrorState.none(), ProjectLibraryModel.fromMap(maps.first));      
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState, null);
    }
  }

/// Gets a [ProjectLibraryModel] from the project_library table, taking the current session [userID] and [projectLibraryID]
/// as arguments
/// 
/// Returns a [ProjectLibraryModel] alongside and [ErrorState]. If an error occurs,
/// the returned [ProjectLibraryModel] is null
  Future<(ErrorState,ProjectLibraryModel?)> getCurrentProjectLibrary(int projectLibraryID) async {
    
    final String function = 'DatabaseService.getCurrentProjectLibrary()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    
    if (userErrorState.isNotNull()) {
      return (userErrorState, null);
    }
    
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState, null);
    }

    if (firebaseUser == null) {
      final getErrorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );
      
      return (getErrorState,null);
    }
    
    final String userID = firebaseUser.uid;            
    final (
      ErrorState getErrorState, 
      ProjectLibraryModel? projectLibrary
      ) = await getProjectLibrary(userID, projectLibraryID);
    
    
    if (getErrorState.isNotNull()) {
      return (getErrorState, null);
    }
    
    return (ErrorState.none(function: function), projectLibrary);
  }

/// Inserts a [ProjectLibraryModel] into the project_library table, taking the project [name], [userID], and [tag] 
/// as arguments
/// 
/// Returns an [ErrorState] 
  Future<ErrorState> insertProjectLibrary(String name, String userID, String? tag) async {
    
    final String function = 'DatabaseService.insertProjectLibrary()';    
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (name == '') {
      final nameExceptionState = ErrorState.database(
        error: DatabaseError.emptyEntry, 
        function: function, 
        context: null
      );
      
      return nameExceptionState;
    }
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    
    final (ErrorState getErrorState, int projectLibraryID) = await getNextID('projectLibrary');
    
    if (getErrorState.isNotNull()) {
      return getErrorState;
    }
    
    try {
      final date = getCurrentTime();
      
      final projectLibrary = ProjectLibraryModel(
        userID: userID, 
        projectLibraryID: projectLibraryID, 
        name: name,
        date: date,
        tag: tag
      );
      
      await db!.insert(
        projectLibraryTableName,
        projectLibrary.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
      );
      
      return ErrorState.none(
        function: function,
        context: 'User ID: $userID, Name: $name, Project Library ID: $projectLibraryID, Date: $date, Tag: $tag'
      );
    
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;
    }
  }

/// Inserts a [ProjectLibraryModel] into the project_library table, taking the project [name], current session [userID], and [tag] 
/// as arguments
/// 
/// Returns an [ErrorState] 
  Future<ErrorState> insertCurrentProjectLibrary(String name, String? tag) async {
    
    final String function = 'DatabaseService.insertCurrentProjectLibrary()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user; 
    
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }
    
    if (firebaseUser == null) {
      final insertErrorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );

      return insertErrorState; 
    }
    
    final String userID = firebaseUser.uid;
    return await insertProjectLibrary(name, userID, tag);
  }

/// Deletes a [ProjectLibraryModel] from the project_library table, taking [userID] and [projectLibraryID] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> deleteProjectLibrary(String userID, int projectLibraryID) async {
    
    final String function = 'DatabaseService.deleteProjectLibrary()';
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }

    try {

      await db!.delete(
        projectLibraryTableName,
        where: 'user_id = ? AND pl_id = ?',
        whereArgs: [userID, projectLibraryID]
      );

      return ErrorState.none();
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;
    }
  }

/// Deletes a [ProjectLibraryModel] from the project_library table, taking the current session [userID] and [projectLibraryID] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> deleteCurrentProjectLibrary(int projectLibraryID) async {
    
    final String function = 'DatabaseService.deleteCurrentProjectLibrary()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user; 
    
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }
    
    if (firebaseUser == null) {
      final insertErrorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );

      return insertErrorState; 
    }
    
    String userID = firebaseUser.uid;
    return deleteProjectLibrary(userID, projectLibraryID);
  }

//------------------------------------------------------------------------------------------------------


//  BOULDERING ROUTE------------------------------------------------------------------------------------ 

/// Inserts a [BoulderingRouteModel] into the bouldering_route table
/// 
/// Returns an [ErrorState]
  Future<ErrorState> insertBoulderingRoute(BoulderingRouteModel boulderingRoute) async {
    
    final String function = 'DatabaseService.insertBoulderingRoute()';
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    
    try {
      
      await db!.insert(
        boulderingRouteTableName, 
        boulderingRoute.toSQLMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
      );
      
      return ErrorState.none(
        function: function,
        context: 'Route ID: ${boulderingRoute.routeID} Styles: ${boulderingRoute.styles}'
      );        
    
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;
    } 
  }

/// Gets a list of [BoulderingRouteModel] from the bouldering_route table, taking [projectLibraryID] as an argument
/// 
/// Returns a list of [BoulderingRouteModel] alongside an [ErrorState]. If an error occurs, the returned
/// list of [BoulderingRouteModel] is null
  Future<(ErrorState,List<BoulderingRouteModel>?)> getProjectBoulderingRouteList(int projectLibraryID) async {
    
    final String function = 'DatabaseService.getProjectBoulderingRouteList()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    
    if (userErrorState.isNotNull()) {
      return (userErrorState,null);
    }
    
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState,null);
    }
    
    if (firebaseUser == null) {
      final queryErrorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );
      return (queryErrorState,null); 
    }
    
    try {
      final String userID = firebaseUser.uid; 
      
      final maps = await db!.query(
        projectLibraryContainsTableName,
        where: 'user_id = ? AND pl_id = ?',
        whereArgs: [userID, projectLibraryID]
      );
      
      if (maps.isEmpty) {
        final queryErrorState = ErrorState.database(
          error: DatabaseError.boulderingRouteListNotFound, 
          function: function, 
          context: 'Project Library ID: $projectLibraryID'
        );
        return (queryErrorState,null); 
      }
      
      List<String> boulderingRouteIDList = [];
      
      for (Map<String,dynamic> map in maps) {
        final routeID = map['route_id'];
        boulderingRouteIDList.add(routeID);                
      }
      
      List<BoulderingRouteModel> boulderingRouteList = [];
      
      for (String routeID in boulderingRouteIDList) {
        
        final (
          ErrorState getErrorState, 
          BoulderingRouteModel? boulderingRoute ) = await getBoulderingRouteByRouteID(routeID
        );
        
        if (getErrorState.isNotNull()) {
          return (getErrorState,null);
        }
        boulderingRouteList.add(boulderingRoute!);
      }
      
      final buffer = StringBuffer();
      buffer.writeln('\n\tUser ID: $userID, Project library ID: $projectLibraryID');
      for (final boulderingRoute in boulderingRouteList) {
        buffer.writeln('\tRoute ID: ${boulderingRoute.routeID}');
      }
      
      return (ErrorState.none(
        function: function,
        context: buffer.toString()), boulderingRouteList
      );   
    } on Exception catch (e) {
    final exceptionErrorState = ErrorState.database(
      error: DatabaseError.exception, 
      function: function, 
      context: e.toString()
    );
    exceptionErrorState.toLog();
    return (exceptionErrorState,null);
    }
  }

/// Gets a [BoulderingRouteModel] from the bouldering_route table, taking [routeID] as an argument
/// 
/// Returns a [BoulderingRouteModel] alongside an [ErrorState]. If an error occurs, the returned 
/// [BoulderingRouteModel] is null
  Future<(ErrorState,BoulderingRouteModel?)> getBoulderingRouteByRouteID(String routeID) async {
    
    final String function = 'DatabaseService.getBoulderingRouteByRouteID()';    
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState,null);
    }
    
    try {
      
      final maps = await db!.query(
        boulderingRouteTableName,
        where: 'route_id = ?',
        whereArgs: [routeID],
        limit: 1
      );

      if (maps.isEmpty) {
        final queryErrorState = ErrorState.database(
          error: DatabaseError.boulderingRouteNotFound, 
          function: function, 
          context: 'Route ID: $routeID'
        );
        return (queryErrorState,null);
      }
      
      return (ErrorState.none(
        function: function,
        context: 'Bouldering route ID: $routeID'),BoulderingRouteModel.fromSQLmap(maps.first)
      );               
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null);
    }
  }

/// Gets a list of [BoulderingRouteModel] alongside the date they were archived. Takes a [userID] as an argument
/// 
/// Returns a list of [BoulderingRouteModel], a list of [date], and an [ErrorState]
  Future<(ErrorState,List<String>?,List<BoulderingRouteModel>?)> getArchivedBoulderingRouteListByUserID(String userID) async {
    
    final String function = 'DatabaseService.getArchivedBoulderingRouteListByUserID()';    
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState,null,null);
    }
    
    try {
      
      final maps = await db!.query(
        projectArchiveContainsTableName,
        where: 'user_id = ?',
        whereArgs: [userID]
      );
      
      if (maps.isEmpty) {
        final ErrorState queryErrorState = ErrorState.database(
          error: DatabaseError.archivedBoulderingRouteListNotFound, 
          function: function, 
          context: 'User ID: $userID'
        );
        return (queryErrorState,null,null);
      }
      
      final List<String> boulderingRouteIDList = [];
      final List<String> dateList = [];
      
      for (Map<String,dynamic> map in maps) {
        String routeID = map['route_id'];
        String date = map['date'];
        boulderingRouteIDList.add(routeID);
        dateList.add(date);
      }
      final List<BoulderingRouteModel> boulderingRouteList = [];
      
      for (String routeID in boulderingRouteIDList) {
        final (
          ErrorState getErrorState, 
          BoulderingRouteModel? boulderingRoute) = await getBoulderingRouteByRouteID(routeID
        );
        
        if (getErrorState.isNotNull()) {
          return (getErrorState,null,null);
        }
        boulderingRouteList.add(boulderingRoute!);
      }
      final buffer = StringBuffer();
      buffer.writeln('\n\tUser ID: $userID');
      for (final boulderingRoute in boulderingRouteList) {
        buffer.writeln('\tRoute ID: ${boulderingRoute.routeID}');
      }
      return (ErrorState.none(
        function: function,
        context: buffer.toString()
        ),
        dateList, 
        boulderingRouteList
      );
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null,null);  
    }
  } 

/// Gets a list of [BoulderingRouteModel] alongside the date they were archived. Takes the current session [userID] as an argument
/// 
/// Returns a list of [BoulderingRouteModel], a list of [date], and an [ErrorState]
  Future<(ErrorState,List<String>?,List<BoulderingRouteModel>?)> getCurrentArchivedBoulderingRouteList() async {
    final String function = 'DatabaseService.getCurrentArchivedBoulderingRouteList()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    if (userErrorState.isNotNull()) {
      return (userErrorState,null,null);
    }
    if (firebaseUser == null) {
      final insertErrorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );
      return (insertErrorState,null,null); 
    }
    String userID = firebaseUser.uid;
    return getArchivedBoulderingRouteListByUserID(userID);
  }

//------------------------------------------------------------------------------------------------------


//  PROJECT LIBRARY CONTAINS----------------------------------------------------------------------------
  
/// Inserts a [ProjectLibraryContainsModel] into the pl_contains table
/// 
/// Returns an [ErrorState]
  Future<ErrorState> insertProjectLibraryContains(ProjectLibraryContainsModel projectLibraryContains) async {
    
    final String function = 'DatabaseService.insertProjectLibraryContains()';
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    
    try {
      
      await db!.insert(
        projectLibraryContainsTableName,
        projectLibraryContains.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
      );
      final String userID = projectLibraryContains.userID;
      final String routeID = projectLibraryContains.routeID;
      final int projectLibraryID = projectLibraryContains.projectLibraryID;
      return ErrorState.none(
        function: function,
        context: 'User ID: $userID, Route ID: $routeID, Project library ID: $projectLibraryID',
      );
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;

    }
  }

/// Inserts a [ProjectLibraryContainsModel] into the pl_contains table, taking the current session [userID], [routeID], and [projectLibraryID]
/// as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> insertCurrentProjectLibraryContains(String routeID, int projectLibraryID) async {
    
    final String function = 'DatabaseService.insertCurrentProjectLibraryContains()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }
    
    if (firebaseUser == null) {
      final insertErrorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );
      return insertErrorState; 
    }
    
    final String userID = firebaseUser.uid; 
    final ProjectLibraryContainsModel projectLibraryContains = ProjectLibraryContainsModel(
      userID: userID, 
      routeID: routeID, 
      projectLibraryID: projectLibraryID
    );
    return insertProjectLibraryContains(projectLibraryContains);     
  }

/// Deletes a [ProjectLibraryContainsModel] from the pl_contains table, taking a [userID], [routeID], and [projectLibraryID]
/// as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> deleteProjectLibraryContains(String userID, String routeID, int projectLibraryID) async {
    
    final String function = 'DatabaseService.deleteProjectLibraryContains()';
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    
    try {

      await db!.delete(
        projectLibraryContainsTableName,
        where: 'user_id = ? AND route_id = ? AND pl_id = ?',
        whereArgs: [userID, routeID, projectLibraryID],
      );

      return ErrorState.none(
        function: function,
        context: 'User ID: $userID, Route ID: $routeID, Project library ID: $projectLibraryID',
      );
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;
      
    }
  }

/// Deletes a [ProjectLibraryContainsModel] from the pl_contains table, taking the current session [userID], [routeID], and [projectLibraryID]
/// as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> deleteCurrentProjectLibraryContains(String routeID, int projectLibraryID) async {
    
    final String function = 'DatabaseService.deleteCurrentProjectLibraryContains()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }
    
    if (firebaseUser == null) {
      final insertErrorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );
      return insertErrorState; 
    }
    
    final String userID = firebaseUser.uid;

    return deleteProjectLibraryContains(userID, routeID, projectLibraryID);
  }

//------------------------------------------------------------------------------------------------------
  

//  PROJECT ARCHIVE CONTAINS----------------------------------------------------------------------------

/// Inserts an entry in the pa_contains table, taking a [userID] and [routeID] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> archiveBoulderingRoute(String userID, String routeID) async {
    
    final String function = 'DatabaseService.archiveBoulderingRoute()';    
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    
    try {
      
      String date = getCurrentTime();
      await db!.insert(
        projectArchiveContainsTableName, 
        {
          "user_id": userID,
          "route_id": routeID,
          "date": date,
        },
        conflictAlgorithm: ConflictAlgorithm.replace
      );
      return ErrorState.none(
        function: function,
        context: 'User ID: $userID, Route ID: $routeID, Date: $date'
      );
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;
    } 
  }

/// Inserts an entry in the pa_contains table, taking the current session [userID] and [routeID] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> archiveCurrentBoulderingRoute(String routeID) async {
    
    final String function = 'DatabaseService.archiveCurrentBoulderingRoute()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }
    
    if (firebaseUser == null) {
      final insertErrorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );
      return insertErrorState; 
    }
    
    String userID = firebaseUser.uid;
    return archiveBoulderingRoute(userID, routeID);
  }

//------------------------------------------------------------------------------------------------------


//  BOULDERING WALL LINK--------------------------------------------------------------------------------
  
/// Inserts a [BoulderingWallLinkModel] into the bw_linked table
/// 
/// Returns an [ErrorState]
  Future<ErrorState> insertBoulderingWallLink(BoulderingWallLinkModel boulderingWallLink) async {
   
   final String function = 'DatabaseService.insertBoulderingWallLink()';    
    final (ErrorState initErrorState, Database? db) = await database;
   
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    
    try {

      await db!.insert(
        boulderingWallLinkedTableName,
        boulderingWallLink.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
      );
      return ErrorState.none();
    
    } on Exception catch (e) {
      
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      return exceptionErrorState;
    } 
  }

/// Inserts a [BoulderingWallLinkModel] into the bw_linked table, taking the current session [userID], [boulderingWallID], [displayName],
/// [city], [postcode], and [street] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> insertCurrentBoulderingWallLink(
    String boulderingWallID, 
    String displayName,
    String city,
    String postcode,
    String street,
    ) async {
    
    final String function = 'DatabaseService.insertCurrentBoulderingWallLink()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }
    
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }

    if (firebaseUser == null) {
      final getErrorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );
      return getErrorState;
    }
    
    final String userID = firebaseUser.uid;
    BoulderingWallLinkModel boulderingWallLink = BoulderingWallLinkModel(
      userID: userID, 
      boulderingWallID: boulderingWallID,
      displayName: displayName,
      city: city,
      postcode: postcode,
      street: street
    );

    return await insertBoulderingWallLink(boulderingWallLink);            
  }

/// Gets a list of [BoulderingWallLinkModel] from the bw_linked table, taking a [userID] as an argument
/// 
/// Returns a list of [BoulderingWallLinkModel] alongside an [ErrorState]. If an error occurs, the returned list
/// of [BoulderingWallLinkModel] is null
  Future<(ErrorState,List<BoulderingWallLinkModel>?)> getBoulderingWallLinkListByUserID(String userID) async {
    
    final String function = 'DatabaseService.getBoulderingWallLinkListByUserID()';    
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState,null);
    }
    
    try {
      final maps = await db!.query(
        boulderingWallLinkedTableName,
        where: 'user_id = ?',
        whereArgs: [userID],
      );
      
      if (maps.isEmpty) {
        final queryErrorState = ErrorState.database(
          error: DatabaseError.boulderingWallLinkListNotFound, 
          function: function, 
          context: 'User ID: $userID'
        );
        return (queryErrorState,null);
      }
      
      List<BoulderingWallLinkModel> boulderingWallLinkList = [];
      
      for (Map<String,dynamic> map in maps) {
        boulderingWallLinkList.add(BoulderingWallLinkModel.fromMap(map));
      }
      
      final buffer = StringBuffer();
      
      buffer.writeln('\n\tUser ID: $userID');
      for (final boulderingWallLink in boulderingWallLinkList) {
        buffer.writeln('Bouldering wall ID: ${boulderingWallLink.boulderingWallID}');
      }
      
      return (ErrorState.none(
        function: function,
        context: buffer.toString()), boulderingWallLinkList
      );        
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null);
    }
  }

/// Gets a list of [BoulderingWallLinkModel] from the bw_linked table, taking the current session [userID] as an argument
/// 
/// Returns a list of [BoulderingWallLinkModel] alongside an [ErrorState]. If an error occurs, the returned list
/// of [BoulderingWallLinkModel] is null
  Future<(ErrorState,List<BoulderingWallLinkModel>?)> getCurrentBoulderingWallLinkList() async {
    
    final String function = 'DatabaseService.getCurrentBoulderingWallLinkList()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    
    if (userErrorState.isNotNull()) {
      return (userErrorState,null);
    }
    
    final (ErrorState initErrorState, Database? db) = await database;
    if (initErrorState.isNotNull()) {
      return (initErrorState,null);
    }
    
    if (firebaseUser == null) {
      final getErrorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );
      return (getErrorState,null);  
    }
    
    final String userID = firebaseUser.uid;        
    return getBoulderingWallLinkListByUserID(userID);
  }

/// Deletes a [BoulderingWallLinkModel] from the bw_linked table, taking a [userID] and [boulderingWallID] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> deleteBoulderingWallLinkByBoulderingWallID(String boulderingWallID, String userID) async {
    final String function = 'DatabaseService.deleteBoulderingWallLinkByBoulderingWallID()';    
    final (ErrorState initErrorState, Database? db) = await database;
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    try {
      await db!.delete(
        boulderingWallLinkedTableName,
        where: 'bw_id = ? AND user_id = ?',
        whereArgs: [boulderingWallID, userID]
      );  
      return ErrorState.none(function: function);   
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState);
    }
  }
  
/// Deletes a [BoulderingWallLinkModel] from the bw_linked table, taking the current session [userID] and [boulderingWallID] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> deleteCurrentBoulderingWallLink(String boulderingWallID) async {
    final String function = 'DatabaseService.deleteCurrentBoulderingWallLink()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }
    final (ErrorState initErrorState, Database? db) = await database;
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    if (firebaseUser != null) {
      String userID = firebaseUser.uid;
      return await deleteBoulderingWallLinkByBoulderingWallID(boulderingWallID, userID);
    } else {
      final getErrorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );
      return getErrorState; 
    }
  }

/// Checks if a [BoulderingWallLinkModel] exists in the bw_linked table, taking a [boulderingWallID] as an argument
/// 
/// Returns true if the [BoulderingWallLinkModel] exists, and false otherwise. Also returns an [ErrorState]
  Future<(ErrorState,bool)> isCurrentBoulderingWallLinked(String boulderingWallID) async {
    final String function = 'DatabaseService.isCurrentBoulderingWallLinked()';
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
        
    if (userErrorState.isNotNull()) {
      return (userErrorState,false);
    }
    
    final (ErrorState initErrorState, Database? db) = await database;
    if (initErrorState.isNotNull()) {
      return (initErrorState,false);
    }
    
    if (firebaseUser == null) {
      final getErrorState = ErrorState.database(
        error: DatabaseError.notLoggedIn, 
        function: function, 
        context: null
      );
      return (getErrorState,false);  
    }

    String userID = firebaseUser.uid;

    try {

    final maps = await db!.query(
      boulderingWallLinkedTableName,
      where: 'user_id = ? AND bw_id = ?',
      whereArgs: [userID, boulderingWallID],
    );

    if (maps.isEmpty) {
      return (ErrorState.none(), false);
    } else {
      return (ErrorState.none(), true);
    }

    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,false);
    }
  }

//------------------------------------------------------------------------------------------------------


//  HELPER FUNCTIONS------------------------------------------------------------------------------------
 
/// Gets the database password from the [FlutterSecureStorage]. If no password exists, a secure password is
/// generated using [generateSecurePassword]
/// 
/// Returns the [dbPassword]
  Future<String> getPassword() async {
    String? dbPassword = await _secureStorage.read(key: dbPasswordKey);
    if (dbPassword == null) {
      final String dbSecurePassword = generateSecurePassword();
      await _secureStorage.write(key: dbPasswordKey, value: dbSecurePassword);
      return dbSecurePassword;
    }
    return dbPassword;
  }

/// Generates a secure random 32 character long password
/// 
/// Returns a [password]
  static String generateSecurePassword() {
    List<String> charList = [];
    final rand = Random.secure();
    for (var i = 0; i < 32; i++) {
      charList.add(charSet[rand.nextInt(charSet.length)]);
    }
    String password = charList.join();
    return password;
  }

/// Gets an [id] value from the id_count table, increments it, and then updates the id_count table. Takes a [counterName] as an argument
/// 
/// Returns the [id] alongside an [ErrorState]
  Future<(ErrorState,int)> getNextID(String counterName) async {
    
    final String function = 'DatabaseService.getNextID';
    final (ErrorState initErrorState, Database? db) = await database;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState, 0);
    }
    
    try {
      
      final maps = await db!.query(
        idCountTableName,
        where: 'name = ?',
        whereArgs: [counterName],
        limit: 1
      );
      
      if (maps.isEmpty) {
        final queryErrorState = ErrorState.database(
          error: DatabaseError.counterNotFound,
          function: function,
          context: 'Counter Name: $counterName'
        );
       
        return (queryErrorState, 0);
      } else {
        
        final int currentID = maps.first['id'] as int;
        final int updatedID = currentID + 1;
        
        await db.update(
          idCountTableName,
          {'id': updatedID},
          where: 'name = ?',
          whereArgs: [counterName]
        );
        
        return (ErrorState.none(), updatedID);                
      }      
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.database(
        error: DatabaseError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState, 0);
    }
  }

/// Gets the current date in dd-MM-yyyy format
/// 
/// Returns the current date
  String getCurrentTime() {
    final currTime = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(currTime);
  }

//-----------------------------------------------------------------------------------------------------
}
