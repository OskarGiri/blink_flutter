import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardTabIndexProvider =
    NotifierProvider<DashboardTabIndexNotifier, int>(
      DashboardTabIndexNotifier.new,
    );

class DashboardTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    if (index < 0 || index > 2) return;
    state = index;
  }
}
