import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:simple_todo_app/core/constants/app_constants.dart';
import 'package:simple_todo_app/core/custom_widgets.dart/custom_button.dart';
import 'package:simple_todo_app/core/custom_widgets.dart/custom_text_field.dart';
import '../../controllers/auth_controller.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSignIn = true.obs;
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.paddingXL),
                // Logo/Icon
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: const Icon(
                    Iconsax.task_square5,
                    color: Colors.white,
                    size: AppSizes.iconXL,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),
                
                // Title
                Obx(() => Text(
                  isSignIn.value ? AppStrings.welcomeBack : AppStrings.getStarted,
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.textXXL,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                )),
                const SizedBox(height: AppSizes.paddingS),
                Obx(() => Text(
                  isSignIn.value
                      ? 'Sign in to continue to ${AppStrings.appName}'
                      : 'Create an account to get started',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.textM,
                    color: AppColors.textSecondary,
                  ),
                )),
                const SizedBox(height: AppSizes.paddingXL),

                // Email Field
                CustomTextField(
                  label: AppStrings.email,
                  hint: 'Enter your email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Iconsax.sms,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.paddingM),

                // Password Field
                Obx(() {
                  final obscurePassword = true.obs;
                  return CustomTextField(
                    label: AppStrings.password,
                    hint: 'Enter your password',
                    controller: passwordController,
                    obscureText: obscurePassword.value,
                    prefixIcon: Iconsax.lock,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword.value ? Iconsax.eye_slash : Iconsax.eye,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => obscurePassword.toggle(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  );
                }),
                const SizedBox(height: AppSizes.paddingXL),

                // Sign In/Up Button
                Obx(() => CustomButton(
                  text: isSignIn.value ? AppStrings.signIn : AppStrings.signUp,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (isSignIn.value) {
                        controller.signIn(
                          email: emailController.text.trim(),
                          password: passwordController.text,
                        );
                      } else {
                        controller.signUp(
                          email: emailController.text.trim(),
                          password: passwordController.text,
                        );
                      }
                    }
                  },
                  isLoading: controller.isLoading.value,
                  icon: isSignIn.value ? Iconsax.login : Iconsax.user_add,
                )),
                const SizedBox(height: AppSizes.paddingM),

                // Toggle Sign In/Up
                Center(
                  child: TextButton(
                    onPressed: () => isSignIn.toggle(),
                    child: Obx(() => RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: AppSizes.textS,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: isSignIn.value
                                ? "Don't have an account? "
                                : "Already have an account? ",
                          ),
                          TextSpan(
                            text: isSignIn.value
                                ? AppStrings.signUp
                                : AppStrings.signIn,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}