import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/exercise_controller.dart';

/// Opens the filter sheet and shows a badge when facets are active.
class ExerciseFilterButton extends GetView<ExerciseController> {
  const ExerciseFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.activeFacetFilterCount;
      return Material(
        color: count > 0 ? AppColors.coral : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () => _openFilterSheet(context),
          borderRadius: BorderRadius.circular(16.r),
          child: SizedBox(
            width: 52.w,
            height: 48.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 22.sp,
                  color: count > 0 ? AppColors.textOnCoral : AppColors.coralDeep,
                ),
                if (count > 0)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textOnCoral,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => const _ExerciseFilterSheet(),
    );
  }
}

/// Compact removable chips for currently selected filters only.
class ExerciseActiveFilters extends GetView<ExerciseController> {
  const ExerciseActiveFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasFacetFilters) return const SizedBox.shrink();

      final chips = <Widget>[
        for (final category in controller.selectedCategories.toList()..sort())
          _ActiveChip(
            label: category,
            onDeleted: () => controller.selectCategory(category),
          ),
        if (controller.selectedDifficulty.value != null)
          _ActiveChip(
            label: controller.selectedDifficulty.value!,
            onDeleted: () => controller.selectDifficulty(null),
          ),
        for (final muscle in controller.selectedMuscles.toList()..sort())
          _ActiveChip(
            label: muscle,
            onDeleted: () => controller.selectMuscle(muscle),
          ),
        _ActiveChip(
          label: 'Clear all',
          onDeleted: controller.clearFacetFilters,
          isAction: true,
        ),
      ];

      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 34.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemBuilder: (context, index) => chips[index],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({
    required this.label,
    required this.onDeleted,
    this.isAction = false,
  });

  final String label;
  final VoidCallback onDeleted;
  final bool isAction;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: Icon(
        isAction ? Icons.close_rounded : Icons.cancel_rounded,
        size: 16.sp,
      ),
      labelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: isAction ? AppColors.coralDeep : AppColors.ink,
      ),
      backgroundColor: isAction
          ? AppColors.coral.withValues(alpha: 0.12)
          : AppColors.surfaceElevated,
      side: BorderSide(
        color: isAction ? AppColors.coral : AppColors.border,
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
    );
  }
}

class _ExerciseFilterSheet extends GetView<ExerciseController> {
  const _ExerciseFilterSheet();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxBodyHeight = media.size.height * 0.48;

    return Padding(
      // Keyboard only — safe area is handled by the sheet.
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
        child: Obx(() {
          final _ = (
            controller.allExercises.length,
            controller.selectedCategories.length,
            controller.selectedDifficulty.value,
            controller.selectedMuscles.length,
            controller.filteredExercises.length,
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  if (controller.hasFacetFilters)
                    TextButton(
                      onPressed: controller.clearFacetFilters,
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.coralDeep,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxBodyHeight),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FilterSection(
                        title: 'Category',
                        options: controller.categories,
                        selected: controller.selectedCategories,
                        onSelected: controller.selectCategory,
                        multiSelect: true,
                      ),
                      SizedBox(height: 16.h),
                      _FilterSection(
                        title: 'Difficulty',
                        options: controller.difficulties,
                        selected: controller.selectedDifficulty.value == null
                            ? const {}
                            : {controller.selectedDifficulty.value!},
                        onSelected: (option) =>
                            controller.selectDifficulty(option),
                      ),
                      SizedBox(height: 16.h),
                      _FilterSection(
                        title: 'Target muscle',
                        options: controller.targetMuscles,
                        selected: controller.selectedMuscles,
                        onSelected: controller.selectMuscle,
                        multiSelect: true,
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 48.h,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Show ${controller.filteredExercises.length} exercises',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.multiSelect = false,
  });

  final String title;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onSelected;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
        if (multiSelect) ...[
          SizedBox(height: 2.h),
          Text(
            'Select one or more',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
        ],
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              showCheckmark: multiSelect,
              checkmarkColor: AppColors.textOnCoral,
              onSelected: (_) => onSelected(option),
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.textOnCoral : AppColors.ink,
              ),
              selectedColor: AppColors.coral,
              backgroundColor: AppColors.background,
              side: BorderSide(
                color: isSelected ? AppColors.coralDeep : AppColors.border,
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
      ],
    );
  }
}
