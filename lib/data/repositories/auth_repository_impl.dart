import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/auth/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementación del repositorio de Autenticación usando Firebase Auth
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  /// Constructor que recibe una instancia de FirebaseAuth
  /// Por defecto usa FirebaseAuth.instance
  AuthRepositoryImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }
      return _mapFirebaseUserToEntity(user);
    } catch (e) {
      // Si hay un error, retornamos null (no hay sesión activa)
      return null;
    }
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Re-lanzamos la excepción para que el caso de uso pueda manejarla
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      // Para otros tipos de errores, lanzamos una excepción genérica
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Re-lanzamos la excepción para que el caso de uso pueda manejarla
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      // Para otros tipos de errores, lanzamos una excepción genérica
      throw Exception('Error al registrar usuario: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /// Mapea el User de Firebase al UserEntity del dominio
  UserEntity _mapFirebaseUserToEntity(User user) {
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
    );
  }

  /// Maneja las excepciones de Firebase Auth y las convierte en excepciones más descriptivas
  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No se encontró una cuenta con este correo electrónico.');
      case 'wrong-password':
        return Exception('La contraseña es incorrecta.');
      case 'invalid-email':
        return Exception('El correo electrónico no es válido.');
      case 'user-disabled':
        return Exception('Esta cuenta ha sido deshabilitada.');
      case 'too-many-requests':
        return Exception('Demasiados intentos fallidos. Intenta más tarde.');
      case 'operation-not-allowed':
        return Exception('Esta operación no está permitida.');
      case 'network-request-failed':
        return Exception('Error de conexión. Verifica tu internet.');
      case 'email-already-in-use':
        return Exception('Este correo electrónico ya está registrado.');
      case 'weak-password':
        return Exception('La contraseña es muy débil. Debe tener al menos 6 caracteres.');
      default:
        return Exception('Error de autenticación: ${e.message}');
    }
  }
}


