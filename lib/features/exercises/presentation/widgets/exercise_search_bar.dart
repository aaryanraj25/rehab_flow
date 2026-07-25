import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../utils/responsive.dart';
import '../controllers/exercise_controller.dart';

class ExerciseSearchBar extends GetView<ExerciseController> {
  const ExerciseSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final height = Responsive.s(context, 48.h, 42);
    final radius = Responsive.s(context, 16.r, 12);
    final fontSize = Responsive.s(context, 14.sp, 13);
    final iconSize = Responsive.s(context, 22.sp, 20);

    return SizedBox(
      height: height,
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          height: 1.2,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search by name, like “knee” or “bridge”',
          hintStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.coralDeep,
            size: iconSize,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: Responsive.s(context, 48.w, 40),
            minHeight: height,
          ),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              tooltip: 'Clear search',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: Responsive.s(context, 40.w, 36),
                minHeight: height,
              ),
              onPressed: () {
                controller.clearSearch();
                FocusScope.of(context).unfocus();
              },
              icon: Icon(
                Icons.close_rounded,
                size: Responsive.s(context, 20.sp, 18),
                color: AppColors.textSecondary,
              ),
            );
          }),
          filled: true,
          fillColor: AppColors.surfaceElevated,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.s(context, 12.w, 10),
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: AppColors.ink, width: 1.2),
          ),
        ),
      ),
    );
  }
}
