import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../utils/responsive.dart';
import '../../../exercises/presentation/widgets/exercise_card.dart';
import '../controllers/favorites_controller.dart';

class FavoritesScreen extends GetView<FavoritesController> {
  const FavoritesScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final maxWidth = Responsive.isTablet(context) ? 360.0 : 320.0;
        return Dialog(
          backgroundColor: AppColors.surfaceElevated,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Clear all favourites?',
                    style: TextStyle(
                      fontSize: Responsive.s(context, 18.sp, 17),
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This removes every saved exercise from this device.',
                    style: TextStyle(
                      fontSize: Responsive.s(context, 14.sp, 13),
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: Responsive.s(context, 14.sp, 13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: Text(
                          'Clear all',
                          style: TextStyle(
                            fontSize: Responsive.s(context, 14.sp, 13),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (confirmed == true) {
      await controller.clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridCrossAxisCount(context);
    final pad = Responsive.horizontalPadding(context);

    final toolbarHeight = Responsive.s(context, kToolbarHeight, 44);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: toolbarHeight,
        backgroundColor: AppColors.coral,
        foregroundColor: AppColors.textOnCoral,
        title: Text(
          'Favourites',
          style: TextStyle(
            fontSize: Responsive.s(context, 18.sp, 17),
            fontWeight: FontWeight.w800,
            color: AppColors.textOnCoral,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.favoriteExercises.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              tooltip: 'Clear all',
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onPressed: () => _confirmClear(context),
              icon: Icon(
                Icons.delete_outline_rounded,
                size: Responsive.s(context, 20.sp, 18),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.favoriteExercises.isEmpty) {
          return const AppLoadingView(message: 'Loading favourites...');
        }

        if (controller.favoriteExercises.isEmpty) {
          return AppEmptyView(
            title: 'No favourites yet',
            subtitle:
                'Tap the heart on any ${AppConstants.appName} exercise to save it here.',
            icon: Icons.favorite_border_rounded,
            actionLabel: 'Browse exercises',
            onAction: () => Get.back(),
          );
        }

        final useList = Responsive.isPhone(context);

        return RefreshIndicator(
          color: AppColors.coralDeep,
          onRefresh: controller.loadFavoriteExercises,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.maxContentWidth(context),
              ),
              child: useList
                  ? ListView.separated(
                      padding: EdgeInsets.fromLTRB(pad, 16.h, pad, 24.h),
                      itemCount: controller.favoriteExercises.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final exercise = controller.favoriteExercises[index];
                        return ExerciseCard(
                          exercise: exercise,
                          dense: true,
                          onTap: () => Get.toNamed(
                            AppRoutes.exerciseDetail,
                            arguments: exercise.id,
                          ),
                        );
                      },
                    )
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(pad, 16.h, pad, 24.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns.clamp(2, 5),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio:
                            Responsive.exerciseGridAspectRatio(context),
                      ),
                      itemCount: controller.favoriteExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = controller.favoriteExercises[index];
                        return ExerciseCard(
                          exercise: exercise,
                          onTap: () => Get.toNamed(
                            AppRoutes.exerciseDetail,
                            arguments: exercise.id,
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      }),
    );
  }
}
