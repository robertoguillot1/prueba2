import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    // Escuchar cambios en el estado de autenticación
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Iniciar sesión con email y contraseña
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = userCredential.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      AppLogger.info('User signed in successfully', {'email': email});
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();

      AppLogger.error('Error signing in', e, StackTrace.current);
      return false;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Error inesperado al iniciar sesión';
      notifyListeners();

      AppLogger.error('Unexpected error signing in', e, stackTrace);
      return false;
    }
  }

  // Registrar nuevo usuario con email y contraseña
  Future<bool> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Actualizar el nombre del usuario
      if (userCredential.user != null && name.isNotEmpty) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
        _user = _auth.currentUser;
      } else {
        _user = userCredential.user;
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      AppLogger.info('User registered successfully', {'email': email, 'name': name});
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();

      AppLogger.error('Error registering user', e, StackTrace.current);
      return false;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Error inesperado al registrar usuario';
      notifyListeners();

      AppLogger.error('Unexpected error registering user', e, stackTrace);
      return false;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signOut();
      _user = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();

      AppLogger.info('User signed out successfully');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Error al cerrar sesión';
      notifyListeners();

      AppLogger.error('Error signing out', e, stackTrace);
    }
  }

  // Convertir códigos de error de Firebase a mensajes en español
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico';
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Por favor, intenta más tarde';
      case 'operation-not-allowed':
        return 'Esta operación no está permitida';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      default:
        return 'Error al autenticar. Por favor, intenta nuevamente';
    }
  }
}









