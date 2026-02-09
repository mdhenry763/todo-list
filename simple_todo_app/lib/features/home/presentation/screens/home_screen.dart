import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:simple_todo_app/core/constants/app_constants.dart';
import 'package:simple_todo_app/features/auth/controllers/auth_controller.dart';
import 'package:simple_todo_app/features/task/controllers/task_controller.dart';
import 'package:simple_todo_app/features/task/presentation/widgets/task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final taskController = Get.put(TaskController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => taskController.loadTasks(),
          color: AppColors.primary,
          backgroundColor: AppColors.cardBackground,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingS),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: const Icon(
                          Iconsax.element_4,
                          color: AppColors.textPrimary,
                          size: AppSizes.iconM,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          print('Navigating to profile setup screen');
                          Get.toNamed('/profile');
                          //Get.toNamed('/profile-setup', arguments: authController.currentUser.value);
                        },
                        icon: Obx(() {
                          final user = authController.currentUser.value;
                          if (user?.profileImageUrl != null) {
                            return CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                user!.profileImageUrl!,
                              ),
                            );
                          }
                          return Container(
                            padding: const EdgeInsets.all(AppSizes.paddingS),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Iconsax.user,
                              color: Colors.white,
                              size: AppSizes.iconM,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // Greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                  ),
                  child: Obx(() {
                    final user = authController.currentUser.value;
                    final firstName =
                        user?.fullName.split(' ').first ?? 'there';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $firstName',
                          style: GoogleFonts.inter(
                            fontSize: AppSizes.textL,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXS),
                        Text(
                          AppStrings.beProductive,
                          style: GoogleFonts.inter(
                            fontSize: AppSizes.textXXL,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSizes.paddingL),
              ),

              // Task Progress Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                  ),
                  child: Obx(
                    () => Container(
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.taskProgress,
                                  style: GoogleFonts.inter(
                                    fontSize: AppSizes.textM,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.paddingXS),
                                Text(
                                  '${taskController.completedTasks}/${taskController.totalTasks} task done',
                                  style: GoogleFonts.inter(
                                    fontSize: AppSizes.textS,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              children: [
                                CircularProgressIndicator(
                                  value:
                                      taskController.progressPercentage / 100,
                                  backgroundColor: AppColors.background,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.info,
                                      ),
                                  strokeWidth: 8,
                                ),
                                Center(
                                  child: Text(
                                    '${taskController.progressPercentage}%',
                                    style: GoogleFonts.inter(
                                      fontSize: AppSizes.textL,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSizes.paddingL),
              ),

              // Today's Tasks Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                  ),
                  child: Text(
                    AppStrings.allTasks,
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.textL,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSizes.paddingM),
              ),

              // Tasks Grid
              Obx(() {
                if (taskController.isLoading.value &&
                    taskController.tasks.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }

                if (taskController.tasks.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.task_square,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppSizes.paddingM),
                          Text(
                            'No tasks yet',
                            style: GoogleFonts.inter(
                              fontSize: AppSizes.textL,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          Text(
                            'Tap the + button to create your first task',
                            style: GoogleFonts.inter(
                              fontSize: AppSizes.textS,
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                print("${taskController.tasks.length} loaded tasks");

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final task = taskController.tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSizes.paddingM,
                        ),
                        child: TaskCard(
                          task: task,
                          onTap: () =>
                              Get.toNamed('/task-detail', arguments: task),
                        ),
                      );
                    }, childCount: taskController.tasks.length),
                  ),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/create-task');
          taskController.loadTasks();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: Text(
          'Add new task',
          style: GoogleFonts.inter(
            fontSize: AppSizes.textM,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
