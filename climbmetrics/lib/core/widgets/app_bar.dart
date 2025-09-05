import 'package:climbmetrics/viewmodels/auth/auth_provider.dart';
import 'package:climbmetrics/viewmodels/auth/auth_state.dart';
import 'package:climbmetrics/viewmodels/database/database_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrimaryAppBar extends ConsumerWidget implements PreferredSizeWidget {

  final String title;

  const PrimaryAppBar({
    super.key,
    required this.title
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firebaseAuthNotifierProvider);
    final authNotifier = ref.read(firebaseAuthNotifierProvider.notifier);
    final databaseNotifier = ref.read(databaseNotifierProvider.notifier);
    List<Widget> actions = [];
    if (authState == AuthState.loggedIn) {
      final IconButton action = IconButton(
        icon: const Icon(Icons.logout_rounded),
        onPressed: () {
          databaseNotifier.closeDB();
          authNotifier.logout();
        }
      );
      actions.add(action);
    }
    if (authState == AuthState.emailNotVerified) {
      final IconButton action = IconButton(
        icon: const Icon(Icons.refresh_rounded),
        onPressed: () {
          authNotifier.reload();
        }
      );
      actions.add(action);
    }
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: actions,
    );
  }
}
