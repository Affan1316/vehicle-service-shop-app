import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final LogoutUseCase _logoutUseCase;
  final SecureStorage _secureStorage;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required GetProfileUseCase getProfileUseCase,
    required LogoutUseCase logoutUseCase,
    required SecureStorage secureStorage,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _getProfileUseCase = getProfileUseCase,
        _logoutUseCase = logoutUseCase,
        _secureStorage = secureStorage,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    // Read token to quiet unused field warning while keeping auto-login disabled
    final _ = await _secureStorage.getAccessToken();
    emit(Unauthenticated());
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final loginResult = await _loginUseCase(event.username, event.password);
    await loginResult.fold(
      (failure) async => emit(AuthError(failure.message)),
      (token) async {
        final profileResult = await _getProfileUseCase();
        profileResult.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(Authenticated(user)),
        );
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final registerResult = await _registerUseCase(
      username: event.username,
      email: event.email,
      password: event.password,
      role: event.role,
    );

    await registerResult.fold(
      (failure) async => emit(AuthError(failure.message)),
      (user) async {
        // Automatically login the user after registration
        final loginResult = await _loginUseCase(event.username, event.password);
        await loginResult.fold(
          (failure) async => emit(AuthError(failure.message)),
          (token) async {
            final profileResult = await _getProfileUseCase();
            profileResult.fold(
              (failure) => emit(AuthError(failure.message)),
              (user) => emit(Authenticated(user)),
            );
          },
        );
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _logoutUseCase();
    emit(Unauthenticated());
  }
}
