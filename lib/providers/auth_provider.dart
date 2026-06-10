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
  bool _activitySetupCompleted = false;
  List<String> _selectedActivities = [];
  bool _reminderSetupCompleted = false;
  TimeOfDay _selectedReminderTime = const TimeOfDay(hour: 20, minute: 0);
  int _selectedPaletteIndex = 0;
  int _selectedEmojiThemeIndex = 0;
  int _selectedBackgroundThemeIndex = 0;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String get errorMessage => _errorMessage;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get privacyAccepted => _privacyAccepted;
  bool get paletteSetupCompleted => _paletteSetupCompleted;
  bool get activitySetupCompleted => _activitySetupCompleted;
  List<String> get selectedActivities => _selectedActivities;
  bool get reminderSetupCompleted => _reminderSetupCompleted;
  TimeOfDay get selectedReminderTime => _selectedReminderTime;
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

  void completeActivitySetup(List<String> activities) {
    _selectedActivities = activities;
    _activitySetupCompleted = true;
    notifyListeners();
  }

  void resetActivitySetup() {
    _activitySetupCompleted = false;
    _paletteSetupCompleted = false;
    notifyListeners();
  }

  void completeReminderSetup(TimeOfDay time) {
    _selectedReminderTime = time;
    _reminderSetupCompleted = true;
    notifyListeners();
  }

  void resetReminderSetup() {
    _reminderSetupCompleted = false;
    _activitySetupCompleted = false;
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
      _errorMessage = _formatAuthError(e);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = '';
      notifyListeners();

      _user = await _authService.signInWithGoogle();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _formatAuthError(e);
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
      _errorMessage = _formatAuthError(e);
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
      _errorMessage = _formatAuthError(e);
      notifyListeners();
      return false;
    }
  }

  String _formatAuthError(Object error) {
    if (error is Exception) {
      final message = error.toString().replaceAll('Exception:', '').trim();
      if (message.contains('email-already-in-use')) {
        return 'Email sudah terdaftar.';
      }
      if (message.contains('invalid-email')) {
        return 'Format email tidak valid.';
      }
      if (message.contains('weak-password')) {
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      }
      if (message.contains('operation-not-allowed')) {
        return 'Login Email/Password belum diaktifkan di Firebase Console.';
      }
      if (message.contains('data pengguna Firebase tidak ditemukan')) {
        return 'Akun berhasil dibuat, tapi sesi Firebase belum siap. Coba login lagi.';
      }
      if (message.contains('permission-denied')) {
        return 'Firestore menolak akses. Cek Firebase rules untuk koleksi users.';
      }
      if (message.contains('popup_closed_by_user')) {
        return 'Login Google dibatalkan sebelum selesai.';
      }
      if (message.contains('GoogleSignInExceptionCode.canceled') || message.contains('GoogleSignInException')) {
        if (message.contains('16') || message.contains('developer_error')) {
          return 'Gagal Login Google: Konfigurasi SHA-1 sidik jari tidak terdaftar di Firebase Console (DEVELOPER_ERROR 16).';
        }
        return 'Login Google dibatalkan oleh pengguna.';
      }
      if (message.contains('popup-blocked')) {
        return 'Popup login Google diblokir browser. Izinkan popup lalu coba lagi.';
      }
      if (message.contains('network-request-failed')) {
        return 'Koneksi ke Firebase gagal. Cek internet atau blokir browser.';
      }
      if (message.contains('account-exists-with-different-credential')) {
        return 'Email ini sudah terdaftar dengan metode login lain.';
      }
      if (message.contains('Google Sign-In tidak tersedia saat mode mock aktif')) {
        return 'Google Sign-In belum siap karena Firebase masih fallback ke mode mock.';
      }
      if (message.contains('Google tidak mengembalikan token login')) {
        return 'Google Sign-In gagal mengambil token akun.';
      }
      if (message.contains('invalid-credential') ||
          message.contains('wrong-password') ||
          message.contains('user-not-found')) {
        return 'Email atau password salah.';
      }
      if (message.contains('too-many-requests')) {
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
      }
      return message;
    }
    return error.toString();
  }
}
