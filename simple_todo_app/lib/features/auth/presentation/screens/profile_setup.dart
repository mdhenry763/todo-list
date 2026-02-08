import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_todo_app/core/constants/app_constants.dart';
import 'package:simple_todo_app/core/custom_widgets.dart/custom_button.dart';
import 'package:simple_todo_app/core/custom_widgets.dart/custom_text_field.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';

class ProfileSetupScreen extends GetView<AuthController> {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fullNameController = TextEditingController();
    final goalController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final selectedImage = Rxn<File>();

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    }

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
                
                // Title
                Text(
                  AppStrings.setupProfile,
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.textXXL,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  'Tell us about yourself to personalize your experience',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.textM,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),

                // Profile Image
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Obx(() => Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: selectedImage.value == null
                            ? LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        image: selectedImage.value != null
                            ? DecorationImage(
                                image: FileImage(selectedImage.value!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: selectedImage.value == null
                          ? const Icon(
                              Iconsax.user,
                              size: 48,
                              color: Colors.white,
                            )
                          : null,
                    )),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Center(
                  child: TextButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Iconsax.camera, size: AppSizes.iconS),
                    label: Text(
                      'Add Profile Photo',
                      style: GoogleFonts.inter(fontSize: AppSizes.textS),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXL),

                // Full Name Field
                CustomTextField(
                  label: AppStrings.fullName,
                  hint: 'Enter your full name',
                  controller: fullNameController,
                  prefixIcon: Iconsax.user,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.paddingM),

                // Ultimate Goal Field
                CustomTextField(
                  label: AppStrings.ultimateGoal,
                  hint: 'What do you want to achieve?',
                  controller: goalController,
                  prefixIcon: Iconsax.flag,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please share your goal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.paddingXL),

                // Complete Setup Button
                Obx(() => CustomButton(
                  text: 'Complete Setup',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      controller.createProfile(
                        fullName: fullNameController.text.trim(),
                        ultimateGoal: goalController.text.trim(),
                        profileImageUrl: selectedImage.value?.path,
                      );
                    }
                  },
                  isLoading: controller.isLoading.value,
                  icon: Iconsax.tick_circle,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}