import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/difficulty_colors.dart';
import '../../../../utils/responsive.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../data/models/exercise_model.dart';
import 'exercise_cached_image.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.dense = false,
    this.enableHero = true,
  });

  final ExerciseModel exercise;
  final VoidCallback? onTap;
  final bool dense;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    if (dense || Responsive.isPhone(context)) {
      return _DenseCard(
        exercise: exercise,
        onTap: onTap,
        enableHero: enableHero,
      );
    }
    return _GridCard(
      exercise: exercise,
      onTap: onTap,
      enableHero: enableHero,
    );
  }
}

class _DenseCard extends StatelessWidget {
  const _DenseCard({
    required this.exercise,
    this.onTap,
    this.enableHero = true,
  });

  final ExerciseModel exercise;
  final VoidCallback? onTap;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final thumb = 92.w;
    final difficultyColor = DifficultyColors.forLevel(exercise.difficulty);

    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        width: thumb,
        height: thumb,
        child: ExerciseCachedImage(
          url: exercise.thumbnailUrl ?? exercise.imageUrl,
          fallbackCategory: exercise.category,
          showLoader: false,
        ),
      ),
    );
    if (enableHero) {
      image = Hero(tag: 'exercise-image-${exercise.id}', child: image);
    }

    return Material(
      color: AppColors.surfaceElevated,
      elevation: 0,
      shadowColor: Colors.transparent,
      borderRadius: BorderRadius.circular(20.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.coral.withValues(alpha: 0.12),
        highlightColor: AppColors.coral.withValues(alpha: 0.05),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                image,
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          height: 1.25,
                          letterSpacing: -0.25,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: [
                          _SoftPill(
                            label: exercise.difficulty,
                            foreground: difficultyColor,
                            background: difficultyColor.withValues(alpha: 0.14),
                          ),
                          _SoftPill(
                            label: exercise.category,
                            foreground: AppColors.coralDeep,
                            background: AppColors.coral.withValues(alpha: 0.14),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.accessibility_new_rounded,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'Targets ${exercise.targetMuscle}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FavoriteButton(
                      exerciseId: exercise.id,
                      color: AppColors.favorite,
                      size: 22.sp,
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary.withValues(alpha: 0.45),
                      size: 22.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({
    required this.exercise,
    this.onTap,
    this.enableHero = true,
  });

  final ExerciseModel exercise;
  final VoidCallback? onTap;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final difficultyColor = DifficultyColors.forLevel(exercise.difficulty);

    Widget media = Stack(
      fit: StackFit.expand,
      children: [
        ExerciseCachedImage(
          url: exercise.thumbnailUrl ?? exercise.imageUrl,
          fallbackCategory: exercise.category,
          showLoader: false,
        ),
        Positioned(
          left: 10.w,
          top: 10.h,
          child: _SoftPill(
            label: exercise.difficulty,
            foreground: Colors.white,
            background: difficultyColor,
          ),
        ),
        Positioned(
          right: 4.w,
          top: 4.h,
          child: FavoriteButton(
            exerciseId: exercise.id,
            color: Colors.white,
            size: 22.sp,
          ),
        ),
      ],
    );
    if (enableHero) {
      media = Hero(tag: 'exercise-image-${exercise.id}', child: media);
    }

    return Material(
      color: AppColors.surfaceElevated,
      elevation: 0,
      borderRadius: BorderRadius.circular(22.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.coral.withValues(alpha: 0.12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: media),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          height: 1.25,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${exercise.category} · ${exercise.targetMuscle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  const _SoftPill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
