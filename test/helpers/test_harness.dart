import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:rehab_flow/core/storage/local_storage_service.dart';
import 'package:rehab_flow/features/auth/data/repositories/auth_repository.dart';
import 'package:rehab_flow/features/exercises/data/models/exercise_model.dart';
import 'package:rehab_flow/features/exercises/data/repositories/exercise_repository.dart';
import 'package:rehab_flow/features/favorites/data/repositories/favorites_repository.dart';
import 'package:rehab_flow/features/favorites/presentation/controllers/favorites_controller.dart';
import 'package:rehab_flow/network/api_client.dart';

/// Controllable connectivity for unit / widget / integration tests.
class FakeNetworkInfo extends NetworkInfo {
  FakeNetworkInfo({this.online = false});

  bool online;

  @override
  Future<bool> get isConnected async => online;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

/// Boots Hive + GetX core services the same way production [main] does.
class TestHarness {
  TestHarness._(this.tempDir);

  final Directory tempDir;

  late final LocalStorageService storage;
  late final FakeNetworkInfo networkInfo;
  late final ApiClient apiClient;
  late final AuthRepository authRepository;
  late final ExerciseRepository exerciseRepository;
  late final FavoritesRepository favoritesRepository;

  static Future<TestHarness> create({bool online = false}) async {
    Get.reset();
    final dir = await Directory.systemTemp.createTemp('rehab_flow_test_');
    final harness = TestHarness._(dir);
    harness.storage = await LocalStorageService.initForTest(dir.path);
    harness.networkInfo = FakeNetworkInfo(online: online);
    harness.apiClient = ApiClient();
    harness.authRepository = AuthRepositoryImpl(harness.storage);
    harness.exerciseRepository = ExerciseRepositoryImpl(
      storage: harness.storage,
      apiClient: harness.apiClient,
      networkInfo: harness.networkInfo,
    );
    harness.favoritesRepository = FavoritesRepositoryImpl(harness.storage);

    Get.put(harness.storage, permanent: true);
    Get.put<NetworkInfo>(harness.networkInfo, permanent: true);
    Get.put(harness.apiClient, permanent: true);
    Get.put<AuthRepository>(harness.authRepository, permanent: true);
    Get.put<ExerciseRepository>(harness.exerciseRepository, permanent: true);
    Get.put<FavoritesRepository>(harness.favoritesRepository, permanent: true);
    Get.put(
      FavoritesController(
        favoritesRepository: harness.favoritesRepository,
        exerciseRepository: harness.exerciseRepository,
      ),
      permanent: true,
    );

    return harness;
  }

  Future<void> dispose() async {
    Get.reset();
    await LocalStorageService.closeForTest();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  }
}

ExerciseModel buildExercise({
  String id = '1',
  String name = 'Seated Knee Extension',
  String category = 'Strength',
  String difficulty = 'Beginner',
  String targetMuscle = 'Quadriceps',
  List<String> relatedIds = const [],
}) {
  return ExerciseModel(
    id: id,
    name: name,
    category: category,
    difficulty: difficulty,
    targetMuscle: targetMuscle,
    description: 'A rehab exercise description.',
    instructions: 'Step one. Step two. Step three.',
    equipment: 'None',
    relatedIds: relatedIds,
  );
}
