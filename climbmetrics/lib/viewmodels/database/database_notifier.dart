import 'dart:developer';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/auth/standard_user_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_link_model.dart';
import 'package:climbmetrics/models/project_library/project_libary_model.dart';
import 'package:climbmetrics/services/database/database_service.dart';
import 'package:climbmetrics/viewmodels/auth/firebase_auth_notifier.dart';
import 'package:climbmetrics/viewmodels/database/database_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

/// The [DatabaseNotifier] provides various methods that can change its [state], which is of the 
/// type [DatabaseState]. It takes the [DatabaseService] and [FirebaseAuthNotifier] as constructor
/// arguments
class DatabaseNotifier extends StateNotifier<DatabaseState>{

  final DatabaseService _databaseService;
  final FirebaseAuthNotifier _firebaseAuthNotifier;

  DatabaseNotifier(
    this._databaseService,
    this._firebaseAuthNotifier
    ) : super(DatabaseState.closed);

//  UTILITY----------------------------------------------------------------------------------------------

/// Calls the [initializeDB] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState] 
  Future<void> initializeDB () async {
    final (ErrorState initErrorState, Database? db) = await _databaseService.initializeDB();
    switch (initErrorState.state) {
      case null:
      state = DatabaseState.nominal;
      break;
      case DatabaseError.openFailed:
      state = DatabaseState.error;
      initErrorState.toLog();
      break;
      case DatabaseError.syntaxError:
      state = DatabaseState.error;
      initErrorState.toLog();
      break;
      case DatabaseError.exception:
      state = DatabaseState.error;
      break;
    }
    initErrorState.toLog();
    log('\n$state');
  }  

/// Calls the [deleteDB] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState] 
  Future<void> deleteDB() async {
    final ErrorState deleteErrorState = await _databaseService.deleteDB();
    switch (deleteErrorState.state) {
      case null:
      state = DatabaseState.terminated;
      break;
      case DatabaseError.exception:
      state = DatabaseState.error;
      break;
    }
  }

/// Calls the [closeDB] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState] 
  Future<void> closeDB() async {
    final ErrorState closeErrorState = await _databaseService.closeDB();
    switch (closeErrorState.state) {
      case null:
      state = DatabaseState.closed;
      break;
      case DatabaseError.databaseAlreadyClosed:
      state = DatabaseState.closed;
      closeErrorState.toLog();
      break;
      case DatabaseError.notInitialized:
      state = DatabaseState.error;
      closeErrorState.toLog();
      break;
      case DatabaseError.exception:
      state = DatabaseState.error;
      break;
    }
    closeErrorState.toLog();
    log('\n$state');
  }

//-------------------------------------------------------------------------------------------------------


//  USER------------------------------------------------------------------------------------------------- 

/// Calls the [insertStandardUser] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
  Future<void> insertStandardUser(StandardUserModel user) async {
    final (ErrorState insertErrorState, int rowID) = await _databaseService.insertStandardUser(user);
    switch (insertErrorState.state) {
      case null:
      state = DatabaseState.nominal;
      break;
      case DatabaseError.openFailed:
      state = DatabaseState.error;
      insertErrorState.toLog();
      break;
      case DatabaseError.syntaxError:
      state = DatabaseState.error;
      insertErrorState.toLog();
      break;
      case DatabaseError.userAlreadyInDatabase:
      state = DatabaseState.nominal;
      insertErrorState.toLog();
      break;
      case DatabaseError.exception:
      state = DatabaseState.error;
      break;
    }
  }

/// Calls the [insertCurrentUser] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
  Future<void> insertCurrentUser() async {
    final ErrorState insertErrorState = await _databaseService.insertCurrentUser();
    switch (insertErrorState.state) {
      case null:
      state = DatabaseState.nominal;
      break;
      case DatabaseError.openFailed:
      state = DatabaseState.error;
      insertErrorState.toLog();
      break;
      case DatabaseError.syntaxError:
      state = DatabaseState.error;
      insertErrorState.toLog();
      break;
      case DatabaseError.userAlreadyInDatabase:
      state = DatabaseState.nominal;
      insertErrorState.toLog();
      break;
      case DatabaseError.userNotFound:
      state = DatabaseState.nominal;
      insertErrorState.toLog();
      break;
      case DatabaseError.notLoggedIn:
      await closeDB();
      await _firebaseAuthNotifier.logout();
      insertErrorState.toLog();
      break;
      case DatabaseError.exception:
      state = DatabaseState.error;
      break;
    }
  }

/// Calls the [getStandardUserByID] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
  Future<(ErrorState,StandardUserModel?)> getStandardUserByID(String userID) async {
    final (ErrorState getErrorState, StandardUserModel? user) = await _databaseService.getStandardUserByID(userID);
    switch (getErrorState.state) {
      case null:
      state = DatabaseState.nominal;
      break;
      case DatabaseError.openFailed:
      state = DatabaseState.error;
      getErrorState.toLog();
      break;
      case DatabaseError.syntaxError:
      state = DatabaseState.error;
      getErrorState.toLog();
      break;
      case DatabaseError.userNotFound:
      state = DatabaseState.nominal;
      getErrorState.toLog();
      break;
      case DatabaseError.exception:
      state = DatabaseState.error;
      break;
    }
    return (getErrorState, user);
  }

//-------------------------------------------------------------------------------------------------------


//  PROJECT LIBRARY--------------------------------------------------------------------------------------

/// Calls the [getCurrentProjectLibraryList] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<(ErrorState,List<ProjectLibraryModel>?)> getCurrentProjectLibraryList() async {
  final (
    ErrorState getErrorState, 
    List<ProjectLibraryModel>? projectLibraryList) = await _databaseService.getCurrentProjectLibraryList();
  switch (getErrorState.state) {
    case null:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    break;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    break;
    case DatabaseError.userHasNoProjectLibrary:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    break;
    case DatabaseError.exception:
    state = DatabaseState.error;
    break;
  }
  getErrorState.toLog();
  return (getErrorState, projectLibraryList);
}

/// Calls the [insertCurrentProjectLibrary] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<ErrorState> insertCurrentProjectLibrary(String name, String? tag) async {
  state = DatabaseState.loading;
  
  final ErrorState insertErrorState = await _databaseService.insertCurrentProjectLibrary(name, tag);
  
  switch (insertErrorState.state) {
    case null:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    break;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    break;
    case DatabaseError.counterNotFound:
    state = DatabaseState.error;
    break;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    break;
    case DatabaseError.emptyEntry:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.exception:
    state = DatabaseState.error;
    break;
  }
  
  insertErrorState.toLog();
  return insertErrorState;
}

/// Calls the [getCurrentProjectLibrary] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<(ErrorState,ProjectLibraryModel?)> getCurrentProjectLibrary(int projectLibraryID) async {
  
  final (
    ErrorState getErrorState, 
    ProjectLibraryModel? projectLibrary
    ) =  await _databaseService.getCurrentProjectLibrary(projectLibraryID);
  
  switch (getErrorState.state) {
    case null:
    state = DatabaseState.nominal;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    case DatabaseError.projectLibraryNotFound:
    state = DatabaseState.nominal;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    case DatabaseError.exception:
    state = DatabaseState.error;

  }

  getErrorState.toLog();
  return (getErrorState, projectLibrary);
}

/// Calls the [deleteCurrentProjectLibrary] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<ErrorState> deleteCurrentProjectLibrary(int projectLibraryID) async {
    final ErrorState deleteErrorState =  await _databaseService.deleteCurrentProjectLibrary(projectLibraryID);
  
  switch (deleteErrorState.state) {
    case null:
    state = DatabaseState.nominal;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    case DatabaseError.exception:
    state = DatabaseState.error;

  }

  deleteErrorState.toLog();
  return deleteErrorState;
}

//-------------------------------------------------------------------------------------------------------


//  PROJECT LIBRARY CONTAINS----------------------------------------------------------------------------

/// Calls the [insertCurrentProjectLibraryContains] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<ErrorState> insertCurrentProjectLibraryContains(String routeID, int projectLibraryID) async {
  
  final ErrorState insertErrorState = await _databaseService.insertCurrentProjectLibraryContains(routeID, projectLibraryID);
  
  switch (insertErrorState.state) {
    case null:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    break;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    break;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    break;
    case DatabaseError.exception:
    state = DatabaseState.error;
    break;
  }
  
  insertErrorState.toLog();
  return insertErrorState;
}

/// Calls the [deleteCurrentProjectLibraryContains] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<ErrorState> deleteCurrentProjectLibraryContains(String routeID, int projectLibraryID) async {
  
  final ErrorState errorState = await _databaseService.deleteCurrentProjectLibraryContains(routeID, projectLibraryID);
  
  switch (errorState.state) {
    case null:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    break;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    break;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    break;
    case DatabaseError.exception:
    state = DatabaseState.error;
    break;
  }
  
  errorState.toLog();
  return errorState;
}

//------------------------------------------------------------------------------------------------------


//  BOULDERING ROUTE------------------------------------------------------------------------------------

/// Calls the [getProjectBoulderingRouteList] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<(ErrorState,List<BoulderingRouteModel>?)> getProjectBoulderingRouteList(int projectLibraryID) async {
    
    final (
    ErrorState getErrorState, 
    List<BoulderingRouteModel>? boulderingRouteList) =  await _databaseService.getProjectBoulderingRouteList(projectLibraryID
    );
  
  switch (getErrorState.state) {
    case null:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    break;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    break;
    case DatabaseError.boulderingRouteListNotFound:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    break;
    case DatabaseError.exception:
    state = DatabaseState.error;
    break;
  }
  
  getErrorState.toLog();
  return (getErrorState, boulderingRouteList);
}

/// Calls the [insertBoulderingRoute] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<ErrorState> insertBoulderingRoute(BoulderingRouteModel boulderingRoute) async {
  final ErrorState insertErrorState = await _databaseService.insertBoulderingRoute(boulderingRoute);
  switch (insertErrorState.state) {
    case null:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    break;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    break;
    case DatabaseError.exception:
    state = DatabaseState.error;
    break;
  }
  insertErrorState.toLog();
  return insertErrorState;
}

/// Calls the [getCurrentArchivedBoulderingRouteList] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<(ErrorState,List<String>?,List<BoulderingRouteModel>?)> getCurrentArchivedBoulderingRouteList() async {
final (
    ErrorState getErrorState,
    List<String>? dateList,
    List<BoulderingRouteModel>? boulderingRouteList) =  await _databaseService.getCurrentArchivedBoulderingRouteList();
  switch (getErrorState.state) {
    case null:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    break;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    break;
    case DatabaseError.archivedBoulderingRouteListNotFound:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    break;
    case DatabaseError.exception:
    state = DatabaseState.error;
    break;
  }
  getErrorState.toLog();
  return (getErrorState,dateList,boulderingRouteList);
}

//------------------------------------------------------------------------------------------------------


//  PROJECT ARCHIVE CONTAINS----------------------------------------------------------------------------

/// Calls the [archiveCurrentBoulderingRoute] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<ErrorState> archiveCurrentBoulderingRoute(String routeID) async {  
  
  ErrorState getErrorState =  await _databaseService.archiveCurrentBoulderingRoute(routeID);
  
  switch (getErrorState.state) {
    case null:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    break;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    break;
    case DatabaseError.archivedBoulderingRouteListNotFound:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    break;
    case DatabaseError.exception:
    state = DatabaseState.error;
    break;
  }
  
  getErrorState.toLog();
  return getErrorState;
}

//------------------------------------------------------------------------------------------------------


//  BOULDERING WALL LINK--------------------------------------------------------------------------------

/// Calls the [getCurrentBoulderingWallLinkList] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<(ErrorState,List<BoulderingWallLinkModel>?)> getCurrentBoulderingWallLinkList() async {
  
  final (
    ErrorState getErrorState,
    List<BoulderingWallLinkModel>? boulderingWallLinkList) = await _databaseService.getCurrentBoulderingWallLinkList();
  
  switch (getErrorState.state) {
    case null:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    break;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    break;
    case DatabaseError.boulderingWallLinkListNotFound:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    break;
    case DatabaseError.exception:
    state = DatabaseState.error;
    break;
  }
  
  getErrorState.toLog();
  return (getErrorState, boulderingWallLinkList);
}

/// Calls the [insertCurrentBoulderingWallLink] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<ErrorState> insertCurrentBoulderingWallLink(
  String boulderingWallID, 
  String displayName,
  String city,
  String postcode,
  String street,
  ) async {
  
  final ErrorState errorState = await _databaseService.insertCurrentBoulderingWallLink(
    boulderingWallID, 
    displayName,
    city,
    postcode,
    street
    );
  
  switch (errorState.state) {
    case null:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    break;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    break;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    break;
    case DatabaseError.exception:
    state = DatabaseState.error;
    break;
  }

  errorState.toLog();
  return errorState;
}

/// Calls the [deleteCurrentBoulderingWallLink] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<ErrorState> deleteCurrentBoulderingWallLink(String boulderingWallID) async {
  ErrorState deleteErrorState = await _databaseService.deleteCurrentBoulderingWallLink(boulderingWallID);
  
  switch (deleteErrorState.state) {
    case null:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    break;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    break;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    break;
    case DatabaseError.exception:
    state = DatabaseState.error;
    break;
  }
  
  deleteErrorState.toLog();
  return deleteErrorState;
}

/// Calls the [isCurrentBoulderingWallLinked] method from the [DatabaseService] and changes the internal [state] of the [DatabaseNotifier]
/// depending on the [ErrorState]
Future<(ErrorState,bool)> isCurrentBoulderingWallLinked(String boulderingWallID) async {
  
  final (
    ErrorState errorState, 
    bool result
    ) = await _databaseService.isCurrentBoulderingWallLinked(boulderingWallID);
  
  switch (errorState.state) {
    case null:
    state = DatabaseState.nominal;
    break;
    case DatabaseError.openFailed:
    state = DatabaseState.error;
    break;
    case DatabaseError.syntaxError:
    state = DatabaseState.error;
    break;
    case DatabaseError.notLoggedIn:
    await closeDB();
    await _firebaseAuthNotifier.logout();
    break;
    case DatabaseError.exception:
    state = DatabaseState.error;
    break;
  }
  
  errorState.toLog();
  return (errorState, result);
}

//------------------------------------------------------------------------------------------------------
}

