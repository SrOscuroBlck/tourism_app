// lib/presentation/blocs/auth/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/constants/storage_constants.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final FlutterSecureStorage _secureStorage;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required FlutterSecureStorage secureStorage,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _secureStorage = secureStorage,
        super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final token = await _secureStorage.read(key: StorageConstants.authToken);

    if (token != null) {
      final userId = await _secureStorage.read(key: StorageConstants.userId);
      final userEmail = await _secureStorage.read(key: StorageConstants.userEmail);
      final userName = await _secureStorage.read(key: StorageConstants.userName);
      final userRole = await _secureStorage.read(key: StorageConstants.userRole);

      if (userId != null && userEmail != null && userName != null && userRole != null) {
        final user = User(
          id: int.parse(userId),
          email: userEmail,
          name: userName,
          role: userRole,
        );
        emit(Authenticated(user: user));
      } else {
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await _loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));

    await result.fold(
          (failure) async {
        emit(AuthError(message: failure.message ?? 'Login failed'));
      },
          (user) async {
        // The repository did not return a token inside the User—so assume
        // that the remote data source already wrote it to secure storage,
        // or that our repository stored it earlier. If you still need the
        // raw token, consider returning a custom object from login().
        //
        // For now, we just re‐read the token from storage and keep the User in state.
        final token = await _secureStorage.read(key: StorageConstants.authToken);
        // If your API client hasn’t already written it, you could do:
        // await _secureStorage.write(key: StorageConstants.authToken, value: SOME_TOKEN_HERE);

        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await _registerUseCase(RegisterParams(
      email: event.email,
      password: event.password,
      name: event.name,
    ));

    await result.fold(
          (failure) async {
        emit(AuthError(message: failure.message ?? 'Registration failed'));
      },
          (user) async {
        final token = await _secureStorage.read(key: StorageConstants.authToken);
        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await _logoutUseCase();
    await _secureStorage.deleteAll();
    emit(Unauthenticated());
  }
}
