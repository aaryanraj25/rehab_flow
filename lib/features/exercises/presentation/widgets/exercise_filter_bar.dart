import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../utils/responsive.dart';
import '../controllers/exercise_controller.dart';

/// Opens the filter sheet and shows a badge when facets are active.
class ExerciseFilterButton extends GetView<ExerciseController> {
  const ExerciseFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final size = Responsive.s(context, 48.h, 42);
    final radius = Responsive.s(context, 16.r, 12);

    return Obx(() {
      final count = controller.activeFacetFilterCount;
      return Material(
        color: count > 0 ? AppColors.coral : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: () => _openFilterSheet(context),
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: Responsive.s(context, 22.sp, 20),
                  color: count > 0 ? AppColors.textOnCoral : AppColors.coralDeep,
                ),
                if (count > 0)
                  Positioned(
                    top: Responsive.s(context, 8.h, 6),
                    right: Responsive.s(context, 8.w, 6),
                    child: Container(
                      width: Responsive.s(context, 16.w, 14),
                      height: Responsive.s(context, 16.w, 14),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: Responsive.s(context, 9.sp, 9),
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
    final isTablet = Responsive.isTablet(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surfaceElevated,
      constraints: isTablet
          ? BoxConstraints(maxWidth: Responsive.maxContentWidth(context))
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.s(context, 24.r, 18)),
        ),
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
              height: Responsive.s(context, 34.h, 30),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (context, index) =>
                    SizedBox(width: Responsive.s(context, 8.w, 6)),
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
        size: Responsive.s(context, 16.sp, 14),
      ),
      labelStyle: TextStyle(
        fontSize: Responsive.s(context, 12.sp, 11),
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
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, 2.w, 2),
      ),
    );
  }
}

class _ExerciseFilterSheet extends GetView<ExerciseController> {
  const _ExerciseFilterSheet();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isTablet = Responsive.isTablet(context);
    final maxBodyHeight = media.size.height * (isTablet ? 0.42 : 0.48);
    final hPad = Responsive.s(context, 20.w, 20);
    final vPad = Responsive.s(context, 12.h, 10);

    // Content-sized sheet — do NOT use Align(bottom) with isScrollControlled,
    // or the sheet expands full-height and leaves a huge empty gap above.
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          hPad,
          vPad,
          hPad,
          Responsive.s(context, 16.h, 14),
        ),
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
                  width: Responsive.s(context, 40.w, 36),
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              SizedBox(height: Responsive.s(context, 16.h, 12)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: Responsive.s(context, 20.sp, 18),
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
                          fontSize: Responsive.s(context, 13.sp, 13),
                          fontWeight: FontWeight.w700,
                          color: AppColors.coralDeep,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: Responsive.s(context, 8.h, 6)),
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
                      SizedBox(height: Responsive.s(context, 16.h, 12)),
                      _FilterSection(
                        title: 'Difficulty',
                        options: controller.difficulties,
                        selected: controller.selectedDifficulty.value == null
                            ? const {}
                            : {controller.selectedDifficulty.value!},
                        onSelected: (option) =>
                            controller.selectDifficulty(option),
                      ),
                      SizedBox(height: Responsive.s(context, 16.h, 12)),
                      _FilterSection(
                        title: 'Target muscle',
                        options: controller.targetMuscles,
                        selected: controller.selectedMuscles,
                        onSelected: controller.selectMuscle,
                        multiSelect: true,
                      ),
                      SizedBox(height: Responsive.s(context, 8.h, 6)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Responsive.s(context, 12.h, 10)),
              SizedBox(
                height: Responsive.s(context, 48.h, 44),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Show ${controller.filteredExercises.length} exercises',
                    style: TextStyle(
                      fontSize: Responsive.s(context, 15.sp, 14),
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
            fontSize: Responsive.s(context, 13.sp, 12),
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
        if (multiSelect) ...[
          SizedBox(height: Responsive.s(context, 2.h, 2)),
          Text(
            'Select one or more',
            style: TextStyle(
              fontSize: Responsive.s(context, 11.sp, 11),
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
        ],
        SizedBox(height: Responsive.s(context, 8.h, 6)),
        Wrap(
          spacing: Responsive.s(context, 8.w, 6),
          runSpacing: Responsive.s(context, 8.h, 6),
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              showCheckmark: multiSelect,
              checkmarkColor: AppColors.textOnCoral,
              onSelected: (_) => onSelected(option),
              labelStyle: TextStyle(
                fontSize: Responsive.s(context, 12.sp, 12),
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
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }).toList(),
        ),
      ],
    );
  }
}
