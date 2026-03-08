import 'package:blink_flutter/core/services/connectivity/network_info.dart';
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/token_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/core/services/sync/swipe_sync_service.dart';
import 'package:blink_flutter/features/auth/data/datasources/discovery_remote_datasource.dart';
import 'package:blink_flutter/features/auth/data/datasources/swipe_remote_datasource.dart';
import 'package:hive/hive.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:mocktail/mocktail.dart';

class MockHiveService extends Mock implements HiveService {}

class MockUserSessionService extends Mock implements UserSessionService {}

class MockTokenService extends Mock implements TokenService {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockSwipeSyncService extends Mock implements SwipeSyncService {}

class MockDiscoveryRemoteDatasource extends Mock
    implements DiscoveryRemoteDatasource {}

class MockSwipeRemoteDatasource extends Mock implements SwipeRemoteDatasource {}

class MockProfileHiveBox extends Mock implements Box<ProfileHiveModel> {}
