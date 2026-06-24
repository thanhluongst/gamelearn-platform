import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repository/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckEvent extends AuthEvent {}
class AuthLoginEvent extends AuthEvent {
  final String identifier;
  final String password;
  AuthLoginEvent(this.identifier, this.password);
  @override
  List<Object?> get props => [identifier, password];
}
class AuthLogoutEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoadingState extends AuthState {}
class AuthUnauthenticatedState extends AuthState {}
class AuthAuthenticatedState extends AuthState {
  final dynamic user;
  AuthAuthenticatedState(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(AuthLoadingState()) {
    on<AuthCheckEvent>(_onCheck);
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
  }

  Future<void> _onCheck(AuthCheckEvent event, Emitter<AuthState> emit) async {
    try {
      final user = await _repo.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticatedState(user));
      } else {
        emit(AuthUnauthenticatedState());
      }
    } catch (_) {
      emit(AuthUnauthenticatedState());
    }
  }

  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final result = await _repo.login(event.identifier, event.password);
      emit(AuthAuthenticatedState(result['user']));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    await _repo.logout();
    emit(AuthUnauthenticatedState());
  }
}
