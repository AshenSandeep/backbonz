import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus { idle, loading, success, error }

// Manages authentication state and logic.
class AuthViewModel extends GetxController {
  final AuthService _authService = AuthService();

  final _status = AuthStatus.idle.obs;
  final _errorMessage = RxnString(); // nullable observable String

  AuthStatus get status => _status.value;
  String? get errorMessage => _errorMessage.value;
  bool get isLoading => _status.value == AuthStatus.loading;

  // Sign up a new user
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _setStatus(AuthStatus.loading);
    try {
      await _authService.signUp(email: email, password: password);
      _setStatus(AuthStatus.success);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    }
  }

  // Login existing user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setStatus(AuthStatus.loading);
    try {
      await _authService.login(email: email, password: password);
      _setStatus(AuthStatus.success);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _setStatus(AuthStatus.idle);
  }

  void clearError() {
    _errorMessage.value = null;
    _setStatus(AuthStatus.idle);
  }

  void _setStatus(AuthStatus status) {
    _status.value = status;
  }

  void _setError(String message) {
    _errorMessage.value = message;
    _status.value = AuthStatus.error;
  }

  // Convert Firebase error codes to user-friendly messages
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}