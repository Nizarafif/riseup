import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/revenue_cat_service.dart';
import '../services/notification_service.dart';

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
  bool _trialSetupCompleted = false;
  bool _isPremium = false;
  bool _initialMoodSetupCompleted = false;
  int? _initialMoodLevel;
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
  bool get trialSetupCompleted => _trialSetupCompleted;
  bool get isPremium => _isPremium;
  bool get initialMoodSetupCompleted => _initialMoodSetupCompleted;
  int? get initialMoodLevel => _initialMoodLevel;
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

  Future<void> completePaletteSetup(int paletteIndex, int emojiThemeIndex, int backgroundThemeIndex) async {
    _selectedPaletteIndex = paletteIndex;
    _selectedEmojiThemeIndex = emojiThemeIndex;
    _selectedBackgroundThemeIndex = backgroundThemeIndex;
    _paletteSetupCompleted = true;
    notifyListeners();
    _persistTheme(paletteIndex, emojiThemeIndex, backgroundThemeIndex);

    if (_user != null) {
      try {
        final updatedUser = await _authService.updateUserThemePreferences(
          paletteIndex,
          emojiThemeIndex,
          backgroundThemeIndex,
        );
        _user = updatedUser;
        notifyListeners();
      } catch (e) {
        debugPrint('Gagal memperbarui preferensi tema di database: $e');
      }
    }
  }

  Future<void> updateBackgroundTheme(int index) async {
    _selectedBackgroundThemeIndex = index;
    notifyListeners();
    _persistTheme(_selectedPaletteIndex, _selectedEmojiThemeIndex, index);

    if (_user != null) {
      try {
        final updatedUser = await _authService.updateUserThemePreferences(
          _selectedPaletteIndex,
          _selectedEmojiThemeIndex,
          index,
        );
        _user = updatedUser;
        notifyListeners();
      } catch (e) {
        debugPrint('Gagal memperbarui preferensi background di database: $e');
      }
    }
  }

  void resetPaletteSetup() {
    _paletteSetupCompleted = false;
    _privacyAccepted = false;
    _selectedBackgroundThemeIndex = 0;
    notifyListeners();
  }

  void editMoodTheme() {
    _paletteSetupCompleted = false;
    _initialMoodSetupCompleted = false;
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
    NotificationService().scheduleDailyReminder(time);
  }

  void resetReminderSetup() {
    _reminderSetupCompleted = false;
    _activitySetupCompleted = false;
    notifyListeners();
  }

  void completeTrialSetup() {
    _trialSetupCompleted = true;
    notifyListeners();
  }

  void completeInitialMoodSetup() {
    _initialMoodSetupCompleted = true;
    _persistOnboardingCompleted();
    notifyListeners();
  }

  Future<void> _persistOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (e) {
      debugPrint('Gagal menyimpan status onboarding: $e');
    }
  }

  void resetInitialMoodSetup() {
    _initialMoodSetupCompleted = false;
    _reminderSetupCompleted = false;
    notifyListeners();
  }

  void setInitialMoodLevel(int? level) {
    _initialMoodLevel = level;
    notifyListeners();
  }

  void setPremiumStatus(bool premium) {
    _isPremium = premium;
    notifyListeners();
  }

  Future<void> updatePremiumStatus() async {
    final status = await RevenueCatService.checkPremiumStatus();
    _isPremium = status;
    notifyListeners();
  }

  Future<bool> updateProfile(String newName, int avatarIndex, String photoUrl) async {
    try {
      final updatedUser = await _authService.updateUserProfile(newName, avatarIndex, photoUrl);
      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Gagal memperbarui profil: $e');
      return false;
    }
  }

  void resetTrialSetup() {
    _trialSetupCompleted = false;
    _reminderSetupCompleted = false;
    notifyListeners();
  }

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      await _authService.initialize();
      
      // Muat status onboarding dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final isCompleted = prefs.getBool('onboarding_completed') ?? false;
      if (isCompleted) {
        _onboardingCompleted = true;
        _privacyAccepted = true;
        _paletteSetupCompleted = true;
        _activitySetupCompleted = true;
        _reminderSetupCompleted = true;
        _initialMoodSetupCompleted = true;
      }
      // Muat tema yang tersimpan dari SharedPreferences (untuk tamu atau sebelum login)
      _selectedPaletteIndex = prefs.getInt('selected_palette_index') ?? 0;
      _selectedEmojiThemeIndex = prefs.getInt('selected_emoji_theme_index') ?? 0;
      _selectedBackgroundThemeIndex = prefs.getInt('selected_background_theme_index') ?? 0;
    } catch (e) {
      debugPrint("Error in _initAuth during initialize: $e");
    } finally {
      _user = _authService.currentUser;
      if (_user != null) {
        _selectedPaletteIndex = _user!.paletteIndex;
        _selectedEmojiThemeIndex = _user!.emojiThemeIndex;
        _selectedBackgroundThemeIndex = _user!.backgroundThemeIndex;
        
        // Jika user terautentikasi, tandai onboarding selesai
        _onboardingCompleted = true;
        _privacyAccepted = true;
        _paletteSetupCompleted = true;
        _activitySetupCompleted = true;
        _reminderSetupCompleted = true;
        _initialMoodSetupCompleted = true;
        _persistOnboardingCompleted();
        _persistTheme(_selectedPaletteIndex, _selectedEmojiThemeIndex, _selectedBackgroundThemeIndex);
      }
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
      _selectedPaletteIndex = _user!.paletteIndex;
      _selectedEmojiThemeIndex = _user!.emojiThemeIndex;
      _selectedBackgroundThemeIndex = _user!.backgroundThemeIndex;
      _persistTheme(_selectedPaletteIndex, _selectedEmojiThemeIndex, _selectedBackgroundThemeIndex);
      
      // Tandai onboarding selesai saat berhasil login
      _onboardingCompleted = true;
      _privacyAccepted = true;
      _paletteSetupCompleted = true;
      _activitySetupCompleted = true;
      _reminderSetupCompleted = true;
      _initialMoodSetupCompleted = true;
      _persistOnboardingCompleted();

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
      _selectedPaletteIndex = _user!.paletteIndex;
      _selectedEmojiThemeIndex = _user!.emojiThemeIndex;
      _selectedBackgroundThemeIndex = _user!.backgroundThemeIndex;
      _persistTheme(_selectedPaletteIndex, _selectedEmojiThemeIndex, _selectedBackgroundThemeIndex);

      // Tandai onboarding selesai saat berhasil login
      _onboardingCompleted = true;
      _privacyAccepted = true;
      _paletteSetupCompleted = true;
      _activitySetupCompleted = true;
      _reminderSetupCompleted = true;
      _initialMoodSetupCompleted = true;
      _persistOnboardingCompleted();

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

  // Aksi Login Sebagai Tamu (Anonymous Login)
  Future<bool> signInAnonymously() async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = '';
      notifyListeners();

      _user = await _authService.signInAnonymously();
      _selectedPaletteIndex = _user!.paletteIndex;
      _selectedEmojiThemeIndex = _user!.emojiThemeIndex;
      _selectedBackgroundThemeIndex = _user!.backgroundThemeIndex;
      _persistTheme(_selectedPaletteIndex, _selectedEmojiThemeIndex, _selectedBackgroundThemeIndex);

      // Tandai onboarding selesai saat berhasil masuk tamu
      _onboardingCompleted = true;
      _privacyAccepted = true;
      _paletteSetupCompleted = true;
      _activitySetupCompleted = true;
      _reminderSetupCompleted = true;
      _initialMoodSetupCompleted = true;
      _persistOnboardingCompleted();

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
      _selectedPaletteIndex = _user!.paletteIndex;
      _selectedEmojiThemeIndex = _user!.emojiThemeIndex;
      _selectedBackgroundThemeIndex = _user!.backgroundThemeIndex;
      _persistTheme(_selectedPaletteIndex, _selectedEmojiThemeIndex, _selectedBackgroundThemeIndex);

      // Tandai onboarding selesai saat berhasil registrasi
      _onboardingCompleted = true;
      _privacyAccepted = true;
      _paletteSetupCompleted = true;
      _activitySetupCompleted = true;
      _reminderSetupCompleted = true;
      _initialMoodSetupCompleted = true;
      _persistOnboardingCompleted();

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
    try {
      await NotificationService().cancelAll();
    } catch (e) {
      debugPrint('Gagal membatalkan notifikasi saat signOut: $e');
    }
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    
    // Setel bendera onboarding & setup ke true agar pengguna diarahkan langsung ke Login Screen, bukan onboarding
    _onboardingCompleted = true;
    _privacyAccepted = true;
    _paletteSetupCompleted = true;
    _activitySetupCompleted = true;
    _reminderSetupCompleted = true;
    _initialMoodSetupCompleted = true;
    
    // Jangan reset local customization state agar halaman login tetap mengikuti tema terakhir yang disetel
    
    notifyListeners();
  }

  Future<void> _persistTheme(int paletteIndex, int emojiThemeIndex, int backgroundThemeIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selected_palette_index', paletteIndex);
      await prefs.setInt('selected_emoji_theme_index', emojiThemeIndex);
      await prefs.setInt('selected_background_theme_index', backgroundThemeIndex);
    } catch (e) {
      debugPrint('Gagal menyimpan tema di SharedPreferences: $e');
    }
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
