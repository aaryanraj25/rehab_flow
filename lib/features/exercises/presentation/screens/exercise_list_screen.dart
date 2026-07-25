import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../utils/responsive.dart';
import '../controllers/exercise_controller.dart';
import '../widgets/exercise_card.dart';
import '../widgets/exercise_filter_bar.dart';
import '../widgets/exercise_search_bar.dart';

class ExerciseListScreen extends GetView<ExerciseController> {
  const ExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final isTablet = Responsive.isTablet(context);
    final columns = Responsive.gridCrossAxisCount(context);
    final pad = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            _Header(auth: auth),
            Obx(() {
              if (controller.isOffline.value) {
                return const OfflineBanner(visible: true);
              }
              if (controller.refreshFailed.value && controller.fromCache.value) {
                return const OfflineBanner(
                  visible: true,
                  online: false,
                  message: 'Couldn’t refresh — showing saved data',
                );
              }
              if (controller.showOnlineBanner.value) {
                return const OfflineBanner(visible: true, online: true);
              }
              return const SizedBox.shrink();
            }),
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 12.h, pad, 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.maxContentWidth(context),
                ),
                child: Row(
                  children: [
                    const Expanded(child: ExerciseSearchBar()),
                    SizedBox(width: 10.w),
                    const ExerciseFilterButton(),
                  ],
                ),
              ),
            ),
            Obx(() {
              if (!controller.hasFacetFilters) {
                return SizedBox(height: 10.h);
              }
              return Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxContentWidth(context),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 10.h, pad, 4.h),
                    child: const ExerciseActiveFilters(),
                  ),
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                switch (controller.status.value) {
                  case ExerciseListStatus.initial:
                  case ExerciseListStatus.loading:
                    return const AppLoadingView(message: 'Loading exercises...');
                  case ExerciseListStatus.empty:
                    return const AppEmptyView(
                      title: 'No exercises found',
                      subtitle: 'Pull to refresh or try again later.',
                      icon: Icons.fitness_center_outlined,
                    );
                  case ExerciseListStatus.error:
                    return AppErrorView(
                      message: controller.errorMessage.value ??
                          'Could not load exercises.',
                      isOffline: controller.isOffline.value,
                      onRetry: controller.retry,
                    );
                  case ExerciseListStatus.success:
                    final filtered = controller.filteredExercises;
                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification) {
                          FocusScope.of(context).unfocus();
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        color: AppColors.coralDeep,
                        displacement: 40,
                        onRefresh: () =>
                            controller.loadExercises(forceRefresh: true),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: Responsive.maxContentWidth(context),
                            ),
                            child: CustomScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(pad, 6.h, pad, 10.h),
                                    child: Text(
                                      filtered.isEmpty
                                          ? 'No matches yet'
                                          : filtered.length == 1
                                              ? '1 exercise ready for you'
                                              : '${filtered.length} exercises ready for you',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                if (filtered.isEmpty)
                                  SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: AppEmptyView(
                                      title: 'No matches',
                                      subtitle: controller.hasActiveFilters
                                          ? 'Try adjusting search or filters.'
                                          : 'Nothing to show right now.',
                                      icon: Icons.search_off_rounded,
                                      actionLabel: controller.hasActiveFilters
                                          ? 'Clear filters'
                                          : null,
                                      onAction: controller.hasActiveFilters
                                          ? controller.clearFilters
                                          : null,
                                    ),
                                  )
                                else if (isTablet)
                                  SliverPadding(
                                    padding:
                                        EdgeInsets.fromLTRB(pad, 0, pad, 24.h),
                                    sliver: SliverGrid(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns.clamp(2, 4),
                                        crossAxisSpacing: 12.w,
                                        mainAxisSpacing: 12.h,
                                        childAspectRatio: 0.82,
                                      ),
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final exercise = filtered[index];
                                          return ExerciseCard(
                                            exercise: exercise,
                                            dense: false,
                                            onTap: () => Get.toNamed(
                                              AppRoutes.exerciseDetail,
                                              arguments: exercise.id,
                                            ),
                                          );
                                        },
                                        childCount: filtered.length,
                                      ),
                                    ),
                                  )
                                else
                                  SliverPadding(
                                    padding:
                                        EdgeInsets.fromLTRB(pad, 0, pad, 24.h),
                                    sliver: SliverList.separated(
                                      itemCount: filtered.length,
                                      separatorBuilder: (context, index) =>
                                          SizedBox(height: 10.h),
                                      itemBuilder: (context, index) {
                                        final exercise = filtered[index];
                                        return ExerciseCard(
                                          exercise: exercise,
                                          dense: true,
                                          onTap: () => Get.toNamed(
                                            AppRoutes.exerciseDetail,
                                            arguments: exercise.id,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.auth});

  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.coralDeep,
            AppColors.coral,
            AppColors.coralSoft,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, 8.h, pad - 4.w, 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textOnCoral.withValues(alpha: 0.85),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Obx(
                      () => Text(
                        'Hey, ${auth.currentUser.value?.displayName ?? 'Athlete'}',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: AppColors.textOnCoral,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Find a move and keep recovering.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textOnCoral.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Favourites',
                onPressed: () => Get.toNamed(AppRoutes.favorites),
                style: IconButton.styleFrom(
                  backgroundColor:
                      AppColors.textOnCoral.withValues(alpha: 0.16),
                ),
                icon: Icon(Icons.favorite_rounded, size: 20.sp),
              ),
              SizedBox(width: 4.w),
              IconButton(
                tooltip: 'Sign out',
                onPressed: auth.logout,
                style: IconButton.styleFrom(
                  backgroundColor:
                      AppColors.textOnCoral.withValues(alpha: 0.16),
                ),
                icon: Icon(Icons.logout_rounded, size: 20.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
