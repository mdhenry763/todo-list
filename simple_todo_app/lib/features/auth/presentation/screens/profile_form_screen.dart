import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_todo_app/core/constants/app_constants.dart';
import 'package:simple_todo_app/core/custom_widgets.dart/custom_button.dart';
import 'package:simple_todo_app/core/custom_widgets.dart/custom_text_field.dart';
import 'package:simple_todo_app/data/models/user_model.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';
class ProfileFormScreen extends GetView<AuthController> {
  const ProfileFormScreen({super.key});

  // Check if we're editing an existing profile
  bool get isEditMode => Get.arguments != null;
  UserProfile? get existingProfile => Get.arguments as UserProfile?;

  @override
  Widget build(BuildContext context) {
    final fullNameController = TextEditingController(
      text: existingProfile?.fullName,
    );
    final goalController = TextEditingController(
      text: existingProfile?.ultimateGoal,
    );
    final formKey = GlobalKey<FormState>();
    final selectedImage = Rxn<File>();
    
    // Set initial image URL if editing
    final currentImageUrl = (existingProfile?.profileImageUrl).obs;

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
        currentImageUrl.value = null; // Clear network image when new image selected
      }
    }

    Future<void> handleSubmit() async {
      if (!formKey.currentState!.validate()) return;

      if (isEditMode) {
        // Update existing profile
        await controller.updateProfile(
          fullName: fullNameController.text.trim(),
          ultimateGoal: goalController.text.trim(),
          profileImageUrl: selectedImage.value?.path,
        );
      } else {
        // Create new profile
        await controller.createProfile(
          fullName: fullNameController.text.trim(),
          ultimateGoal: goalController.text.trim(),
          profileImageUrl: selectedImage.value?.path,
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isEditMode
          ? AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
                onPressed: () => Get.back(),
              ),
              title: Text(
                'Edit Profile',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.textL,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isEditMode) ...[
                  const SizedBox(height: AppSizes.paddingXL),
                  // Title (only for setup)
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
                ],

                // Profile Image
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Obx(() {
                      // Show selected image
                      if (selectedImage.value != null) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: FileImage(selectedImage.value!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                      
                      // Show existing network image (edit mode)
                      if (currentImageUrl.value != null && currentImageUrl.value!.isNotEmpty) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(currentImageUrl.value!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                      
                      // Show default gradient avatar
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Iconsax.user,
                          size: 48,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Center(
                  child: TextButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Iconsax.camera, size: AppSizes.iconS),
                    label: Text(
                      isEditMode ? 'Change Photo' : 'Add Profile Photo',
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

                // Submit Button
                Obx(() => CustomButton(
                  text: isEditMode ? 'Save Changes' : 'Complete Setup',
                  onPressed: handleSubmit,
                  isLoading: controller.isLoading.value,
                  icon: isEditMode ? Iconsax.tick_circle : Iconsax.tick_circle,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}