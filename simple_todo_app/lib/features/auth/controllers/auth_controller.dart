import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:simple_todo_app/data/models/user_model.dart';
import 'package:simple_todo_app/data/services/supabase_service.dart';

class AuthController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final currentUser = Rxn<UserProfile>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final user = _supabaseService.currentUser;
      if (user != null) {
        final profile = await _supabaseService.getProfile(user.id);
        if (profile != null) {
          currentUser.value = profile;
          Get.offAllNamed('/home');
        } else {
          Get.offAllNamed('/profile-setup');
        }
      } else {
        Get.offAllNamed('/auth');
      }
    } catch (e) {
      Get.offAllNamed('/auth');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final response = await _supabaseService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        Get.offAllNamed('/profile-setup');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value!,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final profile = await _supabaseService.getProfile(response.user!.id);
        if (profile != null) {
          currentUser.value = profile;
          Get.offAllNamed('/home');
        } else {
          Get.offAllNamed('/profile-setup');
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value!,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _supabaseService.signOut();
      currentUser.value = null;
      Get.offAllNamed('/auth');
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProfile({
    required String fullName,
    required String ultimateGoal,
    String? profileImageUrl,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No user logged in');

      final profile = await _supabaseService.createProfile(
        userId: user.id,
        email: user.email!,
        fullName: fullName,
        ultimateGoal: ultimateGoal,
        profileImageUrl: profileImageUrl,
      );

      currentUser.value = profile;
      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value!,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? ultimateGoal,
    String? profileImageUrl,
  }) async {
    try {
      isLoading.value = true;

      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('No user logged in');

      final profile = await _supabaseService.updateProfile(
        userId: user.id,
        fullName: fullName,
        ultimateGoal: ultimateGoal,
        profileImageUrl: profileImageUrl,
      );

      currentUser.value = profile;
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}