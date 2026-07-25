import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/exercise_model.dart';
import '../../data/repositories/exercise_repository.dart';

enum ExerciseListStatus { initial, loading, success, empty, error }

class ExerciseController extends GetxController {
  ExerciseController(this._repository);

  final ExerciseRepository _repository;

  final searchController = TextEditingController();

  final RxList<ExerciseModel> allExercises = <ExerciseModel>[].obs;
  final Rx<ExerciseListStatus> status = ExerciseListStatus.initial.obs;
  final RxnString errorMessage = RxnString();
  final RxBool isOffline = false.obs;
  final RxBool fromCache = false.obs;

  final RxString searchQuery = ''.obs;
  final RxnString selectedCategory = RxnString();
  final RxnString selectedDifficulty = RxnString();
  final RxnString selectedMuscle = RxnString();

  List<String> get categories {
    final values = allExercises.map((e) => e.category).toSet().toList()..sort();
    return values;
  }

  List<String> get difficulties {
    const order = ['Beginner', 'Intermediate', 'Advanced'];
    final values = allExercises.map((e) => e.difficulty).toSet().toList();
    values.sort((a, b) {
      final ai = order.indexOf(a);
      final bi = order.indexOf(b);
      if (ai == -1 && bi == -1) return a.compareTo(b);
      if (ai == -1) return 1;
      if (bi == -1) return -1;
      return ai.compareTo(bi);
    });
    return values;
  }

  List<String> get targetMuscles {
    final values =
        allExercises.map((e) => e.targetMuscle).toSet().toList()..sort();
    return values;
  }

  bool get hasFacetFilters =>
      selectedCategory.value != null ||
      selectedDifficulty.value != null ||
      selectedMuscle.value != null;

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty || hasFacetFilters;

  int get activeFacetFilterCount =>
      (selectedCategory.value != null ? 1 : 0) +
      (selectedDifficulty.value != null ? 1 : 0) +
      (selectedMuscle.value != null ? 1 : 0);

  /// Search by name + category/difficulty/muscle filters (AND).
  List<ExerciseModel> get filteredExercises {
    final query = searchQuery.value.trim().toLowerCase();

    return allExercises.where((exercise) {
      final matchesSearch =
          query.isEmpty || exercise.name.toLowerCase().contains(query);
      final matchesCategory = selectedCategory.value == null ||
          exercise.category == selectedCategory.value;
      final matchesDifficulty = selectedDifficulty.value == null ||
          exercise.difficulty == selectedDifficulty.value;
      final matchesMuscle = selectedMuscle.value == null ||
          exercise.targetMuscle == selectedMuscle.value;
      return matchesSearch &&
          matchesCategory &&
          matchesDifficulty &&
          matchesMuscle;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadExercises();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadExercises({bool forceRefresh = false}) async {
    status.value = ExerciseListStatus.loading;
    errorMessage.value = null;

    try {
      final result = await _repository.getExercises(forceRefresh: forceRefresh);
      allExercises.assignAll(result.exercises);
      isOffline.value = result.isOffline;
      fromCache.value = result.fromCache;

      if (result.exercises.isEmpty) {
        status.value = ExerciseListStatus.empty;
      } else {
        status.value = ExerciseListStatus.success;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = ExerciseListStatus.error;
    }
  }

  Future<void> retry() => loadExercises(forceRefresh: true);

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void selectCategory(String? value) {
    selectedCategory.value =
        selectedCategory.value == value ? null : value;
  }

  void selectDifficulty(String? value) {
    selectedDifficulty.value =
        selectedDifficulty.value == value ? null : value;
  }

  void selectMuscle(String? value) {
    selectedMuscle.value = selectedMuscle.value == value ? null : value;
  }

  void clearFacetFilters() {
    selectedCategory.value = null;
    selectedDifficulty.value = null;
    selectedMuscle.value = null;
  }

  void clearFilters() {
    clearSearch();
    clearFacetFilters();
  }
}
