import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../network/api_client.dart';
import '../../data/models/exercise_model.dart';
import '../../data/repositories/exercise_repository.dart';

enum ExerciseListStatus { initial, loading, success, empty, error }

class ExerciseController extends GetxController {
  ExerciseController(this._repository, this._networkInfo);

  final ExerciseRepository _repository;
  final NetworkInfo _networkInfo;

  final searchController = TextEditingController();

  final RxList<ExerciseModel> allExercises = <ExerciseModel>[].obs;
  final Rx<ExerciseListStatus> status = ExerciseListStatus.initial.obs;
  final RxnString errorMessage = RxnString();
  final RxBool isOffline = false.obs;
  final RxBool fromCache = false.obs;
  final RxBool showOnlineBanner = false.obs;
  final RxBool refreshFailed = false.obs;

  final RxString searchQuery = ''.obs;
  final RxnString selectedCategory = RxnString();
  final RxnString selectedDifficulty = RxnString();
  final RxnString selectedMuscle = RxnString();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _onlineBannerTimer;

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
    _listenToConnectivity();
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    _onlineBannerTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _listenToConnectivity() {
    _connectivitySub = _networkInfo.onConnectivityChanged.listen((results) {
      final online = results.any((result) => result != ConnectivityResult.none);
      if (online) {
        final wasOffline = isOffline.value;
        isOffline.value = false;
        if (wasOffline) {
          _flashOnlineBanner();
          loadExercises();
        }
      } else {
        _onlineBannerTimer?.cancel();
        showOnlineBanner.value = false;
        isOffline.value = true;
      }
    });
  }

  void _flashOnlineBanner() {
    showOnlineBanner.value = true;
    _onlineBannerTimer?.cancel();
    _onlineBannerTimer = Timer(const Duration(seconds: 3), () {
      showOnlineBanner.value = false;
    });
  }

  Future<void> loadExercises({bool forceRefresh = false}) async {
    status.value = ExerciseListStatus.loading;
    errorMessage.value = null;
    refreshFailed.value = false;

    try {
      final result = await _repository.getExercises(forceRefresh: forceRefresh);
      allExercises.assignAll(result.exercises);
      isOffline.value = result.isOffline;
      fromCache.value = result.fromCache;
      refreshFailed.value = result.refreshFailed;

      // Re-check live connectivity so a stale offline flag doesn't stick
      // when the repository returned cached data while the device is online.
      if (isOffline.value && await _networkInfo.isConnected) {
        isOffline.value = false;
      }

      if (result.exercises.isEmpty) {
        status.value = ExerciseListStatus.empty;
      } else {
        status.value = ExerciseListStatus.success;
        if (result.refreshFailed) {
          _showRefreshFailedSnack();
          _onlineBannerTimer?.cancel();
          _onlineBannerTimer = Timer(const Duration(seconds: 4), () {
            refreshFailed.value = false;
          });
        }
      }
    } catch (e) {
      isOffline.value = !(await _networkInfo.isConnected);
      errorMessage.value = isOffline.value
          ? 'No internet connection and no saved exercises to show.'
          : e.toString();
      status.value = ExerciseListStatus.error;
    }
  }

  void _showRefreshFailedSnack() {
    Get.closeAllSnackbars();
    Get.snackbar(
      'Couldn’t refresh',
      'Showing saved data instead.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
      backgroundColor: AppColors.ink,
      colorText: AppColors.textOnCoral,
      icon: const Icon(Icons.cloud_off_rounded, color: AppColors.textOnCoral),
    );
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
