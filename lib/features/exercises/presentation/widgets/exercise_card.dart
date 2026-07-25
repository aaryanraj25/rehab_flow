import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
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

  /// Compact horizontal layout for phone lists.
  final bool dense;

  /// Disable when multiple cards for the same id could share a route
  /// (e.g. related list under an already-heroed detail media).
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
    final thumb = 88.w;

    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: SizedBox(
        width: thumb,
        height: thumb,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExerciseCachedImage(
              url: exercise.thumbnailUrl ?? exercise.imageUrl,
              fallbackCategory: exercise.category,
              showLoader: false,
            ),
            Positioned(
              left: 6.w,
              top: 6.h,
              child: _DifficultyDot(difficulty: exercise.difficulty),
            ),
          ],
        ),
      ),
    );
    if (enableHero) {
      image = Hero(tag: 'exercise-image-${exercise.id}', child: image);
    }

    return Material(
      color: AppColors.surfaceElevated,
      elevation: 1.5,
      shadowColor: AppColors.ink.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(18.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.coral.withValues(alpha: 0.12),
        highlightColor: AppColors.coral.withValues(alpha: 0.06),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Row(
            children: [
              image,
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        height: 1.25,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${exercise.difficulty} · ${exercise.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      exercise.targetMuscle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              FavoriteButton(
                exerciseId: exercise.id,
                color: AppColors.favorite,
                size: 22.sp,
              ),
            ],
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
          child: _Chip(
            label: exercise.difficulty,
            color: DifficultyColors.forLevel(exercise.difficulty),
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
      elevation: 2,
      shadowColor: AppColors.ink.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.coral.withValues(alpha: 0.12),
        highlightColor: AppColors.coral.withValues(alpha: 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: media),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
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
                        fontSize: 11.5.sp,
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
    );
  }
}

class _DifficultyDot extends StatelessWidget {
  const _DifficultyDot({required this.difficulty});

  final String difficulty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: DifficultyColors.forLevel(difficulty),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
