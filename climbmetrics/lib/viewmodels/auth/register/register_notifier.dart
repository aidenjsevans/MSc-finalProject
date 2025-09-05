import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The [RegisterNotifier] provides methods that can change its [state]
class RegisterNotifier  extends StateNotifier<ErrorState> {
  
  RegisterNotifier() : super(ErrorState.none());

  void setState(ErrorState newState) {
    state = newState;
  }

  void reset() {
    state = ErrorState.none();
  }
}