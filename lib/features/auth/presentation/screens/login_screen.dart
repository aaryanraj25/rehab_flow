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
    final isTablet = Responsive.isTablet(context);

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
              SizedBox(height: isTablet ? 28 : 20.h),
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
    final markSize = Responsive.s(context, 52.w, 56);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: markSize,
          height: markSize,
          decoration: BoxDecoration(
            color: AppColors.textOnCoral.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(Responsive.s(context, 16.r, 16)),
            border: Border.all(
              color: AppColors.textOnCoral.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(
            Icons.accessibility_new_rounded,
            size: Responsive.s(context, 28.sp, 28),
            color: AppColors.textOnCoral,
          ),
        ),
        SizedBox(height: Responsive.s(context, 12.h, 12)),
        Text(
          AppConstants.appName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Responsive.s(context, 26.sp, 28),
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: AppColors.textOnCoral,
          ),
        ),
        SizedBox(height: Responsive.s(context, 4.h, 4)),
        Text(
          'Move better. Recover smarter.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textOnCoral.withValues(alpha: 0.9),
            fontSize: Responsive.s(context, 13.sp, 14),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (!compact) ...[
          SizedBox(height: Responsive.s(context, 12.h, 10)),
          Text(
            AppConstants.appTagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textOnCoral.withValues(alpha: 0.75),
              fontSize: Responsive.s(context, 13.sp, 13),
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
      padding: EdgeInsets.fromLTRB(
        Responsive.s(context, 18.w, 28),
        Responsive.s(context, 20.h, 24),
        Responsive.s(context, 18.w, 28),
        Responsive.s(context, 18.h, 22),
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(Responsive.s(context, 20.r, 20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.16),
            blurRadius: Responsive.s(context, 24.r, 24),
            offset: Offset(0, Responsive.s(context, 10.h, 10)),
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
                fontSize: Responsive.s(context, 20.sp, 20),
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: Responsive.s(context, 4.h, 4)),
            Text(
              'Sign in to continue your rehab plan',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: Responsive.s(context, 13.sp, 13),
              ),
            ),
            SizedBox(height: Responsive.s(context, 18.h, 18)),
            AuthTextField(
              controller: controller.emailController,
              label: 'Email',
              hint: AppConstants.demoEmailHint,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.mail_outline_rounded,
              validator: Validators.email,
            ),
            SizedBox(height: Responsive.s(context, 12.h, 12)),
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
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: Responsive.s(context, 20.sp, 18),
                  ),
                ),
              ),
            ),
            SizedBox(height: Responsive.s(context, 8.h, 8)),
            Obx(() {
              final error = controller.errorMessage.value;
              if (error == null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(
                  bottom: Responsive.s(context, 6.h, 6),
                ),
                child: Text(
                  error,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: Responsive.s(context, 12.sp, 12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
            SizedBox(height: Responsive.s(context, 6.h, 6)),
            Obx(
              () => SizedBox(
                height: Responsive.buttonHeight(),
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.login,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppColors.textOnCoral,
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: Responsive.s(context, 15.sp, 15),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: Responsive.s(context, 14.h, 14)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.s(context, 12.w, 12),
                vertical: Responsive.s(context, 10.h, 10),
              ),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(Responsive.s(context, 12.r, 12)),
              ),
              child: Text(
                'Mock auth · any valid email + password '
                '(min ${AppConstants.passwordMinLength})\n'
                '${AppConstants.demoEmailHint} / ${AppConstants.demoPasswordHint}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: Responsive.s(context, 11.5.sp, 12),
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
