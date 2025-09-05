import 'dart:developer' show log;

import 'package:climbmetrics/core/exceptions/database_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StandardUserModel {
  
  final String userID;
  final String email;
  final String? username;

  StandardUserModel({
    required this.userID,
    required this.email,
    this.username
  });

  factory StandardUserModel.fromMap(Map<String,dynamic> map) {
    return StandardUserModel(
      userID: map['user_id'], 
      email: map['email'],
      username: map['username']
    );
  }

  factory StandardUserModel.fromFirebaseUser(User user) {
    if (user.email == null) {
      log('EmailFieldRequired');
      throw EmailFieldRequiredException();
    }
    return StandardUserModel(
      userID: user.uid, 
      email: user.email!
    );
  }

  factory StandardUserModel.placeholder() {
    return StandardUserModel(
      userID: 'placeholder', 
      email: 'placeholder'
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userID,
      'email': email,
      'username': username
    };
  }
}