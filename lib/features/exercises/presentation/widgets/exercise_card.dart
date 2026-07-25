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
    final isTablet = Responsive.isTablet(context);
    final thumb = Responsive.s(context, 92.w, 48);
    final pad = Responsive.s(context, 12.w, 6);
    final gap = Responsive.s(context, 14.w, 8);
    final radius = Responsive.s(context, 20.r, 12);
    final imageRadius = Responsive.s(context, 16.r, 8);
    final titleSize = Responsive.s(context, 15.sp, 12);
    final metaSize = Responsive.s(context, 12.sp, 11);
    final iconSize = Responsive.s(context, 14.sp, 12);
    final difficultyColor = DifficultyColors.forLevel(exercise.difficulty);

    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(imageRadius),
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
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.coral.withValues(alpha: 0.12),
        highlightColor: AppColors.coral.withValues(alpha: 0.05),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
          ),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              children: [
                image,
                SizedBox(width: gap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        exercise.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          height: 1.15,
                          letterSpacing: -0.25,
                        ),
                      ),
                      SizedBox(height: isTablet ? 3 : 8.h),
                      Wrap(
                        spacing: isTablet ? 4 : 6.w,
                        runSpacing: isTablet ? 3 : 6.h,
                        children: [
                          _SoftPill(
                            label: exercise.difficulty,
                            foreground: difficultyColor,
                            background: difficultyColor.withValues(alpha: 0.14),
                            logical: isTablet,
                          ),
                          _SoftPill(
                            label: exercise.category,
                            foreground: AppColors.coralDeep,
                            background: AppColors.coral.withValues(alpha: 0.14),
                            logical: isTablet,
                          ),
                        ],
                      ),
                      if (!isTablet) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.accessibility_new_rounded,
                              size: iconSize,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                'Targets ${exercise.targetMuscle}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: metaSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                FavoriteButton(
                  exerciseId: exercise.id,
                  exercise: exercise,
                  color: AppColors.favorite,
                  size: Responsive.s(context, 22.sp, 18),
                ),
                if (!isTablet)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.45),
                    size: Responsive.s(context, 22.sp, 18),
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
    // Logical sizes — `.h` / `.sp` inside fixed grid cells overscale on tablets
    // and cause BOTTOM OVERFLOW.
    const radius = 16.0;

    Widget media = Stack(
      fit: StackFit.expand,
      children: [
        ExerciseCachedImage(
          url: exercise.thumbnailUrl ?? exercise.imageUrl,
          fallbackCategory: exercise.category,
          showLoader: false,
        ),
        Positioned(
          left: 10,
          top: 10,
          child: _SoftPill(
            label: exercise.difficulty,
            foreground: Colors.white,
            background: difficultyColor,
            logical: true,
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: FavoriteButton(
            exerciseId: exercise.id,
            exercise: exercise,
            color: Colors.white,
            size: 22,
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
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.coral.withValues(alpha: 0.12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: media),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            exercise.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${exercise.category} · ${exercise.targetMuscle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
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
    this.logical = false,
  });

  final String label;
  final Color foreground;
  final Color background;
  final bool logical;

  @override
  Widget build(BuildContext context) {
    final hPad = logical ? 8.0 : 8.w;
    final vPad = logical ? 4.0 : 4.h;
    final fontSize = logical ? 11.0 : 11.sp;
    final radius = logical ? 999.0 : 999.r;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
