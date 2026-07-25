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
    final toolbarHeight = Responsive.s(context, kToolbarHeight, 44);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(toolbarHeight),
        child: Obx(() {
          final exercise = controller.exercise.value;
          final showFavorite =
              controller.status.value == ExerciseDetailStatus.success &&
                  exercise != null;

          return AppBar(
            toolbarHeight: toolbarHeight,
            backgroundColor: AppColors.coral,
            foregroundColor: AppColors.textOnCoral,
            centerTitle: true,
            titleSpacing: 0,
            title: Text(
              exercise?.name ?? 'Exercise',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Responsive.s(context, 16.sp, 15),
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              if (showFavorite) ...[
                FavoriteButton(
                  exerciseId: exercise.id,
                  exercise: exercise,
                  color: AppColors.textOnCoral,
                  size: Responsive.s(context, 24.sp, 20),
                ),
                SizedBox(width: Responsive.s(context, 4.w, 8)),
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
    final isTablet = Responsive.isTablet(context);

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.name,
          style: TextStyle(
            fontSize: Responsive.s(context, 26.sp, 22),
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.15,
            color: AppColors.ink,
          ),
        ),
        SizedBox(height: Responsive.s(context, 6.h, 6)),
        Text(
          'A ${exercise.difficulty.toLowerCase()} ${exercise.category.toLowerCase()} move for ${exercise.targetMuscle.toLowerCase()}.',
          style: TextStyle(
            fontSize: Responsive.s(context, 14.sp, 13),
            height: 1.35,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: Responsive.s(context, 12.h, 10)),
        Wrap(
          spacing: 6,
          runSpacing: 6,
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
        SizedBox(height: Responsive.s(context, 12.h, 10)),
        _TipCard(
          icon: Icons.handyman_outlined,
          title: 'What you’ll need',
          body: exercise.equipment,
        ),
      ],
    );

    final aboutBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'About this move',
          icon: Icons.info_outline_rounded,
        ),
        SizedBox(height: Responsive.s(context, 8.h, 8)),
        Text(
          exercise.description,
          style: TextStyle(
            fontSize: Responsive.s(context, 15.sp, 14),
            height: 1.5,
            color: AppColors.ink,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final stepsBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'How to perform',
          icon: Icons.checklist_rounded,
        ),
        SizedBox(height: Responsive.s(context, 10.h, 8)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            Responsive.s(context, 14.w, 12),
            Responsive.s(context, 12.h, 10),
            Responsive.s(context, 14.w, 12),
            Responsive.s(context, 4.h, 4),
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(Responsive.s(context, 20.r, 16)),
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
                    padding: EdgeInsets.only(
                      bottom: Responsive.s(context, 10.h, 8),
                    ),
                    child: _StepRow(
                      index: entry.key + 1,
                      text: entry.value,
                      isLast:
                          entry.key == exercise.instructionSteps.length - 1,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );

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
                padding: EdgeInsets.fromLTRB(
                  pad,
                  Responsive.s(context, 16.h, 14),
                  pad,
                  Responsive.s(context, 40.h, 32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTablet)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: _MediaBlock(exercise: exercise),
                          ),
                          const SizedBox(width: 20),
                          Expanded(flex: 5, child: titleBlock),
                        ],
                      )
                    else ...[
                      _MediaBlock(exercise: exercise),
                      SizedBox(height: 18.h),
                      titleBlock,
                    ],
                    SizedBox(height: Responsive.s(context, 20.h, 18)),
                    if (isTablet)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: aboutBlock),
                          const SizedBox(width: 20),
                          Expanded(flex: 5, child: stepsBlock),
                        ],
                      )
                    else ...[
                      aboutBlock,
                      SizedBox(height: 22.h),
                      stepsBlock,
                    ],
                    if (controller.related.isNotEmpty) ...[
                      SizedBox(height: Responsive.s(context, 22.h, 20)),
                      const _SectionTitle(
                        title: 'Try these next',
                        icon: Icons.auto_awesome_rounded,
                      ),
                      SizedBox(height: Responsive.s(context, 4.h, 4)),
                      Text(
                        'Similar moves to keep your rehab progressing.',
                        style: TextStyle(
                          fontSize: Responsive.s(context, 13.sp, 12),
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: Responsive.s(context, 10.h, 10)),
                      if (isTablet)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            const gap = 10.0;
                            final cardWidth =
                                (constraints.maxWidth - gap) / 2;
                            return Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: controller.related.map((related) {
                                return SizedBox(
                                  width: cardWidth,
                                  child: ExerciseCard(
                                    exercise: related,
                                    dense: true,
                                    enableHero: false,
                                    onTap: () =>
                                        controller.openRelated(related),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        )
                      else
                        ...controller.related.map(
                          (related) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
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
    final height = Responsive.value(
      context,
      phone: 210.h,
      tablet: Responsive.isLandscape(context) ? 220.0 : 200.0,
    );
    final difficultyColor = DifficultyColors.forLevel(exercise.difficulty);

    return Hero(
      tag: 'exercise-image-${exercise.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.s(context, 24.r, 18)),
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
                left: Responsive.s(context, 12.w, 10),
                top: Responsive.s(context, 12.h, 10),
                child: _OverlayBadge(
                  label: exercise.difficulty,
                  color: difficultyColor,
                ),
              ),
              Positioned(
                left: Responsive.s(context, 12.w, 10),
                bottom: Responsive.s(context, 12.h, 10),
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
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, 10.w, 8),
        vertical: Responsive.s(context, 6.h, 4),
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Responsive.s(context, 12.r, 8)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textOnCoral,
          fontSize: Responsive.s(context, 12.sp, 11),
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
    final iconBox = Responsive.s(context, 36.w, 28);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.s(context, 14.w, 10)),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Responsive.s(context, 18.r, 12)),
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Responsive.s(context, 12.r, 8)),
            ),
            child: Icon(
              icon,
              color: AppColors.coralDeep,
              size: Responsive.s(context, 18.sp, 15),
            ),
          ),
          SizedBox(width: Responsive.s(context, 12.w, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.s(context, 13.sp, 12),
                    fontWeight: FontWeight.w800,
                    color: AppColors.coralDeep,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: Responsive.s(context, 14.sp, 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    height: 1.3,
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
        Icon(
          icon,
          size: Responsive.s(context, 18.sp, 16),
          color: AppColors.coralDeep,
        ),
        SizedBox(width: Responsive.s(context, 8.w, 6)),
        Text(
          title,
          style: TextStyle(
            fontSize: Responsive.s(context, 18.sp, 16),
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
    final badge = Responsive.s(context, 28.w, 24);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: badge,
              height: badge,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(Responsive.s(context, 10.r, 8)),
              ),
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: Responsive.s(context, 13.sp, 12),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textOnCoral,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: Responsive.s(context, 18.h, 12),
                margin: const EdgeInsets.only(top: 4),
                color: AppColors.coral.withValues(alpha: 0.28),
              ),
          ],
        ),
        SizedBox(width: Responsive.s(context, 12.w, 10)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: TextStyle(
                fontSize: Responsive.s(context, 14.sp, 13),
                height: 1.4,
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
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, 10.w, 8),
        vertical: Responsive.s(context, 7.h, 5),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Responsive.s(context, 14.r, 10)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: Responsive.s(context, 14.sp, 13), color: color),
          SizedBox(width: Responsive.s(context, 6.w, 5)),
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.s(context, 12.sp, 11),
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
