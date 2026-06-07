import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, authenticating, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String _errorMessage = '';

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      await _authService.initialize();
    } catch (e) {
      debugPrint("Error in _initAuth during initialize: $e");
    } finally {
      _user = _authService.currentUser;
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // Aksi Sign In
  Future<bool> signIn(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = '';
      notifyListeners();

      _user = await _authService.signIn(email, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // Aksi Sign Up
  Future<bool> signUp(String name, String email, String password, {String role = 'user'}) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = '';
      notifyListeners();

      _user = await _authService.signUp(name, email, password, role: role);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // Aksi Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Clear Error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Aksi Reset Password
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _errorMessage = '';
      notifyListeners();
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return false;
    }
  }
}

