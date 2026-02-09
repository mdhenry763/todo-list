import 'package:get/get.dart';
import 'package:simple_todo_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:simple_todo_app/features/auth/presentation/screens/profile_form_screen.dart';
import 'package:simple_todo_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:simple_todo_app/features/home/presentation/screens/home_screen.dart';
import 'package:simple_todo_app/features/task/presentation/screens/create_task_screen.dart';
import 'package:simple_todo_app/features/task/presentation/screens/task_detail_screen.dart';
import 'package:simple_todo_app/main.dart';

class AppPages {
  static const String splash = '/splash';
  static const String home = '/home';

  static final routes = [
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(
      name: '/auth',
      page: () => const AuthScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/profile-setup',
      page: () => const ProfileFormScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/profile',
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/home',
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/create-task',
      page: () => const CreateTaskScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/task-detail',
      page: () => const TaskDetailScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
