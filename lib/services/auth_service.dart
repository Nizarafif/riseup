import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _auth;
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
      // Inisialisasi Firebase Auth jika library siap
      await Firebase.initializeApp().timeout(const Duration(seconds: 2));
      _auth = FirebaseAuth.instance;
      _useMock = false;
      debugPrint("Firebase Auth berhasil diinisialisasi.");
    } catch (e) {
      debugPrint("Firebase Auth gagal diinisialisasi, beralih ke Mock Mode.");
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
      
      // Ambil detail profil pengguna dari Firestore
      final userDoc = await FirestoreService().getUserProfile(credential.user!.uid);
      if (userDoc != null) {
        _mockCurrentUser = userDoc;
        return userDoc;
      } else {
        // Jika belum ada di database, buat data profil dasar
        final newUser = UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? email,
          name: email.split('@').first,
          role: 'user',
          createdAt: DateTime.now(),
        );
        await FirestoreService().createUserProfile(newUser);
        _mockCurrentUser = newUser;
        return newUser;
      }
    }
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
      final newUser = UserModel(
        uid: credential.user!.uid,
        email: email.trim(),
        name: name.trim(),
        role: role,
        createdAt: DateTime.now(),
      );
      await FirestoreService().createUserProfile(newUser);
      _mockCurrentUser = newUser;
      return newUser;
    }
  }

  // Logout
  Future<void> signOut() async {
    if (_useMock) {
      _mockCurrentUser = null;
    } else {
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
}

