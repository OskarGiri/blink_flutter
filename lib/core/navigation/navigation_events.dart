import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NavigationCommand { goToMatches }

final navigationCommandProvider =
    NotifierProvider<NavigationCommandNotifier, NavigationCommand?>(
      NavigationCommandNotifier.new,
    );

class NavigationCommandNotifier extends Notifier<NavigationCommand?> {
  @override
  NavigationCommand? build() => null;

  void goToMatches() {
    state = NavigationCommand.goToMatches;
  }

  void consume() {
    state = null;
  }
}
