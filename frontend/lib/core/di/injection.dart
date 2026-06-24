import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../network/socket_client.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/games/bloc/game_bloc.dart';
import '../../features/games/repository/game_repository.dart';
import '../../features/student/bloc/student_bloc.dart';
import '../../features/student/bloc/leaderboard_bloc.dart';
import '../../features/student/repository/student_repository.dart';
import '../../features/teacher/bloc/teacher_bloc.dart';
import '../../features/teacher/repository/teacher_repository.dart';
import '../../features/notifications/service/notification_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<SocketClient>(() => SocketClient());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton<GameRepository>(() => GameRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton<StudentRepository>(() => StudentRepository(getIt<ApiClient>()));
  getIt.registerLazySingleton<TeacherRepository>(() => TeacherRepository(getIt<ApiClient>()));

  // Services
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // BLoCs (factory = new instance each time)
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory<GameBloc>(() => GameBloc(
    getIt<GameRepository>(),
    getIt<SocketClient>(),
  ));
  getIt.registerFactory<StudentBloc>(() => StudentBloc(getIt<StudentRepository>()));
  getIt.registerFactory<LeaderboardBloc>(() => LeaderboardBloc(getIt<ApiClient>()));
  getIt.registerFactory<TeacherBloc>(() => TeacherBloc(getIt<TeacherRepository>()));
}
