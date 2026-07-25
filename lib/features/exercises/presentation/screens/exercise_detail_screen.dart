import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
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
        preferredSize: Size.fromHeight(kToolbarHeight),
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
                  return const AppLoadingView(message: 'Loading exercise...');
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
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _MetaChip(
                          label: exercise.category,
                          icon: Icons.category_outlined,
                        ),
                        _MetaChip(
                          label: exercise.difficulty,
                          icon: Icons.speed_rounded,
                          solidColor: DifficultyColors.forLevel(
                            exercise.difficulty,
                          ),
                        ),
                        _MetaChip(
                          label: exercise.targetMuscle,
                          icon: Icons.accessibility_new_rounded,
                        ),
                        _MetaChip(
                          label: exercise.equipment,
                          icon: Icons.handyman_outlined,
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    const _SectionTitle(title: 'About'),
                    SizedBox(height: 8.h),
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
                    const _SectionTitle(title: 'How to perform'),
                    SizedBox(height: 12.h),
                    ...exercise.instructionSteps.asMap().entries.map(
                      (entry) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _StepRow(
                          index: entry.key + 1,
                          text: entry.value,
                        ),
                      ),
                    ),
                    if (controller.related.isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      const _SectionTitle(title: 'Related exercises'),
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
    final height = Responsive.value(context, phone: 200.h, tablet: 260.h);

    return Hero(
      tag: 'exercise-image-${exercise.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
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
                bottom: 12.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    exercise.targetMuscle,
                    style: TextStyle(
                      color: AppColors.textOnCoral,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.3,
        color: AppColors.ink,
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.55,
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    required this.icon,
    this.solidColor,
  });

  final String label;
  final IconData icon;
  final Color? solidColor;

  @override
  Widget build(BuildContext context) {
    final solid = solidColor != null;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: solid ? solidColor : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14.r),
        border: solid ? null : Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: solid ? Colors.white : AppColors.coralDeep,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: solid ? Colors.white : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
