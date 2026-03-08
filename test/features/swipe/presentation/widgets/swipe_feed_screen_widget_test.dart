import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/core/services/sync/swipe_sync_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/discovery_remote_datasource_provider.dart';
import 'package:blink_flutter/features/auth/data/datasources/swipe_datasource_provider.dart';
import 'package:blink_flutter/features/auth/presentation/pages/discovery_page.dart';
import '../../../../mocks/mock_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

List<Map<String, dynamic>> _cards({int count = 2}) {
  final values = <Map<String, dynamic>>[];
  for (var i = 0; i < count; i++) {
    values.add({
      '_id': 'target-$i',
      'username': 'User $i',
      'fullName': 'User $i',
      'dob': '2000-01-01',
      'photos': <String>[],
    });
  }
  return values;
}

Future<void> _pumpDiscoveryPage(
  WidgetTester tester, {
  required MockNetworkInfo network,
  required MockHiveService hive,
  required MockUserSessionService session,
  required MockDiscoveryRemoteDatasource discoveryRemote,
  required MockSwipeRemoteDatasource swipeRemote,
  required MockSwipeSyncService syncService,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        networkInfoProvider.overrideWithValue(network),
        hiveServiceProvider.overrideWithValue(hive),
        userSessionServiceProvider.overrideWithValue(session),
        discoveryRemoteDatasourceProvider.overrideWithValue(discoveryRemote),
        swipeRemoteDatasourceProvider.overrideWithValue(swipeRemote),
        swipeSyncServiceProvider.overrideWithValue(syncService),
      ],
      child: const MaterialApp(home: DiscoveryPage()),
    ),
  );

  if (settle) {
    await tester.pumpAndSettle();
  }
}

void main() {
  group('Swipe Feed Screen Widget Tests', () {
    late MockNetworkInfo mockNetwork;
    late MockHiveService mockHive;
    late MockUserSessionService mockSession;
    late MockDiscoveryRemoteDatasource mockDiscoveryRemote;
    late MockSwipeRemoteDatasource mockSwipeRemote;
    late MockSwipeSyncService mockSyncService;

    setUp(() {
      mockNetwork = MockNetworkInfo();
      mockHive = MockHiveService();
      mockSession = MockUserSessionService();
      mockDiscoveryRemote = MockDiscoveryRemoteDatasource();
      mockSwipeRemote = MockSwipeRemoteDatasource();
      mockSyncService = MockSwipeSyncService();

      when(() => mockSession.getCurrentUserId()).thenReturn('user-1');
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(
        () => mockSyncService.syncPendingSwipes(any()),
      ).thenAnswer((_) async => 0);
      when(
        () => mockDiscoveryRemote.getDiscovery(),
      ).thenAnswer((_) async => _cards());
      when(
        () => mockHive.saveDiscoveryCache(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockHive.getDiscoveryCache(any()),
      ).thenAnswer((_) async => _cards());
      when(
        () => mockSwipeRemote.swipe(
          targetUserId: any(named: 'targetUserId'),
          action: any(named: 'action'),
        ),
      ).thenAnswer((_) async => {'matched': false});
      when(
        () => mockHive.enqueueSwipe(
          userId: any(named: 'userId'),
          targetUserId: any(named: 'targetUserId'),
          action: any(named: 'action'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockHive.getProfileByUserId(any()),
      ).thenAnswer((_) async => null);
    });

    testWidgets('1. shows loading indicator while first frame loads', (
      tester,
    ) async {
      await _pumpDiscoveryPage(
        tester,
        network: mockNetwork,
        hive: mockHive,
        session: mockSession,
        discoveryRemote: mockDiscoveryRemote,
        swipeRemote: mockSwipeRemote,
        syncService: mockSyncService,
        settle: false,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('2. shows empty state when no cards are available', (
      tester,
    ) async {
      when(
        () => mockDiscoveryRemote.getDiscovery(),
      ).thenAnswer((_) async => <dynamic>[]);

      await _pumpDiscoveryPage(
        tester,
        network: mockNetwork,
        hive: mockHive,
        session: mockSession,
        discoveryRemote: mockDiscoveryRemote,
        swipeRemote: mockSwipeRemote,
        syncService: mockSyncService,
      );

      expect(
        find.text('No more people. Create more users in DB.'),
        findsOneWidget,
      );
    });

    testWidgets('3. renders top card name from online data', (tester) async {
      await _pumpDiscoveryPage(
        tester,
        network: mockNetwork,
        hive: mockHive,
        session: mockSession,
        discoveryRemote: mockDiscoveryRemote,
        swipeRemote: mockSwipeRemote,
        syncService: mockSyncService,
      );

      expect(find.textContaining('User 0'), findsWidgets);
    });

    testWidgets('4. offline mode loads from cached discovery list', (
      tester,
    ) async {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);
      when(
        () => mockHive.getDiscoveryCache('user-1'),
      ).thenAnswer((_) async => _cards(count: 1));

      await _pumpDiscoveryPage(
        tester,
        network: mockNetwork,
        hive: mockHive,
        session: mockSession,
        discoveryRemote: mockDiscoveryRemote,
        swipeRemote: mockSwipeRemote,
        syncService: mockSyncService,
      );

      expect(find.textContaining('User 0'), findsWidgets);
      verify(() => mockHive.getDiscoveryCache('user-1')).called(1);
    });

    testWidgets('5. online fetch failure falls back to cache', (tester) async {
      when(
        () => mockDiscoveryRemote.getDiscovery(),
      ).thenThrow(Exception('network failure'));
      when(
        () => mockHive.getDiscoveryCache('user-1'),
      ).thenAnswer((_) async => _cards(count: 1));

      await _pumpDiscoveryPage(
        tester,
        network: mockNetwork,
        hive: mockHive,
        session: mockSession,
        discoveryRemote: mockDiscoveryRemote,
        swipeRemote: mockSwipeRemote,
        syncService: mockSyncService,
      );

      expect(find.textContaining('User 0'), findsWidgets);
      verify(() => mockHive.getDiscoveryCache('user-1')).called(1);
    });

    testWidgets('6. renders pass and like action buttons', (tester) async {
      await _pumpDiscoveryPage(
        tester,
        network: mockNetwork,
        hive: mockHive,
        session: mockSession,
        discoveryRemote: mockDiscoveryRemote,
        swipeRemote: mockSwipeRemote,
        syncService: mockSyncService,
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('7. renders verified icon on card', (tester) async {
      await _pumpDiscoveryPage(
        tester,
        network: mockNetwork,
        hive: mockHive,
        session: mockSession,
        discoveryRemote: mockDiscoveryRemote,
        swipeRemote: mockSwipeRemote,
        syncService: mockSyncService,
      );

      expect(find.byIcon(Icons.verified), findsWidgets);
    });

    testWidgets('8. tapping like removes current card', (tester) async {
      await _pumpDiscoveryPage(
        tester,
        network: mockNetwork,
        hive: mockHive,
        session: mockSession,
        discoveryRemote: mockDiscoveryRemote,
        swipeRemote: mockSwipeRemote,
        syncService: mockSyncService,
      );

      expect(find.textContaining('User 0'), findsWidgets);
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      expect(find.textContaining('User 1'), findsWidgets);
    });

    testWidgets('9. tapping pass removes current card', (tester) async {
      await _pumpDiscoveryPage(
        tester,
        network: mockNetwork,
        hive: mockHive,
        session: mockSession,
        discoveryRemote: mockDiscoveryRemote,
        swipeRemote: mockSwipeRemote,
        syncService: mockSyncService,
      );

      expect(find.textContaining('User 0'), findsWidgets);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.textContaining('User 1'), findsWidgets);
    });

    testWidgets('10. online like calls swipe API with like action', (
      tester,
    ) async {
      await _pumpDiscoveryPage(
        tester,
        network: mockNetwork,
        hive: mockHive,
        session: mockSession,
        discoveryRemote: mockDiscoveryRemote,
        swipeRemote: mockSwipeRemote,
        syncService: mockSyncService,
      );

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      verify(
        () => mockSwipeRemote.swipe(targetUserId: 'target-0', action: 'like'),
      ).called(1);
    });
  });
}
