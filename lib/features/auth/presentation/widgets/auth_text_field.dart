import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../utils/responsive.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final labelSize = Responsive.s(context, 12.5.sp, 12);
    final fieldSize = Responsive.s(context, 14.sp, 14);
    final hintSize = Responsive.s(context, 13.sp, 13);
    final iconSize = Responsive.s(context, 20.sp, 18);
    final radius = Responsive.s(context, 14.r, 12);
    final hPad = Responsive.s(context, 14.w, 14);
    final vPad = Responsive.s(context, 12.h, 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: labelSize,
            letterSpacing: 0.15,
            color: AppColors.ink,
          ),
        ),
        SizedBox(height: Responsive.s(context, 6.h, 6)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          autovalidateMode: AutovalidateMode.onUnfocus,
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
            fontSize: fieldSize,
            height: 1.25,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.65),
              fontSize: hintSize,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: hPad,
              vertical: vPad,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: AppColors.coralDeep, size: iconSize),
            prefixIconConstraints: BoxConstraints(
              minWidth: Responsive.s(context, 44.w, 40),
              minHeight: Responsive.s(context, 44.h, 44),
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.background.withValues(alpha: 0.55),
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
              borderSide: const BorderSide(color: AppColors.ink, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: AppColors.error, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
