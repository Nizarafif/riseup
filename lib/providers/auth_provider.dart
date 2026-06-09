import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, authenticating, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String _errorMessage = '';
  bool _onboardingCompleted = false;
  bool _privacyAccepted = false;
  bool _paletteSetupCompleted = false;
  int _selectedPaletteIndex = 0;
  int _selectedEmojiThemeIndex = 0;
  int _selectedBackgroundThemeIndex = 0;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String get errorMessage => _errorMessage;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get privacyAccepted => _privacyAccepted;
  bool get paletteSetupCompleted => _paletteSetupCompleted;
  int get selectedPaletteIndex => _selectedPaletteIndex;
  int get selectedEmojiThemeIndex => _selectedEmojiThemeIndex;
  int get selectedBackgroundThemeIndex => _selectedBackgroundThemeIndex;

  void completeOnboarding() {
    _onboardingCompleted = true;
    notifyListeners();
  }

  void resetOnboarding() {
    _onboardingCompleted = false;
    notifyListeners();
  }

  void acceptPrivacy() {
    _privacyAccepted = true;
    notifyListeners();
  }

  void rejectPrivacy() {
    _privacyAccepted = false;
    _onboardingCompleted = false;
    notifyListeners();
  }

  void completePaletteSetup(int paletteIndex, int emojiThemeIndex, int backgroundThemeIndex) {
    _selectedPaletteIndex = paletteIndex;
    _selectedEmojiThemeIndex = emojiThemeIndex;
    _selectedBackgroundThemeIndex = backgroundThemeIndex;
    _paletteSetupCompleted = true;
    notifyListeners();
  }

  void updateBackgroundTheme(int index) {
    _selectedBackgroundThemeIndex = index;
    notifyListeners();
  }

  void resetPaletteSetup() {
    _paletteSetupCompleted = false;
    _privacyAccepted = false;
    _selectedBackgroundThemeIndex = 0;
    notifyListeners();
  }

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

