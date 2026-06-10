import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  static const Duration _profileOperationTimeout = Duration(seconds: 8);

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInInitialized = false;
  bool _useMock = true; // Default ke true, disesuaikan di initialize()

  // Sesi Pengguna untuk Mode Simulasi (Mock)
  UserModel? _mockCurrentUser;
  
  final List<UserModel> _mockUsers = [
    UserModel(
      uid: 'mock-user-1',
      email: 'user@riseup.com',
      name: 'Budi Santoso',
      role: 'user',
      createdAt: DateTime.now(),
    ),
    UserModel(
      uid: 'mock-admin-1',
      email: 'admin@riseup.com',
      name: 'Dr. Sarah (Pakar)',
      role: 'admin',
      createdAt: DateTime.now(),
    ),
  ];

  bool get useMock => _useMock;
  UserModel? get currentUser => _mockCurrentUser;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        throw Exception('Firebase belum diinisialisasi di main.dart.');
      }

      _auth = FirebaseAuth.instance;
      await _initializeGoogleSignIn();
      await FirestoreService().initialize();
      _useMock = false;
      debugPrint("Firebase Auth berhasil diinisialisasi.");

      final firebaseUser = _auth!.currentUser;
      if (firebaseUser != null) {
        _mockCurrentUser = await _ensureUserProfile(firebaseUser);
      } else {
        _mockCurrentUser = null;
      }
    } catch (e) {
      debugPrint("Firebase Auth gagal diinisialisasi, beralih ke Mock Mode. Error: $e");
      _useMock = true;
    }
    FirestoreService().setUseMock(_useMock);
  }

  // Login
  Future<UserModel> signIn(String email, String password) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600)); // Simulasi network delay
      try {
        final mockUser = _mockUsers.firstWhere(
          (u) => u.email.trim().toLowerCase() == email.trim().toLowerCase() && password == 'password',
        );
        _mockCurrentUser = mockUser;
        return mockUser;
      } catch (e) {
        throw Exception("Email atau password salah. (Gunakan password: 'password' untuk demo)");
      }
    } else {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user ?? _auth!.currentUser;
      if (firebaseUser == null) {
        throw Exception('Login berhasil, tetapi data pengguna Firebase tidak ditemukan.');
      }

      final appUser = await _ensureUserProfile(firebaseUser);
      _mockCurrentUser = appUser;
      return appUser;
    }
  }

  Future<UserModel> signInWithGoogle() async {
    if (_useMock) {
      throw Exception('Google Sign-In tidak tersedia saat mode mock aktif.');
    }

    UserCredential credential;
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});
      credential = await _auth!.signInWithPopup(googleProvider);
    } else {
      await _initializeGoogleSignIn();
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw Exception('Google tidak mengembalikan token login.');
      }

      final googleCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      credential = await _auth!.signInWithCredential(googleCredential);
    }

    final firebaseUser = credential.user ?? _auth!.currentUser;
    if (firebaseUser == null) {
      throw Exception('Login Google berhasil, tetapi data pengguna Firebase tidak ditemukan.');
    }

    final appUser = await _ensureUserProfile(firebaseUser);
    _mockCurrentUser = appUser;
    return appUser;
  }

  // Registrasi
  Future<UserModel> signUp(String name, String email, String password, {String role = 'user'}) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (_mockUsers.any((u) => u.email.trim().toLowerCase() == email.trim().toLowerCase())) {
        throw Exception("Email sudah terdaftar.");
      }
      final newUser = UserModel(
        uid: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email.trim(),
        name: name.trim(),
        role: role,
        createdAt: DateTime.now(),
      );
      _mockUsers.add(newUser);
      _mockCurrentUser = newUser;
      return newUser;
    } else {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user ?? _auth!.currentUser;
      if (firebaseUser == null) {
        throw Exception('Registrasi berhasil, tetapi data pengguna Firebase tidak ditemukan.');
      }

      final newUser = UserModel(
        uid: firebaseUser.uid,
        email: email.trim(),
        name: name.trim(),
        role: role,
        createdAt: DateTime.now(),
      );
      await _saveUserProfile(newUser);
      await firebaseUser.updateDisplayName(name.trim());
      _mockCurrentUser = newUser;
      return newUser;
    }
  }

  // Logout
  Future<void> signOut() async {
    if (_useMock) {
      _mockCurrentUser = null;
    } else {
      if (!kIsWeb && _googleSignInInitialized) {
        try {
          await _googleSignIn.signOut();
        } catch (e) {
          debugPrint('Google Sign-In local signOut gagal: $e');
        }
      }
      await _auth?.signOut();
      _mockCurrentUser = null;
    }
  }

  // Reset Password / Lupa Kata Sandi
  Future<void> sendPasswordResetEmail(String email) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!email.contains('@')) {
        throw Exception("Format email tidak valid.");
      }
      return;
    } else {
      await _auth!.sendPasswordResetEmail(email: email.trim());
    }
  }

  Future<UserModel> _ensureUserProfile(User firebaseUser) async {
    final userDoc = await _loadUserProfile(firebaseUser.uid);
    if (userDoc != null) {
      return userDoc;
    }

    final newUser = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName?.trim().isNotEmpty == true
          ? firebaseUser.displayName!.trim()
          : _fallbackNameFromEmail(firebaseUser.email),
      role: 'user',
      createdAt: DateTime.now(),
    );
    await _saveUserProfile(newUser);
    return newUser;
  }

  Future<UserModel?> _loadUserProfile(String uid) async {
    try {
      return await FirestoreService()
          .getUserProfile(uid)
          .timeout(_profileOperationTimeout);
    } catch (e) {
      debugPrint('Gagal mengambil profil user dari Firestore: $e');
      return null;
    }
  }

  Future<void> _saveUserProfile(UserModel user) async {
    try {
      await FirestoreService()
          .createUserProfile(user)
          .timeout(_profileOperationTimeout);
    } catch (e) {
      debugPrint('Gagal menyimpan profil user ke Firestore: $e');
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    if (kIsWeb || _googleSignInInitialized) {
      return;
    }

    await _googleSignIn.initialize();
    _googleSignInInitialized = true;
  }

  String _fallbackNameFromEmail(String? email) {
    if (email == null || !email.contains('@')) {
      return 'Pengguna RiseUp';
    }
    return email.split('@').first;
  }
}
