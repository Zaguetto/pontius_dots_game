import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/game/domain/usecases/make_move_usecases.dart';
import '../../features/game/domain/usecases/bot_move_usecase.dart';
import '../../features/game/presentation/bloc/game_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/data/repositories/player_repository_impl.dart';
import '../../features/auth/domain/repositories/player_repository.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Repositories
  getIt.registerLazySingleton<PlayerRepository>(
    () => PlayerRepositoryImpl(getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => MakeMoveUseCase());
  getIt.registerLazySingleton(() => BotMoveUseCase(getIt()));

  // BLoCs
  getIt.registerFactory(() => GameBloc(
        makeMoveUseCase: getIt(),
        botMoveUseCase: getIt(),
      ));

  getIt.registerFactory(() => AuthBloc(
        playerRepository: getIt(),
      ));
}
