import 'package:get/get.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/exercises/data/repositories/exercise_repository.dart';
import '../../features/favorites/data/repositories/favorites_repository.dart';
import '../../features/favorites/presentation/controllers/favorites_controller.dart';
import '../../network/api_client.dart';
import '../storage/local_storage_service.dart';

/// Central registration for app services.
///
/// Data/domain objects are constructed with **constructor injection**; GetX
/// only holds the singletons so presentation code can resolve controllers via
/// [GetView] / [Get.find] without building its own service graph.
class ServiceLocator {
  ServiceLocator._();

  static Future<void> registerCore() async {
    final storage = await LocalStorageService.init();
    final networkInfo = NetworkInfo();
    final apiClient = ApiClient();

    final AuthRepository authRepository = AuthRepositoryImpl(storage);
    final FavoritesRepository favoritesRepository =
        FavoritesRepositoryImpl(storage);
    final ExerciseRepository exerciseRepository = ExerciseRepositoryImpl(
      storage: storage,
      apiClient: apiClient,
      networkInfo: networkInfo,
    );

    Get.put(storage, permanent: true);
    Get.put<NetworkInfo>(networkInfo, permanent: true);
    Get.put(apiClient, permanent: true);
    Get.put<AuthRepository>(authRepository, permanent: true);
    Get.put<ExerciseRepository>(exerciseRepository, permanent: true);
    Get.put<FavoritesRepository>(favoritesRepository, permanent: true);
    Get.put(
      FavoritesController(
        favoritesRepository: favoritesRepository,
        exerciseRepository: exerciseRepository,
      ),
      permanent: true,
    );
  }
}
