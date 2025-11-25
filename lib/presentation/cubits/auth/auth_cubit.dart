import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/auth/user_entity.dart';
import '../../../domain/usecases/auth/get_current_user.dart';
import '../../../domain/usecases/auth/sign_in.dart';
import '../../../domain/usecases/auth/sign_out.dart';
import 'auth_state.dart';

/// Cubit para manejar el estado de autenticación
class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUser getCurrentUser;
  final SignIn signInUseCase;
  final SignOut signOutUseCase;

  AuthCubit({
    required this.getCurrentUser,
    required this.signInUseCase,
    required this.signOutUseCase,
  }) : super(const AuthInitial());

  /// Verifica el estado de autenticación actual
  /// Emite AuthLoading, luego Authenticated si hay usuario o Unauthenticated si no
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(AuthError('Error al verificar el estado de autenticación: $e'));
    }
  }

  /// Inicia sesión con email y contraseña
  /// Emite AuthLoading, luego Authenticated si tiene éxito, o AuthError si falla
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      await signInUseCase.call(email: email, password: password);
      // Después de iniciar sesión, obtener el usuario actual
      final user = await getCurrentUser.call();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Error: No se pudo obtener el usuario después del login'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Cierra sesión del usuario actual
  /// Emite Unauthenticated después de cerrar sesión
  Future<void> signOut() async {
    try {
      await signOutUseCase.call();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError('Error al cerrar sesión: $e'));
    }
  }
}

