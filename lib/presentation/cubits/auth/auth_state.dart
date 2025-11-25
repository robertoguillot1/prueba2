import 'package:equatable/equatable.dart';
import '../../../domain/entities/auth/user_entity.dart';

/// Estados de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial de autenticación
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carga (verificando o intentando autenticar)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado cuando hay un usuario autenticado
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Estado cuando no hay usuario autenticado
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Estado cuando ocurre un error en la autenticación
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}


