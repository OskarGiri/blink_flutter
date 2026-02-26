import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/swipe_datasource_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final swipeSyncServiceProvider = Provider<SwipeSyncService>((ref) {
  return SwipeSyncService(ref);
});

class SwipeSyncService {
  final Ref _ref;
  SwipeSyncService(this._ref);

  Future<int> syncPendingSwipes(String userId) async {
    final hive = _ref.read(hiveServiceProvider);
    final api = _ref.read(swipeRemoteDatasourceProvider);

    final pending = await hive.getPendingSwipes(userId);
    if (pending.isEmpty) return 0;

    int synced = 0;

    for (final s in List<Map<String, dynamic>>.from(pending)) {
      final id = (s["id"] ?? "").toString();
      final target = (s["targetUserId"] ?? "").toString();
      final action = (s["action"] ?? "").toString();

      if (id.isEmpty || target.isEmpty || action.isEmpty) {
        await hive.removePendingSwipeById(userId, id);
        continue;
      }

      try {
        await api.swipe(targetUserId: target, action: action);
        await hive.removePendingSwipeById(userId, id);
        synced++;
      } catch (_) {
        break; // stop if still offline/server error
      }
    }

    return synced;
  }
}
