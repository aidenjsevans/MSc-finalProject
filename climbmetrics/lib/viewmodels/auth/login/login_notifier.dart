import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The [LoginNotifier] provides various methods that can change its [state]
class LoginNotifier  extends StateNotifier<ErrorState> {
  
  LoginNotifier() : super(ErrorState.none());

  void setState(ErrorState newState) {
    state = newState;
  }

  void reset() {
    state = ErrorState.none();
  }
}