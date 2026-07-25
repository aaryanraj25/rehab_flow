import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../exercises/data/models/exercise_model.dart';
import '../controllers/favorites_controller.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.exerciseId,
    this.exercise,
    this.color,
    this.size,
  });

  final String exerciseId;
  /// Optional full model — preferred so favouriting does not depend on a lookup.
  final ExerciseModel? exercise;
  final Color? color;
  final double? size;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.28), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 1), weight: 55),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggle(FavoritesController favorites) async {
    _controller.forward(from: 0);
    try {
      await favorites.toggleFavorite(
        widget.exerciseId,
        snapshot: widget.exercise,
      );
    } catch (_) {
      // Keep UI responsive; heart state stays driven by controller obs.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FavoritesController>()) {
      return const SizedBox.shrink();
    }

    final favorites = Get.find<FavoritesController>();
    final iconSize = widget.size ?? 22.sp;

    return Obx(() {
      final isFavorite = favorites.isFavorite(widget.exerciseId);
      // Filled hearts stay coral-red so they read clearly on light photos.
      final iconColor = isFavorite
          ? AppColors.favorite
          : (widget.color ?? AppColors.textOnCoral);

      return ScaleTransition(
        scale: _scale,
        child: IconButton(
          tooltip: isFavorite ? 'Remove from favourites' : 'Add to favourites',
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: iconSize + 8,
            minHeight: iconSize + 8,
          ),
          visualDensity: VisualDensity.compact,
          onPressed: () => _toggle(favorites),
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: iconColor,
            size: iconSize,
          ),
        ),
      );
    });
  }
}
