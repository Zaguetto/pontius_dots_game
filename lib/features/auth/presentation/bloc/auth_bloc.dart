import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../game/domain/entities/player.dart';
import '../../domain/repositories/player_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LoginEvent extends AuthEvent {
  final Player player;
  const LoginEvent(this.player);

  @override
  List<Object?> get props => [player];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final Player player;
  const Authenticated(this.player);

  @override
  List<Object?> get props => [player];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PlayerRepository playerRepository;

  AuthBloc({required this.playerRepository}) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await playerRepository.getCurrentPlayer();

    result.fold(
      (failure) => emit(const Unauthenticated()),
      (player) => player != null
          ? emit(Authenticated(player))
          : emit(const Unauthenticated()),
    );
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await playerRepository.savePlayer(event.player);

    result.fold(
      (failure) => emit(const Unauthenticated()),
      (_) => emit(Authenticated(event.player)),
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await playerRepository.clearPlayer();
    emit(const Unauthenticated());
  }
}
