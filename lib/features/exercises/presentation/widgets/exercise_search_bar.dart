import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/exercise_controller.dart';

class ExerciseSearchBar extends GetView<ExerciseController> {
  const ExerciseSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          hintText: 'Search exercises',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.coralDeep,
            size: 22.sp,
          ),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              tooltip: 'Clear search',
              onPressed: () {
                controller.clearSearch();
                FocusScope.of(context).unfocus();
              },
              icon: Icon(
                Icons.close_rounded,
                size: 20.sp,
                color: AppColors.textSecondary,
              ),
            );
          }),
          filled: true,
          fillColor: AppColors.surfaceElevated,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.ink, width: 1.4.w),
          ),
        ),
      ),
    );
  }
}
