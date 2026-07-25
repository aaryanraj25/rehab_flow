import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../network/api_client.dart';
import '../../data/exercise_image_cache.dart';

/// Network image that reads/writes [ExerciseImageCache] for offline use.
class ExerciseCachedImage extends StatelessWidget {
  const ExerciseCachedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackCategory,
    this.showLoader = true,
  });

  final String? url;
  final BoxFit fit;
  final String? fallbackCategory;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    final resolved = url?.trim();
    if (resolved == null || resolved.isEmpty) {
      return _Fallback(category: fallbackCategory);
    }

    return CachedNetworkImage(
      imageUrl: resolved,
      cacheManager: ExerciseImageCache.instance,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 180),
      fadeOutDuration: const Duration(milliseconds: 120),
      placeholder: (context, _) => showLoader
          ? _Loader(category: fallbackCategory)
          : _Fallback(category: fallbackCategory),
      errorWidget: (context, url, error) => _OfflineAwareFallback(
        category: fallbackCategory,
      ),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader({this.category});

  final String? category;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _Fallback(category: category),
        Center(
          child: SizedBox(
            width: 22.w,
            height: 22.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.textOnCoral,
            ),
          ),
        ),
      ],
    );
  }
}

/// Checks connectivity so cold-start offline errors get a clearer caption.
class _OfflineAwareFallback extends StatelessWidget {
  const _OfflineAwareFallback({this.category});

  final String? category;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NetworkInfo>()) {
      return _Fallback(category: category, offlineUnavailable: false);
    }

    return FutureBuilder<bool>(
      future: Get.find<NetworkInfo>().isConnected,
      builder: (context, snapshot) {
        final online = snapshot.data ?? true;
        return _Fallback(
          category: category,
          offlineUnavailable: snapshot.hasData && !online,
        );
      },
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({
    this.category,
    this.offlineUnavailable = false,
  });

  final String? category;
  final bool offlineUnavailable;

  static IconData iconForCategory(String? category) {
    switch ((category ?? '').trim().toLowerCase()) {
      case 'strength':
        return Icons.fitness_center_rounded;
      case 'flexibility':
        return Icons.self_improvement_rounded;
      case 'balance':
        return Icons.accessibility_new_rounded;
      case 'core':
        return Icons.sports_gymnastics_rounded;
      case 'mobility':
        return Icons.directions_walk_rounded;
      case 'functional':
        return Icons.sports_kabaddi_rounded;
      default:
        return Icons.image_not_supported_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = category?.trim();
    final caption = offlineUnavailable
        ? 'Unavailable offline'
        : (label != null && label.isNotEmpty ? label : 'No image');

    return DecoratedBox(
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
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: AppColors.textOnCoral.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconForCategory(category),
                  size: 28.sp,
                  color: AppColors.textOnCoral,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                caption,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textOnCoral,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
