import 'package:blink_flutter/core/realtime/socket_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/messages_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockMessagesRemoteDatasource extends Mock
    implements MessagesRemoteDatasource {}

class MockSocketService extends Mock implements SocketService {}
