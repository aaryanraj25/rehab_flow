import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../utils/responsive.dart';
import '../../data/models/exercise_model.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.dense = false,
  });

  final ExerciseModel exercise;
  final VoidCallback? onTap;

  /// Compact horizontal layout for phone lists.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (dense || Responsive.isPhone(context)) {
      return _DenseCard(exercise: exercise, onTap: onTap);
    }
    return _GridCard(exercise: exercise, onTap: onTap);
  }
}

class _DenseCard extends StatelessWidget {
  const _DenseCard({required this.exercise, this.onTap});

  final ExerciseModel exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final thumb = 88.w;

    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(18.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: SizedBox(
                  width: thumb,
                  height: thumb,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _Thumbnail(url: exercise.thumbnailUrl ?? exercise.imageUrl),
                      Positioned(
                        left: 6.w,
                        top: 6.h,
                        child: _DifficultyDot(difficulty: exercise.difficulty),
                      ),
                    ],
                  ),
                ),
              ),
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
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
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
  const _GridCard({required this.exercise, this.onTap});

  final ExerciseModel exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(20.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Thumbnail(url: exercise.thumbnailUrl ?? exercise.imageUrl),
                  Positioned(
                    left: 10.w,
                    top: 10.h,
                    child: _Chip(
                      label: exercise.difficulty,
                      color: DifficultyColors.forLevel(exercise.difficulty),
                    ),
                  ),
                ],
              ),
            ),
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

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const _ThumbnailFallback();
    }

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.coral.withValues(alpha: 0.18),
        child: Center(
          child: SizedBox(
            width: 18.w,
            height: 18.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.coralDeep,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => const _ThumbnailFallback(),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.coral.withValues(alpha: 0.2),
      child: Icon(
        Icons.fitness_center_rounded,
        size: 28.sp,
        color: AppColors.coralDeep,
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
