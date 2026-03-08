import 'dart:async';

import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/message_remote_datasource_provider.dart';
import 'package:blink_flutter/features/auth/presentation/pages/chat_pages.dart';
import 'package:blink_flutter/core/realtime/socket_providers.dart';
import '../../../../mocks/mock_chat_repository.dart';
import '../../../../mocks/mock_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

Future<void> _pumpChatPage(
  WidgetTester tester, {
  required MockMessagesRemoteDatasource messages,
  required MockUserSessionService session,
  Stream<Map<String, dynamic>>? stream,
  String? avatarUrl,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        messagesRemoteDatasourceProvider.overrideWithValue(messages),
        userSessionServiceProvider.overrideWithValue(session),
        messageNewStreamProvider.overrideWith(
          (_) => stream ?? const Stream.empty(),
        ),
      ],
      child: MaterialApp(
        home: ChatPage(matchId: 'match-1', title: 'Alex', avatarUrl: avatarUrl),
      ),
    ),
  );

  await tester.pump();
  if (settle) {
    await tester.pumpAndSettle();
  }
}

void main() {
  group('Chat Screen Widget Tests', () {
    late MockMessagesRemoteDatasource mockMessages;
    late MockUserSessionService mockSession;

    setUp(() {
      mockMessages = MockMessagesRemoteDatasource();
      mockSession = MockUserSessionService();

      when(() => mockSession.getCurrentUserId()).thenReturn('me-1');
      when(
        () => mockMessages.getMessages(matchId: 'match-1', limit: 80),
      ).thenAnswer(
        (_) async => [
          {
            'id': 'm1',
            'senderId': 'me-1',
            'text': 'Hello from me',
            'createdAt': '2026-01-01T00:00:00.000Z',
          },
          {
            'id': 'm2',
            'senderId': 'other-1',
            'text': 'Hello from other',
            'createdAt': '2026-01-01T00:01:00.000Z',
          },
        ],
      );
      when(
        () => mockMessages.sendMessage(
          matchId: 'match-1',
          text: any(named: 'text'),
        ),
      ).thenAnswer((_) async => {'ok': true});
    });

    testWidgets('1. renders app bar title', (tester) async {
      await _pumpChatPage(tester, messages: mockMessages, session: mockSession);
      expect(find.text('Alex'), findsOneWidget);
    });

    testWidgets('2. renders back button', (tester) async {
      await _pumpChatPage(tester, messages: mockMessages, session: mockSession);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('3. renders refresh button', (tester) async {
      await _pumpChatPage(tester, messages: mockMessages, session: mockSession);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('4. builds chat page without settling', (tester) async {
      await _pumpChatPage(
        tester,
        messages: mockMessages,
        session: mockSession,
        settle: false,
      );
      expect(find.byType(ChatPage), findsOneWidget);
    });

    testWidgets('5. renders loaded messages', (tester) async {
      await _pumpChatPage(tester, messages: mockMessages, session: mockSession);
      expect(find.text('Hello from me'), findsOneWidget);
      expect(find.text('Hello from other'), findsOneWidget);
    });

    testWidgets('6. shows error text when initial load fails', (tester) async {
      when(
        () => mockMessages.getMessages(matchId: 'match-1', limit: 80),
      ).thenThrow(Exception('load fail'));

      await _pumpChatPage(tester, messages: mockMessages, session: mockSession);

      expect(find.textContaining('Failed to load messages'), findsOneWidget);
    });

    testWidgets('7. renders message input field', (tester) async {
      await _pumpChatPage(tester, messages: mockMessages, session: mockSession);
      expect(
        find.widgetWithText(TextField, 'Type a message ...'),
        findsOneWidget,
      );
    });

    testWidgets('8. renders SEND button', (tester) async {
      await _pumpChatPage(tester, messages: mockMessages, session: mockSession);
      expect(find.text('SEND'), findsOneWidget);
    });

    testWidgets('9. text field accepts input', (tester) async {
      await _pumpChatPage(tester, messages: mockMessages, session: mockSession);

      await tester.enterText(find.byType(TextField), 'new message');
      await tester.pump();

      expect(find.text('new message'), findsOneWidget);
    });

    testWidgets('10. tapping SEND calls remote sendMessage', (tester) async {
      await _pumpChatPage(tester, messages: mockMessages, session: mockSession);

      await tester.enterText(find.byType(TextField), 'my outbound message');
      await tester.tap(find.text('SEND'));
      await tester.pump();

      verify(
        () => mockMessages.sendMessage(
          matchId: 'match-1',
          text: 'my outbound message',
        ),
      ).called(1);
    });
  });
}
