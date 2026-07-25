import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';
import '../../utils/responsive.dart';

/// Shared visual language for full-screen app states.
/// Each kind gets its own palette, eyebrow, icon frame, and CTA style.
enum _StateKind { loading, empty, offline, apiFailure }

class _StateTone {
  const _StateTone({
    required this.eyebrow,
    required this.accent,
    required this.accentSoft,
    required this.glow,
    required this.icon,
  });

  final String eyebrow;
  final Color accent;
  final Color accentSoft;
  final Color glow;
  final IconData icon;

  static _StateTone forKind(_StateKind kind) {
    switch (kind) {
      case _StateKind.loading:
        return const _StateTone(
          eyebrow: 'WORKING',
          accent: AppColors.coralDeep,
          accentSoft: AppColors.coral,
          glow: AppColors.coralGlow,
          icon: Icons.hourglass_top_rounded,
        );
      case _StateKind.empty:
        return const _StateTone(
          eyebrow: 'NOTHING HERE',
          accent: AppColors.secondary,
          accentSoft: AppColors.coralSoft,
          glow: AppColors.coralGlow,
          icon: Icons.inbox_outlined,
        );
      case _StateKind.offline:
        return const _StateTone(
          eyebrow: 'OFFLINE',
          accent: AppColors.warning,
          accentSoft: Color(0xFFFDBA74),
          glow: Color(0xFFFFEDD5),
          icon: Icons.wifi_off_rounded,
        );
      case _StateKind.apiFailure:
        return const _StateTone(
          eyebrow: 'REQUEST FAILED',
          accent: AppColors.error,
          accentSoft: Color(0xFFF97066),
          glow: Color(0xFFFEE4E2),
          icon: Icons.cloud_off_rounded,
        );
    }
  }
}

/// Decorative canvas used by every state screen.
/// Avoids [StackFit.expand] so it also works inside [SliverFillRemaining].
class _StateCanvas extends StatelessWidget {
  const _StateCanvas({
    required this.kind,
    required this.child,
  });

  final _StateKind kind;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tone = _StateTone.forKind(kind);
    final showStrip =
        kind == _StateKind.offline || kind == _StateKind.apiFailure;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            Color.lerp(AppColors.background, tone.glow, 0.55)!,
            AppColors.surfaceElevated,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.value(
              context,
              phone: 360.w,
              tablet: 440.w,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(28.w, showStrip ? 20.h : 32.h, 28.w, 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showStrip) ...[
                  _SignalStrip(kind: kind),
                  SizedBox(height: 20.h),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin status ribbon so offline vs API failure read differently at a glance.
class _SignalStrip extends StatelessWidget {
  const _SignalStrip({required this.kind});

  final _StateKind kind;

  @override
  Widget build(BuildContext context) {
    final offline = kind == _StateKind.offline;
    final label = offline ? 'Network unavailable' : 'Server / request error';
    final color = offline ? AppColors.warning : AppColors.error;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.6,
        color: color,
      ),
    );
  }
}

class _IconFrame extends StatelessWidget {
  const _IconFrame({
    required this.tone,
    required this.kind,
    this.overrideIcon,
  });

  final _StateTone tone;
  final _StateKind kind;
  final IconData? overrideIcon;

  @override
  Widget build(BuildContext context) {
    final icon = overrideIcon ?? tone.icon;

    return SizedBox(
      width: 120.w,
      height: 120.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (kind == _StateKind.loading)
            const _LoadingRings()
          else
            Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: tone.accent.withValues(alpha: 0.22),
                  width: kind == _StateKind.empty ? 1.5 : 2.5,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
            ),
          Container(
            width: 88.w,
            height: 88.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tone.accent,
                  tone.accentSoft,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: tone.accent.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, size: 40.sp, color: AppColors.textOnCoral),
          ),
        ],
      ),
    );
  }
}

class _LoadingRings extends StatefulWidget {
  const _LoadingRings();

  @override
  State<_LoadingRings> createState() => _LoadingRingsState();
}

class _LoadingRingsState extends State<_LoadingRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(120.w, 120.w),
          painter: _RingPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final t = (progress + i * 0.22) % 1.0;
      final radius = size.width * (0.28 + t * 0.22);
      paint.color = AppColors.coralDeep.withValues(alpha: 1 - t);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 1.4,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({
    required this.onPressed,
    required this.accent,
    this.label = 'Try again',
  });

  final VoidCallback onPressed;
  final Color accent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Responsive.buttonHeight() + 4.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.textOnCoral,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.refresh_rounded, size: 16.sp, color: Colors.white),
            ),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Responsive.buttonHeight() + 4.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.ink, width: 1.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

// ── Public widgets (call-site API preserved) ────────────────────────────────

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.message = 'Loading...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tone = _StateTone.forKind(_StateKind.loading);

    return _StateCanvas(
      kind: _StateKind.loading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconFrame(tone: tone, kind: _StateKind.loading),
          SizedBox(height: 28.h),
          _Eyebrow(text: tone.eyebrow, color: tone.accent),
          SizedBox(height: 10.h),
          Text(
            'Please wait',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 28.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(99.r),
            child: LinearProgressIndicator(
              minHeight: 4.h,
              backgroundColor: AppColors.border.withValues(alpha: 0.5),
              color: AppColors.coralDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tone = _StateTone.forKind(_StateKind.empty);

    return _StateCanvas(
      kind: _StateKind.empty,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconFrame(
            tone: tone,
            kind: _StateKind.empty,
            overrideIcon: icon,
          ),
          SizedBox(height: 28.h),
          _Eyebrow(text: tone.eyebrow, color: tone.accent),
          SizedBox(height: 10.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: AppColors.ink,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 10.h),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 28.h),
            _ActionButton(label: actionLabel!, onPressed: onAction!),
          ],
        ],
      ),
    );
  }
}

/// Distinct screens for API failure vs no-internet, both with retry.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.isOffline = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final kind = isOffline ? _StateKind.offline : _StateKind.apiFailure;
    final tone = _StateTone.forKind(kind);
    final title =
        isOffline ? 'No internet connection' : 'Couldn’t reach the server';
    final hint = isOffline
        ? 'Reconnect, then tap retry to load the latest exercises.'
        : 'Something went wrong on our side. Your saved data is still safe.';

    return _StateCanvas(
      kind: kind,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconFrame(tone: tone, kind: kind),
          SizedBox(height: 28.h),
          _Eyebrow(text: tone.eyebrow, color: tone.accent),
          SizedBox(height: 10.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: tone.accent.withValues(alpha: 0.28),
              ),
            ),
            child: Column(
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 14.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(height: 24.h),
            _RetryButton(
              onPressed: onRetry!,
              accent: tone.accent,
              label: isOffline ? 'Retry when online' : 'Retry request',
            ),
          ],
        ],
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    required this.visible,
    this.online = false,
    this.message,
  });

  final bool visible;
  final bool online;
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final background = online ? AppColors.success : AppColors.ink;
    final icon = online ? Icons.cloud_done_rounded : Icons.cloud_off_rounded;
    final resolved = message ??
        (online
            ? 'Back online — data can refresh'
            : 'Offline — showing cached exercises');

    return Material(
      color: background,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: AppColors.textOnCoral.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textOnCoral, size: 16.sp),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                resolved,
                style: TextStyle(
                  color: AppColors.textOnCoral,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
