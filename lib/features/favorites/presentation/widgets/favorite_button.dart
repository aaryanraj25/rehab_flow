import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/favorites_controller.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.exerciseId,
    this.color,
    this.size,
  });

  final String exerciseId;
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
    await favorites.toggleFavorite(widget.exerciseId);
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
      return ScaleTransition(
        scale: _scale,
        child: IconButton(
          tooltip: isFavorite ? 'Remove from favourites' : 'Add to favourites',
          onPressed: () => _toggle(favorites),
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: widget.color ??
                (isFavorite ? AppColors.favorite : AppColors.textOnCoral),
            size: iconSize,
          ),
        ),
      );
    });
  }
}
