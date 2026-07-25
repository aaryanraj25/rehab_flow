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
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.maxContentWidth(context),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    pad,
                    Responsive.s(context, 12.h, 10),
                    pad,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(child: ExerciseSearchBar()),
                      SizedBox(width: Responsive.s(context, 10.w, 8)),
                      const ExerciseFilterButton(),
                    ],
                  ),
                ),
              ),
            ),
            Obx(() {
              if (!controller.hasFacetFilters) {
                return SizedBox(height: 10.h);
              }
              return Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxContentWidth(context),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(pad, 10.h, pad, 4.h),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: ExerciseActiveFilters(),
                    ),
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
                                        crossAxisCount: columns.clamp(2, 5),
                                        crossAxisSpacing: 14,
                                        mainAxisSpacing: 14,
                                        childAspectRatio:
                                            Responsive.exerciseGridAspectRatio(
                                          context,
                                        ),
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
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.maxContentWidth(context),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                pad,
                Responsive.s(context, 6.h, 4),
                pad - 4,
                Responsive.s(context, 10.h, 8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: Responsive.s(context, 12.sp, 11),
                            fontWeight: FontWeight.w700,
                            color:
                                AppColors.textOnCoral.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(
                          () => Text(
                            'Hey, ${auth.currentUser.value?.displayName ?? 'Athlete'}',
                            style: TextStyle(
                              fontSize: Responsive.s(context, 22.sp, 18),
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: AppColors.textOnCoral,
                              height: 1.15,
                            ),
                          ),
                        ),
                        if (Responsive.isPhone(context)) ...[
                          SizedBox(height: 4.h),
                          Text(
                            'Find a move and keep recovering.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textOnCoral
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Favourites',
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          AppColors.textOnCoral.withValues(alpha: 0.16),
                      minimumSize: const Size(40, 40),
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () => Get.toNamed(AppRoutes.favorites),
                    icon: Icon(
                      Icons.favorite_rounded,
                      size: Responsive.s(context, 20.sp, 18),
                    ),
                  ),
                  SizedBox(width: Responsive.s(context, 4.w, 4)),
                  IconButton(
                    tooltip: 'Sign out',
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          AppColors.textOnCoral.withValues(alpha: 0.16),
                      minimumSize: const Size(40, 40),
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: auth.logout,
                    icon: Icon(
                      Icons.logout_rounded,
                      size: Responsive.s(context, 20.sp, 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
