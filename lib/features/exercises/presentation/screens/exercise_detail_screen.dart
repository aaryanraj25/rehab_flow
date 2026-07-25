import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../utils/responsive.dart';
import '../../data/models/exercise_model.dart';
import '../controllers/exercise_detail_controller.dart';

class ExerciseDetailScreen extends GetView<ExerciseDetailController> {
  const ExerciseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        switch (controller.status.value) {
          case ExerciseDetailStatus.loading:
            return const AppLoadingView(message: 'Loading exercise...');
          case ExerciseDetailStatus.error:
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.coral,
                foregroundColor: AppColors.textOnCoral,
              ),
              body: AppErrorView(
                message: controller.errorMessage.value ?? 'Unable to load detail.',
                onRetry: controller.loadDetail,
              ),
            );
          case ExerciseDetailStatus.success:
            final exercise = controller.exercise.value!;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: isTablet ? 320.h : 260.h,
                  pinned: true,
                  backgroundColor: AppColors.coral,
                  foregroundColor: AppColors.textOnCoral,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      exercise.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOnCoral,
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        _HeroImage(url: exercise.imageUrl ?? exercise.thumbnailUrl),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.15),
                                Colors.black.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      Responsive.horizontalPadding(context),
                      18.h,
                      Responsive.horizontalPadding(context),
                      28.h,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Responsive.maxContentWidth(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [
                              _InfoChip(
                                label: exercise.category,
                                icon: Icons.category_outlined,
                              ),
                              _InfoChip(
                                label: exercise.difficulty,
                                icon: Icons.speed_rounded,
                                color: DifficultyColors.forLevel(exercise.difficulty),
                              ),
                              _InfoChip(
                                label: exercise.targetMuscle,
                                icon: Icons.accessibility_new_rounded,
                              ),
                            ],
                          ),
                          SizedBox(height: 22.h),
                          _SectionCard(
                            title: 'Description',
                            child: Text(
                              exercise.description,
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.5,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          _SectionCard(
                            title: 'Instructions',
                            child: Text(
                              exercise.instructions,
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.55,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          _SectionCard(
                            title: 'Equipment required',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.handyman_outlined,
                                  size: 18.sp,
                                  color: AppColors.coralDeep,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    exercise.equipment,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (controller.related.isNotEmpty) ...[
                            SizedBox(height: 24.h),
                            Text(
                              'Related exercises',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                                color: AppColors.ink,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            SizedBox(
                              height: 168.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.related.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(width: 12.w),
                                itemBuilder: (context, index) {
                                  final related = controller.related[index];
                                  return _RelatedTile(
                                    exercise: related,
                                    onTap: () => controller.openRelated(related),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
        }
      }),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: AppColors.coral,
        child: Icon(
          Icons.fitness_center_rounded,
          size: 64.sp,
          color: AppColors.textOnCoral,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.coralSoft,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.textOnCoral),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.coral,
        child: Icon(
          Icons.fitness_center_rounded,
          size: 64.sp,
          color: AppColors.textOnCoral,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.coralDeep,
            ),
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.icon,
    this.color,
  });

  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.coral;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: color == null ? 0.14 : 1),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: color == null ? AppColors.coralDeep : Colors.white,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color == null ? AppColors.ink : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedTile extends StatelessWidget {
  const _RelatedTile({required this.exercise, required this.onTap});

  final ExerciseModel exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148.w,
      child: Material(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: exercise.thumbnailUrl ?? exercise.imageUrl ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.coral.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: AppColors.coralDeep,
                      size: 28.sp,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
                child: Text(
                  exercise.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    height: 1.25,
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
