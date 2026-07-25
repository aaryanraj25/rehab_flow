import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../utils/responsive.dart';
import '../../../../utils/validators.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.coralDeep,
              AppColors.coral,
              AppColors.coralSoft,
            ],
          ),
        ),
        child: SafeArea(
          child: Responsive.useWideLayout(context)
              ? const _WideLoginBody()
              : const _CompactLoginBody(),
        ),
      ),
    );
  }
}

/// Phone + tablet portrait: brand above, form below.
class _CompactLoginBody extends StatelessWidget {
  const _CompactLoginBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.authFormMaxWidth(context),
        ),
        child: SingleChildScrollView(
          padding: Responsive.pageInsets(context),
          child: Column(
            children: [
              _BrandHeader(compact: Responsive.isPhone(context)),
              SizedBox(height: 20.h),
              const _LoginCard(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tablet landscape: brand left, form right.
class _WideLoginBody extends StatelessWidget {
  const _WideLoginBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Responsive.pageInsets(context),
      child: Row(
        children: [
          const Expanded(
            child: Center(child: _BrandHeader(compact: false)),
          ),
          SizedBox(width: 40.w),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.authFormMaxWidth(context),
                ),
                child: const SingleChildScrollView(child: _LoginCard()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final markSize = 52.w;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: markSize,
          height: markSize,
          decoration: BoxDecoration(
            color: AppColors.textOnCoral.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.textOnCoral.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(
            Icons.accessibility_new_rounded,
            size: 28.sp,
            color: AppColors.textOnCoral,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          AppConstants.appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: AppColors.textOnCoral,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Move better. Recover smarter.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textOnCoral.withValues(alpha: 0.9),
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (!compact) ...[
          SizedBox(height: 12.h),
          Text(
            AppConstants.appTagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textOnCoral.withValues(alpha: 0.75),
              fontSize: 13.sp,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class _LoginCard extends GetView<AuthController> {
  const _LoginCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.16),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Sign in to continue your rehab plan',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 18.h),
            AuthTextField(
              controller: controller.emailController,
              label: 'Email',
              hint: AppConstants.demoEmailHint,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.mail_outline_rounded,
              validator: Validators.email,
            ),
            SizedBox(height: 12.h),
            Obx(
              () => AuthTextField(
                controller: controller.passwordController,
                label: 'Password',
                hint:
                    'At least ${AppConstants.passwordMinLength} characters',
                obscureText: controller.obscurePassword.value,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.lock_outline_rounded,
                validator: Validators.password,
                onFieldSubmitted: (_) => controller.login(),
                suffix: IconButton(
                  onPressed: controller.togglePasswordVisibility,
                  icon: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              final error = controller.errorMessage.value;
              if (error == null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Text(
                  error,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
            SizedBox(height: 6.h),
            Obx(
              () => SizedBox(
                height: Responsive.buttonHeight(),
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.login,
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppColors.textOnCoral,
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Mock auth · any valid email + password '
                '(min ${AppConstants.passwordMinLength})\n'
                '${AppConstants.demoEmailHint} / ${AppConstants.demoPasswordHint}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
