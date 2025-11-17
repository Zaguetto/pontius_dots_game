import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/position.dart';
import '../../domain/usecases/make_move_usecases.dart';
import '../../domain/usecases/bot_move_usecase.dart';
import '../../../../core/error/failures.dart';

// Events
abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class StartGameEvent extends GameEvent {
  final GameMode mode;
  final int gridSize;
  final Player player1;
  final Player? player2;

  const StartGameEvent({
    required this.mode,
    required this.gridSize,
    required this.player1,
    this.player2,
  });

  @override
  List<Object?> get props => [mode, gridSize, player1, player2];
}

class MakeMoveEvent extends GameEvent {
  final Position start;
  final Position end;

  const MakeMoveEvent({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

class BotMoveEvent extends GameEvent {
  const BotMoveEvent();
}

class PauseGameEvent extends GameEvent {
  const PauseGameEvent();
}

class ResumeGameEvent extends GameEvent {
  const ResumeGameEvent();
}

class ResetGameEvent extends GameEvent {
  const ResetGameEvent();
}

// States
abstract class GameBlocState extends Equatable {
  const GameBlocState();
  @override
  List<Object?> get props => [];
}

class GameInitial extends GameBlocState {
  const GameInitial();
}

class GameLoading extends GameBlocState {
  const GameLoading();
}

class GameInProgress extends GameBlocState {
  final GameState game;

  const GameInProgress(this.game);

  @override
  List<Object?> get props => [game];
}

class GameFinished extends GameBlocState {
  final GameState game;

  const GameFinished(this.game);

  @override
  List<Object?> get props => [game];
}

class GameError extends GameBlocState {
  final String message;

  const GameError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class GameBloc extends Bloc<GameEvent, GameBlocState> {
  final MakeMoveUseCase makeMoveUseCase;
  final BotMoveUseCase botMoveUseCase;

  GameBloc({
    required this.makeMoveUseCase,
    required this.botMoveUseCase,
  }) : super(const GameInitial()) {
    on<StartGameEvent>(_onStartGame);
    on<MakeMoveEvent>(_onMakeMove);
    on<BotMoveEvent>(_onBotMove);
    on<PauseGameEvent>(_onPauseGame);
    on<ResumeGameEvent>(_onResumeGame);
    on<ResetGameEvent>(_onResetGame);
  }

  Future<void> _onStartGame(
    StartGameEvent event,
    Emitter<GameBlocState> emit,
  ) async {
    emit(const GameLoading());

    try {
      final players = <Player>[event.player1];

      if (event.mode == GameMode.onePlayer) {
        players.add(
          Player(
            id: const Uuid().v4(),
            name: 'Bot',
            icon: '🤖',
            isBot: true,
          ),
        );
      } else if (event.player2 != null) {
        players.add(event.player2!);
      }

      final game = GameState(
        id: const Uuid().v4(),
        mode: event.mode,
        status: GameStatus.playing,
        gridSize: event.gridSize,
        players: players,
      );

      emit(GameInProgress(game));
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  Future<void> _onMakeMove(
    MakeMoveEvent event,
    Emitter<GameBlocState> emit,
  ) async {
    if (state is! GameInProgress) return;

    final currentGame = (state as GameInProgress).game;

    try {
      final result = await makeMoveUseCase(
        game: currentGame,
        start: event.start,
        end: event.end,
      );

      result.fold(
        (failure) => emit(GameError(failure is Failure ? failure.message : 'Erro desconhecido')),
        (updatedGame) {
          if (updatedGame.status == GameStatus.finished) {
            emit(GameFinished(updatedGame));
          } else {
            emit(GameInProgress(updatedGame));

            // Se for a vez do bot e não teve turno extra
            if (updatedGame.currentPlayer.isBot && !updatedGame.hasExtraTurn) {
              add(const BotMoveEvent());
            }
          }
        },
      );
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  Future<void> _onBotMove(
    BotMoveEvent event,
    Emitter<GameBlocState> emit,
  ) async {
    if (state is! GameInProgress) return;

    final currentGame = (state as GameInProgress).game;

    // Pequeno delay para simular "pensamento"
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final result = await botMoveUseCase(currentGame);

      result.fold(
        (failure) => emit(GameError(failure is Failure ? failure.message : 'Erro desconhecido')),
        (updatedGame) {
          if (updatedGame.status == GameStatus.finished) {
            emit(GameFinished(updatedGame));
          } else {
            emit(GameInProgress(updatedGame));

            // Se o bot ganhou turno extra, joga de novo
            if (updatedGame.currentPlayer.isBot && updatedGame.hasExtraTurn) {
              add(const BotMoveEvent());
            }
          }
        },
      );
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  void _onPauseGame(
    PauseGameEvent event,
    Emitter<GameBlocState> emit,
  ) {
    if (state is GameInProgress) {
      final game = (state as GameInProgress).game;
      emit(GameInProgress(game.copyWith(status: GameStatus.paused)));
    }
  }

  void _onResumeGame(
    ResumeGameEvent event,
    Emitter<GameBlocState> emit,
  ) {
    if (state is GameInProgress) {
      final game = (state as GameInProgress).game;
      emit(GameInProgress(game.copyWith(status: GameStatus.playing)));
    }
  }

  void _onResetGame(
    ResetGameEvent event,
    Emitter<GameBlocState> emit,
  ) {
    emit(const GameInitial());
  }
}
