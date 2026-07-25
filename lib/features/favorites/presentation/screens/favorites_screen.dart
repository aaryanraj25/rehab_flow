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
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text(
          'Clear all favourites?',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        content: Text(
          'This removes every saved exercise from this device.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridCrossAxisCount(context);
    final pad = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.coral,
        foregroundColor: AppColors.textOnCoral,
        title: Text(
          'Favourites',
          style: TextStyle(
            fontSize: 20.sp,
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
              onPressed: () => _confirmClear(context),
              icon: Icon(Icons.delete_outline_rounded, size: 22.sp),
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
                        crossAxisCount: columns.clamp(2, 4),
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.78,
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
