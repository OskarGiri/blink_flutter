import 'package:blink_flutter/core/realtime/socket_providers.dart';
import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/token_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_about_me_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_edit_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_manage_photos_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_pages.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_setting_page.dart';
import '../../../../mocks/mock_chat_repository.dart';
import '../../../../mocks/mock_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

ProfileHiveModel _profile({
  String userId = 'user-1',
  String fullName = 'Alex Doe',
  String? dob,
  String? gender,
  List<String>? photos,
  String? bio,
}) {
  return ProfileHiveModel(
    userId: userId,
    fullName: fullName,
    dob: dob,
    gender: gender,
    lookingFor: 'Friendship',
    photos: photos,
    bio: bio,
  );
}

Future<void> _pumpProfilePage(
  WidgetTester tester, {
  required MockHiveService hive,
  required MockUserSessionService session,
  required MockTokenService token,
  required MockSocketService socket,
  ProfileHiveModel? profile,
  String? currentUserId = 'user-1',
}) async {
  final box = MockProfileHiveBox();
  final network = MockNetworkInfo();
  final notifier = ValueNotifier<Box<ProfileHiveModel>>(box);

  await tester.binding.setSurfaceSize(const Size(1080, 1920));
  when(() => session.getCurrentUserId()).thenReturn(currentUserId);
  when(() => hive.profileListenable()).thenReturn(notifier);
  when(() => hive.getProfileByUserIdSync(any())).thenReturn(profile);
  when(() => hive.getProfileByUserId(any())).thenAnswer((_) async => profile);
  when(() => network.isConnected).thenAnswer((_) async => false);
  when(() => token.removeToken()).thenAnswer((_) async {});
  when(() => session.clearSession()).thenAnswer((_) async {});
  when(() => socket.disconnect()).thenReturn(null);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hive),
        networkInfoProvider.overrideWithValue(network),
        userSessionServiceProvider.overrideWithValue(session),
        tokenServiceProvider.overrideWithValue(token),
        socketServiceProvider.overrideWithValue(socket),
      ],
      child: const MaterialApp(home: ProfilePage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Profile Screen Widget Tests', () {
    late MockHiveService mockHive;
    late MockUserSessionService mockSession;
    late MockTokenService mockToken;
    late MockSocketService mockSocket;

    setUp(() {
      mockHive = MockHiveService();
      mockSession = MockUserSessionService();
      mockToken = MockTokenService();
      mockSocket = MockSocketService();
    });

    testWidgets('1. renders default user name when profile missing', (
      tester,
    ) async {
      await _pumpProfilePage(
        tester,
        hive: mockHive,
        session: mockSession,
        token: mockToken,
        socket: mockSocket,
        profile: null,
      );

      expect(find.text('User'), findsOneWidget);
    });

    testWidgets('2. renders profile name when available', (tester) async {
      await _pumpProfilePage(
        tester,
        hive: mockHive,
        session: mockSession,
        token: mockToken,
        socket: mockSocket,
        profile: _profile(fullName: 'Taylor Swift'),
      );

      expect(find.text('Taylor Swift'), findsOneWidget);
    });

    testWidgets('3. renders settings icon button', (tester) async {
      await _pumpProfilePage(
        tester,
        hive: mockHive,
        session: mockSession,
        token: mockToken,
        socket: mockSocket,
      );
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('4. renders Edit profile button', (tester) async {
      await _pumpProfilePage(
        tester,
        hive: mockHive,
        session: mockSession,
        token: mockToken,
        socket: mockSocket,
      );
      expect(find.text('Edit profile'), findsOneWidget);
    });

    testWidgets('5. renders profile completion helper text', (tester) async {
      await _pumpProfilePage(
        tester,
        hive: mockHive,
        session: mockSession,
        token: mockToken,
        socket: mockSocket,
      );
      expect(
        find.text('Complete your profile to be seen by more people!'),
        findsOneWidget,
      );
    });

    testWidgets('6. no profile shows 0 percent completion', (tester) async {
      await _pumpProfilePage(
        tester,
        hive: mockHive,
        session: mockSession,
        token: mockToken,
        socket: mockSocket,
        profile: null,
      );
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('7. profile with bio shows 95 percent completion', (
      tester,
    ) async {
      await _pumpProfilePage(
        tester,
        hive: mockHive,
        session: mockSession,
        token: mockToken,
        socket: mockSocket,
        profile: _profile(
          fullName: 'Alex',
          dob: '2000-01-01',
          gender: 'male',
          bio: 'hello',
        ),
      );
      expect(find.text('95%'), findsOneWidget);
    });

    testWidgets('8. renders add photos enhancement card', (tester) async {
      await _pumpProfilePage(
        tester,
        hive: mockHive,
        session: mockSession,
        token: mockToken,
        socket: mockSocket,
      );
      expect(find.text('Add at least 4 photos'), findsOneWidget);
    });

    testWidgets('9. renders add about me enhancement card', (tester) async {
      await _pumpProfilePage(
        tester,
        hive: mockHive,
        session: mockSession,
        token: mockToken,
        socket: mockSocket,
      );
      expect(find.text('Add "About Me"'), findsOneWidget);
    });

    testWidgets('10. renders Logout button', (tester) async {
      await _pumpProfilePage(
        tester,
        hive: mockHive,
        session: mockSession,
        token: mockToken,
        socket: mockSocket,
      );
      expect(find.text('Logout'), findsOneWidget);
    });
  });
}
