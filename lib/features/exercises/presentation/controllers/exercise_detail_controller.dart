import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../network/api_client.dart';
import '../../data/models/exercise_model.dart';
import '../../data/repositories/exercise_repository.dart';

enum ExerciseDetailStatus { loading, success, error }

class ExerciseDetailController extends GetxController {
  ExerciseDetailController(this._repository, this._networkInfo);

  final ExerciseRepository _repository;
  final NetworkInfo _networkInfo;

  final Rx<ExerciseDetailStatus> status = ExerciseDetailStatus.loading.obs;
  final Rxn<ExerciseModel> exercise = Rxn<ExerciseModel>();
  final RxList<ExerciseModel> related = <ExerciseModel>[].obs;
  final RxnString errorMessage = RxnString();
  final RxBool isOffline = false.obs;
  final RxBool fromCache = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  late final String exerciseId;

  @override
  void onInit() {
    super.onInit();
    exerciseId = _resolveExerciseId();
    _listenToConnectivity();
    loadDetail();
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }

  void _listenToConnectivity() {
    _connectivitySub = _networkInfo.onConnectivityChanged.listen((results) {
      final online = results.any((result) => result != ConnectivityResult.none);
      isOffline.value = !online;
    });
  }

  String _resolveExerciseId() {
    final args = Get.arguments;
    if (args is String && args.isNotEmpty) return args;
    if (args is ExerciseModel) return args.id;
    if (args is Map && args['id'] != null) return args['id'].toString();
    final param = Get.parameters['id'];
    if (param != null && param.isNotEmpty) return param;
    return '';
  }

  Future<void> loadDetail() async {
    if (exerciseId.isEmpty) {
      isOffline.value = !(await _networkInfo.isConnected);
      status.value = ExerciseDetailStatus.error;
      errorMessage.value = 'Missing exercise id.';
      return;
    }

    status.value = ExerciseDetailStatus.loading;
    errorMessage.value = null;

    final online = await _networkInfo.isConnected;
    isOffline.value = !online;

    try {
      final detail = await _repository.getExerciseById(exerciseId);
      if (detail == null) {
        status.value = ExerciseDetailStatus.error;
        errorMessage.value = isOffline.value
            ? 'This exercise is not available offline. Connect to the internet and try again.'
            : 'Exercise not found.';
        return;
      }

      // Detail is always served from local cache/asset after first persist.
      fromCache.value = true;
      exercise.value = detail;
      related.assignAll(await _repository.getRelatedExercises(detail));

      // Re-check so a stale offline flag does not stick after reconnect.
      if (isOffline.value && await _networkInfo.isConnected) {
        isOffline.value = false;
      }

      status.value = ExerciseDetailStatus.success;
    } catch (e) {
      isOffline.value = !(await _networkInfo.isConnected);
      errorMessage.value = isOffline.value
          ? 'No internet connection. Connect and retry to load this exercise.'
          : e.toString();
      status.value = ExerciseDetailStatus.error;
    }
  }

  Future<void> openRelated(ExerciseModel relatedExercise) async {
    if (Get.isRegistered<ExerciseDetailController>()) {
      await Get.delete<ExerciseDetailController>(force: true);
    }
    Get.offNamed(
      AppRoutes.exerciseDetail,
      arguments: relatedExercise.id,
      preventDuplicates: false,
    );
  }
}
