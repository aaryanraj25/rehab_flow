import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/favorites_controller.dart';

class FavoriteButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FavoritesController>()) {
      return const SizedBox.shrink();
    }

    final favorites = Get.find<FavoritesController>();
    final iconSize = size ?? 22.sp;

    return Obx(() {
      final isFavorite = favorites.isFavorite(exerciseId);
      return IconButton(
        tooltip: isFavorite ? 'Remove from favourites' : 'Add to favourites',
        onPressed: () => favorites.toggleFavorite(exerciseId),
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: color ?? (isFavorite ? AppColors.favorite : AppColors.textOnCoral),
          size: iconSize,
        ),
      );
    });
  }
}
