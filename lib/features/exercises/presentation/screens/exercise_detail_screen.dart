import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/difficulty_colors.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../utils/responsive.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../data/models/exercise_model.dart';
import '../controllers/exercise_detail_controller.dart';
import '../widgets/exercise_cached_image.dart';
import '../widgets/exercise_card.dart';

class ExerciseDetailScreen extends GetView<ExerciseDetailController> {
  const ExerciseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          final exercise = controller.exercise.value;
          final showFavorite =
              controller.status.value == ExerciseDetailStatus.success &&
                  exercise != null;

          return AppBar(
            backgroundColor: AppColors.coral,
            foregroundColor: AppColors.textOnCoral,
            title: Text(
              exercise?.name ?? 'Exercise',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              if (showFavorite) ...[
                FavoriteButton(
                  exerciseId: exercise.id,
                  color: AppColors.textOnCoral,
                  size: 24.sp,
                ),
                SizedBox(width: 4.w),
              ],
            ],
          );
        }),
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.isOffline.value) {
              return const OfflineBanner(visible: true);
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(() {
              switch (controller.status.value) {
                case ExerciseDetailStatus.loading:
                  return const AppLoadingView(
                    message: 'Getting your exercise ready...',
                  );
                case ExerciseDetailStatus.error:
                  return AppErrorView(
                    message: controller.errorMessage.value ??
                        'Unable to load detail.',
                    isOffline: controller.isOffline.value,
                    onRetry: controller.loadDetail,
                  );
                case ExerciseDetailStatus.success:
                  return _DetailBody(exercise: controller.exercise.value!);
              }
            }),
          ),
        ],
      ),
    );
  }
}

class _DetailBody extends GetView<ExerciseDetailController> {
  const _DetailBody({required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context);
    final difficultyColor = DifficultyColors.forLevel(exercise.difficulty);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.maxContentWidth(context),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 16.h, pad, 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MediaBlock(exercise: exercise),
                    SizedBox(height: 18.h),
                    Text(
                      exercise.name,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                        height: 1.15,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'A ${exercise.difficulty.toLowerCase()} ${exercise.category.toLowerCase()} move for ${exercise.targetMuscle.toLowerCase()}.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _InfoPill(
                          label: exercise.difficulty,
                          icon: Icons.trending_up_rounded,
                          color: difficultyColor,
                        ),
                        _InfoPill(
                          label: exercise.category,
                          icon: Icons.category_outlined,
                          color: AppColors.coralDeep,
                        ),
                        _InfoPill(
                          label: exercise.targetMuscle,
                          icon: Icons.accessibility_new_rounded,
                          color: AppColors.coralDeep,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _TipCard(
                      icon: Icons.handyman_outlined,
                      title: 'What you’ll need',
                      body: exercise.equipment,
                    ),
                    SizedBox(height: 18.h),
                    const _SectionTitle(
                      title: 'About this move',
                      icon: Icons.info_outline_rounded,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      exercise.description,
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.6,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 22.h),
                    const _SectionTitle(
                      title: 'How to perform',
                      icon: Icons.checklist_rounded,
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Column(
                        children: exercise.instructionSteps
                            .asMap()
                            .entries
                            .map(
                              (entry) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: _StepRow(
                                  index: entry.key + 1,
                                  text: entry.value,
                                  isLast: entry.key ==
                                      exercise.instructionSteps.length - 1,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    if (controller.related.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      const _SectionTitle(
                        title: 'Try these next',
                        icon: Icons.auto_awesome_rounded,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Similar moves to keep your rehab progressing.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ...controller.related.map(
                        (related) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: ExerciseCard(
                            exercise: related,
                            dense: true,
                            enableHero: false,
                            onTap: () => controller.openRelated(related),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaBlock extends StatelessWidget {
  const _MediaBlock({required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    final height = Responsive.value(context, phone: 210.h, tablet: 270.h);
    final difficultyColor = DifficultyColors.forLevel(exercise.difficulty);

    return Hero(
      tag: 'exercise-image-${exercise.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ExerciseCachedImage(
                url: exercise.imageUrl ?? exercise.thumbnailUrl,
                fallbackCategory: exercise.category,
              ),
              Positioned(
                left: 12.w,
                top: 12.h,
                child: _OverlayBadge(
                  label: exercise.difficulty,
                  color: difficultyColor,
                ),
              ),
              Positioned(
                left: 12.w,
                bottom: 12.h,
                child: _OverlayBadge(
                  label: 'Focus: ${exercise.targetMuscle}',
                  color: AppColors.ink.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayBadge extends StatelessWidget {
  const _OverlayBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textOnCoral,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.coralDeep, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coralDeep,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.coralDeep),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.text,
    required this.isLast,
  });

  final int index;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textOnCoral,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 18.h,
                margin: EdgeInsets.only(top: 4.h),
                color: AppColors.coral.withValues(alpha: 0.28),
              ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
