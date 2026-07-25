import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../data/models/exercise_model.dart';
import '../../data/repositories/exercise_repository.dart';

enum ExerciseDetailStatus { loading, success, error }

class ExerciseDetailController extends GetxController {
  ExerciseDetailController(this._repository);

  final ExerciseRepository _repository;

  final Rx<ExerciseDetailStatus> status = ExerciseDetailStatus.loading.obs;
  final Rxn<ExerciseModel> exercise = Rxn<ExerciseModel>();
  final RxList<ExerciseModel> related = <ExerciseModel>[].obs;
  final RxnString errorMessage = RxnString();

  late final String exerciseId;

  @override
  void onInit() {
    super.onInit();
    exerciseId = _resolveExerciseId();
    loadDetail();
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
      status.value = ExerciseDetailStatus.error;
      errorMessage.value = 'Missing exercise id.';
      return;
    }

    status.value = ExerciseDetailStatus.loading;
    errorMessage.value = null;

    try {
      final detail = await _repository.getExerciseById(exerciseId);
      if (detail == null) {
        status.value = ExerciseDetailStatus.error;
        errorMessage.value = 'Exercise not found.';
        return;
      }

      exercise.value = detail;
      related.assignAll(await _repository.getRelatedExercises(detail));
      status.value = ExerciseDetailStatus.success;
    } catch (e) {
      errorMessage.value = e.toString();
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
