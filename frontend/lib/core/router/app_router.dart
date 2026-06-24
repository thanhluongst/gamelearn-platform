import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/student/screens/student_home_screen.dart';
import '../../features/student/screens/student_profile_screen.dart';
import '../../features/student/screens/student_leaderboard_screen.dart';
import '../../features/teacher/screens/teacher_home_screen.dart';
import '../../features/teacher/screens/teacher_class_screen.dart';
import '../../features/teacher/screens/teacher_analytics_screen.dart';
import '../../features/games/screens/game_lobby_screen.dart';
import '../../features/games/screens/game_play_screen.dart';
import '../../features/games/screens/game_result_screen.dart';
import '../../features/games/screens/join_game_screen.dart';
import '../../features/questions/screens/question_bank_screen.dart';
import '../../features/questions/screens/import_excel_screen.dart';
import '../../features/admin/screens/admin_home_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuthenticated = authState is AuthAuthenticatedState;
      final isLoading = authState is AuthLoadingState;
      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/';

      if (isLoading) return '/';
      if (!isAuthenticated && !isOnAuthPage) return '/login';
      if (isAuthenticated && isOnAuthPage) {
        final user = (authState as AuthAuthenticatedState).user;
        return switch (user.role) {
          'admin' => '/admin',
          'teacher' => '/teacher',
          _ => '/student',
        };
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Student routes
      ShellRoute(
        builder: (context, state, child) => StudentHomeScreen(child: child),
        routes: [
          GoRoute(path: '/student', builder: (_, __) => const StudentDashboard()),
          GoRoute(path: '/student/profile', builder: (_, __) => const StudentProfileScreen()),
          GoRoute(path: '/student/leaderboard', builder: (_, __) => const StudentLeaderboardScreen()),
        ],
      ),

      // Teacher routes
      ShellRoute(
        builder: (context, state, child) => TeacherHomeScreen(child: child),
        routes: [
          GoRoute(path: '/teacher', builder: (_, __) => const TeacherDashboard()),
          GoRoute(
            path: '/teacher/class/:classId',
            builder: (_, state) => TeacherClassScreen(classId: state.pathParameters['classId']!),
          ),
          GoRoute(
            path: '/teacher/analytics/:classId',
            builder: (_, state) => TeacherAnalyticsScreen(classId: state.pathParameters['classId']!),
          ),
          GoRoute(path: '/teacher/questions', builder: (_, __) => const QuestionBankScreen()),
          GoRoute(path: '/teacher/import', builder: (_, __) => const ImportExcelScreen()),
        ],
      ),

      // Game routes (full screen, no shell)
      GoRoute(
        path: '/game/join',
        builder: (_, __) => const JoinGameScreen(),
      ),
      GoRoute(
        path: '/game/lobby/:sessionId',
        builder: (_, state) => GameLobbyScreen(sessionId: state.pathParameters['sessionId']!),
      ),
      GoRoute(
        path: '/game/play/:sessionId',
        builder: (_, state) => GamePlayScreen(sessionId: state.pathParameters['sessionId']!),
      ),
      GoRoute(
        path: '/game/result/:sessionId',
        builder: (_, state) => GameResultScreen(sessionId: state.pathParameters['sessionId']!),
      ),

      // Admin routes
      GoRoute(path: '/admin', builder: (_, __) => const AdminHomeScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Trang không tìm thấy', style: Theme.of(context).textTheme.headlineMedium),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Placeholder screens (implemented below in detail)
class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
