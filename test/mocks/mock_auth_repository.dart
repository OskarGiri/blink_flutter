import 'package:blink_flutter/features/auth/domain/repositories/auth_recovery_repository.dart';
import 'package:blink_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockAuthRecoveryRepository extends Mock
    implements AuthRecoveryRepository {}
