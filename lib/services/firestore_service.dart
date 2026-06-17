import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/symptom_model.dart';
import '../models/disease_model.dart';
import '../models/rule_model.dart';
import '../models/history_model.dart';
import '../models/mood_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore? _db;
  bool _useMock = true; // Default ke true, diubah di initialize() jika Firebase siap

  // Database Simulasi (In-Memory Mock Database)
  final List<UserModel> _mockUsers = [];
  
  final List<SymptomModel> _mockSymptoms = [
    SymptomModel(id: 's1', code: 'G001', name: 'Sering merasa lelah setelah bekerja ringan'),
    SymptomModel(id: 's2', code: 'G002', name: 'Mengalami ketegangan otot ringan di leher/bahu'),
    SymptomModel(id: 's3', code: 'G003', name: 'Merasa sulit rileks sejenak setelah aktivitas harian'),
    SymptomModel(id: 's4', code: 'G004', name: 'Mengalami sakit kepala atau pusing akibat beban pikiran'),
    SymptomModel(id: 's5', code: 'G005', name: 'Kualitas tidur menurun atau sering terbangun di malam hari'),
    SymptomModel(id: 's6', code: 'G006', name: 'Merasa tidak sabar atau mudah tersinggung karena hal sepele'),
    SymptomModel(id: 's7', code: 'G007', name: 'Mengalami kesulitan bernapas atau dada sesak tanpa sebab fisik'),
    SymptomModel(id: 's8', code: 'G008', name: 'Merasa sangat gelisah dan cemas berlebihan sepanjang waktu'),
    SymptomModel(id: 's9', code: 'G009', name: 'Mengalami gangguan pencernaan atau mual akibat tekanan mental'),
    SymptomModel(id: 's10', code: 'G010', name: 'Merasa sedih, hampa, dan putus asa terus-menerus sepanjang hari'),
    SymptomModel(id: 's11', code: 'G011', name: 'Kehilangan minat total terhadap hobi atau aktivitas yang disukai'),
    SymptomModel(id: 's12', code: 'G012', name: 'Merasa diri tidak berharga, bersalah, atau hidup terasa sia-sia'),
  ];

  final List<DiseaseModel> _mockDiseases = [
    DiseaseModel(
      id: 'd1',
      code: 'P001',
      name: 'Stress Ringan',
      description: 'Kondisi di mana Anda mengalami tekanan emosional ringan. Hal ini wajar dan dapat diatasi secara mandiri dengan istirahat serta relaksasi.',
      solutions: [
        'Lakukan latihan relaksasi pernapasan (Box Breathing) 5-10 menit.',
        'Tulis jurnal mood harian untuk meluapkan beban pikiran.',
        'Istirahat tidur yang cukup (7-8 jam) dan minum air putih yang cukup.'
      ],
    ),
    DiseaseModel(
      id: 'd2',
      code: 'P002',
      name: 'Stress Sedang',
      description: 'Anda mengalami tekanan mental sedang yang mulai memengaruhi rutinitas harian Anda. Diperlukan pengelolaan stres yang lebih aktif secara mandiri.',
      solutions: [
        'Lakukan aktivitas hobi atau self-care yang menyenangkan diri.',
        'Atur prioritas tugas agar tidak merasa kewalahan.',
        'Lakukan olahraga ringan secara rutin (jalan kaki 15-20 menit).',
        'Ceritakan beban pikiran Anda kepada teman atau keluarga terdekat.'
      ],
    ),
    DiseaseModel(
      id: 'd3',
      code: 'P003',
      name: 'Stress Berat',
      description: 'Tekanan mental yang Anda rasakan berada pada tingkat berat dan berisiko mengganggu kesehatan fisik serta mental Anda. Kondisi ini disarankan untuk tidak ditangani secara mandiri saja.',
      solutions: [
        'Segera konsultasikan kondisi Anda kepada Psikolog atau Psikiater profesional.',
        'Batasi paparan terhadap pemicu stres utama (pekerjaan/berita berlebih).',
        'Hubungi hotline layanan kesehatan mental darurat jika merasa kewalahan.'
      ],
    ),
    DiseaseModel(
      id: 'd4',
      code: 'P004',
      name: 'Depresi',
      description: 'Anda menunjukkan indikasi gangguan suasana hati yang mendalam (depresi). Kondisi ini memerlukan diagnosis klinis dan penanganan medis oleh tenaga profesional.',
      solutions: [
        'Sangat disarankan segera berkonsultasi dengan Psikolog klinis atau Psikiater.',
        'Jangan mendiagnosis diri sendiri atau mengisolasi diri dari orang terdekat.',
        'Jaga komunikasi aktif dengan keluarga atau orang yang Anda percayai.',
        'Ikuti terapi perilaku kognitif (CBT) di bawah bimbingan pakar.'
      ],
    ),
  ];

  final List<RuleModel> _mockRules = [
    RuleModel(id: 'r1', code: 'R001', gejalaRequired: ['G001', 'G002', 'G003'], hasilGangguan: 'P001'),
    RuleModel(id: 'r2', code: 'R002', gejalaRequired: ['G004', 'G005', 'G006'], hasilGangguan: 'P002'),
    RuleModel(id: 'r3', code: 'R003', gejalaRequired: ['G007', 'G008', 'G009'], hasilGangguan: 'P003'),
    RuleModel(id: 'r4', code: 'R004', gejalaRequired: ['G010', 'G011', 'G012'], hasilGangguan: 'P004'),
  ];

  final List<HistoryModel> _mockHistory = [];
  final List<MoodModel> _mockMoods = [];

  // StreamControllers untuk real-time update dalam mode Mock
  final StreamController<List<UserModel>> _mockUsersController = StreamController<List<UserModel>>.broadcast();
  final StreamController<List<HistoryModel>> _mockHistoryController = StreamController<List<HistoryModel>>.broadcast();

  void _updateMockUsersStream() {
    if (_mockUsers.isEmpty) {
      _mockUsers.addAll([
        UserModel(uid: 'user-1', email: 'budi@gmail.com', name: 'Budi Santoso', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 5))),
        UserModel(uid: 'user-2', email: 'siti@yahoo.com', name: 'Siti Aminah', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 4))),
        UserModel(uid: 'user-3', email: 'rudi@riseup.com', name: 'Rudi Wijaya', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 3))),
        UserModel(uid: 'user-4', email: 'ani@gmail.com', name: 'Ani Lestari', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 2))),
      ]);
    }
    _mockUsersController.add(List.from(_mockUsers));
  }

  void _updateMockHistoryStream() {
    if (_mockHistory.isEmpty) {
      _mockHistory.addAll([
        HistoryModel(
          id: 'h-1',
          userId: 'user-1',
          tanggal: DateTime.now().subtract(const Duration(hours: 4)),
          gejalaDipilih: ['G001', 'G002', 'G003'],
          hasilDiagnosis: 'Stress Ringan',
          diagnosisCode: 'P001',
          deskripsi: 'Kondisi di mana Anda mengalami tekanan emosional ringan.',
          solusi: ['Lakukan latihan relaksasi pernapasan.', 'Tulis jurnal mood.'],
        ),
        HistoryModel(
          id: 'h-2',
          userId: 'user-2',
          tanggal: DateTime.now().subtract(const Duration(hours: 12)),
          gejalaDipilih: ['G004', 'G005', 'G006'],
          hasilDiagnosis: 'Stress Sedang',
          diagnosisCode: 'P002',
          deskripsi: 'Mengalami tekanan mental sedang.',
          solusi: ['Lakukan hobi.', 'Ceritakan beban pikiran.'],
        ),
        HistoryModel(
          id: 'h-3',
          userId: 'user-3',
          tanggal: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          gejalaDipilih: ['G010', 'G011', 'G012'],
          hasilDiagnosis: 'Depresi',
          diagnosisCode: 'P004',
          deskripsi: 'Menunjukkan indikasi depresi.',
          solusi: ['Konsultasi dengan Psikolog.', 'Ikuti terapi CBT.'],
        ),
      ]);
    }
    _mockHistoryController.add(List.from(_mockHistory)..sort((a, b) => b.tanggal.compareTo(a.tanggal)));
  }

  bool get useMock => _useMock;

  Future<void> initialize() async {
    try {
      _db = FirebaseFirestore.instance;
      _useMock = false;
      debugPrint("Firestore berhasil diinisialisasi.");
    } catch (e) {
      debugPrint("Gagal menginisialisasi Firestore: $e");
      debugPrint("Beralih ke MODE SIMULASI (MOCK MODE).");
      _useMock = true;
    }
  }

  void setUseMock(bool value) {
    _useMock = value;
    if (!value && _db == null) {
      _db = FirebaseFirestore.instance;
    }
  }

  Future<void> seedDefaultData() async {
    if (_useMock || _db == null) return;
    
    // 1. Hapus hanya dokumen duplikat default yang ber-ID acak agar data kustom tidak hilang
    final defaultSymptomCodes = _mockSymptoms.map((e) => e.code).toSet();
    final gejalaSnap = await _db!.collection('gejala').get();
    for (final doc in gejalaSnap.docs) {
      final code = doc.data()['code'] as String?;
      if (code != null && defaultSymptomCodes.contains(code) && doc.id != code) {
        await doc.reference.delete();
      }
    }
    
    final defaultDiseaseCodes = _mockDiseases.map((e) => e.code).toSet();
    final gangguanSnap = await _db!.collection('gangguan').get();
    for (final doc in gangguanSnap.docs) {
      final code = doc.data()['code'] as String?;
      if (code != null && defaultDiseaseCodes.contains(code) && doc.id != code) {
        await doc.reference.delete();
      }
    }
    
    final defaultRuleCodes = _mockRules.map((e) => e.code).toSet();
    final aturanSnap = await _db!.collection('aturan').get();
    for (final doc in aturanSnap.docs) {
      final code = doc.data()['code'] as String?;
      if (code != null && defaultRuleCodes.contains(code) && doc.id != code) {
        await doc.reference.delete();
      }
    }
    
    final batch = _db!.batch();
    
    // Seed symptoms
    for (final s in _mockSymptoms) {
      final docRef = _db!.collection('gejala').doc(s.code);
      batch.set(docRef, s.toMap());
    }
    
    // Seed diseases
    for (final d in _mockDiseases) {
      final docRef = _db!.collection('gangguan').doc(d.code);
      batch.set(docRef, d.toMap());
    }
    
    // Seed rules
    for (final r in _mockRules) {
      final docRef = _db!.collection('aturan').doc(r.code);
      batch.set(docRef, r.toMap());
    }
    
    await batch.commit();
    debugPrint("Berhasil melakukan auto-seed data gejala, gangguan, dan aturan ke Firestore.");
  }

  // --- Users CRUD ---
  Future<void> createUserProfile(UserModel user) async {
    if (_useMock) {
      _mockUsers.removeWhere((u) => u.uid == user.uid);
      _mockUsers.add(user);
      _updateMockUsersStream();
    } else {
      await _db!.collection('users').doc(user.uid).set(user.toMap());
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    if (_useMock) {
      try {
        return _mockUsers.firstWhere((u) => u.uid == uid);
      } catch (e) {
        if (uid == 'mock-admin-1') {
          return UserModel(
            uid: 'mock-admin-1',
            email: 'admin@riseup.com',
            name: 'Dr. Sarah (Pakar)',
            role: 'admin',
            createdAt: DateTime.now(),
          );
        }
        return UserModel(
          uid: uid,
          email: 'user@riseup.com',
          name: 'User Demo',
          role: 'user',
          createdAt: DateTime.now(),
        );
      }
    } else {
      final doc = await _db!.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    }
  }

  Future<void> deleteUser(String uid) async {
    if (_useMock) {
      _mockUsers.removeWhere((u) => u.uid == uid);
      _mockHistory.removeWhere((h) => h.userId == uid);
      _mockMoods.removeWhere((m) => m.userId == uid);
      _updateMockUsersStream();
      _updateMockHistoryStream();
    } else {
      // 1. Hapus dokumen profil user
      await _db!.collection('users').doc(uid).delete();
      
      // 2. Hapus seluruh riwayat skrining user
      final historySnap = await _db!.collection('riwayat_tes').where('userId', isEqualTo: uid).get();
      final historyBatch = _db!.batch();
      for (final doc in historySnap.docs) {
        historyBatch.delete(doc.reference);
      }
      await historyBatch.commit();

      // 3. Hapus seluruh catatan mood tracker user
      final moodSnap = await _db!.collection('mood_tracker').where('userId', isEqualTo: uid).get();
      final moodBatch = _db!.batch();
      for (final doc in moodSnap.docs) {
        moodBatch.delete(doc.reference);
      }
      await moodBatch.commit();
    }
  }

  // --- Admin Queries ---
  Future<List<UserModel>> getAllUsers() async {
    if (_useMock) {
      if (_mockUsers.isEmpty) {
        _mockUsers.addAll([
          UserModel(uid: 'user-1', email: 'budi@gmail.com', name: 'Budi Santoso', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 5))),
          UserModel(uid: 'user-2', email: 'siti@yahoo.com', name: 'Siti Aminah', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 4))),
          UserModel(uid: 'user-3', email: 'rudi@riseup.com', name: 'Rudi Wijaya', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 3))),
          UserModel(uid: 'user-4', email: 'ani@gmail.com', name: 'Ani Lestari', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 2))),
        ]);
      }
      return List.from(_mockUsers);
    } else {
      final snap = await _db!.collection('users').get();
      return snap.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  Future<List<HistoryModel>> getAllHistory() async {
    if (_useMock) {
      if (_mockHistory.isEmpty) {
        _mockHistory.addAll([
          HistoryModel(
            id: 'h-1',
            userId: 'user-1',
            tanggal: DateTime.now().subtract(const Duration(hours: 4)),
            gejalaDipilih: ['G001', 'G002', 'G003'],
            hasilDiagnosis: 'Stress Ringan',
            diagnosisCode: 'P001',
            deskripsi: 'Kondisi di mana Anda mengalami tekanan emosional ringan.',
            solusi: ['Lakukan latihan relaksasi pernapasan.', 'Tulis jurnal mood.'],
          ),
          HistoryModel(
            id: 'h-2',
            userId: 'user-2',
            tanggal: DateTime.now().subtract(const Duration(hours: 12)),
            gejalaDipilih: ['G004', 'G005', 'G006'],
            hasilDiagnosis: 'Stress Sedang',
            diagnosisCode: 'P002',
            deskripsi: 'Mengalami tekanan mental sedang.',
            solusi: ['Lakukan hobi.', 'Ceritakan beban pikiran.'],
          ),
          HistoryModel(
            id: 'h-3',
            userId: 'user-3',
            tanggal: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
            gejalaDipilih: ['G010', 'G011', 'G012'],
            hasilDiagnosis: 'Depresi',
            diagnosisCode: 'P004',
            deskripsi: 'Menunjukkan indikasi depresi.',
            solusi: ['Konsultasi dengan Psikolog.', 'Ikuti terapi CBT.'],
          ),
        ]);
      }
      return List.from(_mockHistory)..sort((a, b) => b.tanggal.compareTo(a.tanggal));
    } else {
      final snap = await _db!.collection('riwayat_tes').orderBy('tanggal', descending: true).get();
      return snap.docs.map((doc) => HistoryModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  // Stream users untuk update real-time
  Stream<List<UserModel>> getUsersStream() {
    if (_useMock) {
      _updateMockUsersStream();
      return _mockUsersController.stream;
    } else {
      return _db!.collection('users').snapshots().map((snap) =>
          snap.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList());
    }
  }

  // Stream riwayat untuk update real-time
  Stream<List<HistoryModel>> getHistoryStream() {
    if (_useMock) {
      _updateMockHistoryStream();
      return _mockHistoryController.stream;
    } else {
      return _db!.collection('riwayat_tes').orderBy('tanggal', descending: true).snapshots().map((snap) =>
          snap.docs.map((doc) => HistoryModel.fromMap(doc.data(), doc.id)).toList());
    }
  }

  // --- Symptoms CRUD ---
  Future<List<SymptomModel>> getSymptoms() async {
    if (_useMock) {
      return List.from(_mockSymptoms);
    } else {
      final snap = await _db!.collection('gejala').orderBy('code').get();
      return snap.docs.map((doc) => SymptomModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  Future<void> addSymptom(SymptomModel symptom) async {
    if (_useMock) {
      final newSymptom = SymptomModel(
        id: 'mock-s-${DateTime.now().millisecondsSinceEpoch}',
        code: symptom.code,
        name: symptom.name,
      );
      _mockSymptoms.add(newSymptom);
      _mockSymptoms.sort((a, b) => a.code.compareTo(b.code));
    } else {
      await _db!.collection('gejala').doc(symptom.code).set(symptom.toMap());
    }
  }

  Future<void> deleteSymptom(String id) async {
    if (_useMock) {
      _mockSymptoms.removeWhere((s) => s.id == id);
    } else {
      await _db!.collection('gejala').doc(id).delete();
    }
  }

  Future<void> updateSymptom(SymptomModel symptom) async {
    if (_useMock) {
      final idx = _mockSymptoms.indexWhere((s) => s.id == symptom.id);
      if (idx != -1) {
        _mockSymptoms[idx] = symptom;
        _mockSymptoms.sort((a, b) => a.code.compareTo(b.code));
      }
    } else {
      await _db!.collection('gejala').doc(symptom.id).update(symptom.toMap());
    }
  }

  // --- Diseases CRUD ---
  Future<List<DiseaseModel>> getDiseases() async {
    if (_useMock) {
      return List.from(_mockDiseases);
    } else {
      final snap = await _db!.collection('gangguan').orderBy('code').get();
      return snap.docs.map((doc) => DiseaseModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  Future<void> addDisease(DiseaseModel disease) async {
    if (_useMock) {
      final newDisease = DiseaseModel(
        id: 'mock-d-${DateTime.now().millisecondsSinceEpoch}',
        code: disease.code,
        name: disease.name,
        description: disease.description,
        solutions: disease.solutions,
      );
      _mockDiseases.add(newDisease);
      _mockDiseases.sort((a, b) => a.code.compareTo(b.code));
    } else {
      await _db!.collection('gangguan').doc(disease.code).set(disease.toMap());
    }
  }

  Future<void> deleteDisease(String id) async {
    if (_useMock) {
      _mockDiseases.removeWhere((d) => d.id == id);
    } else {
      await _db!.collection('gangguan').doc(id).delete();
    }
  }

  Future<void> updateDisease(DiseaseModel disease) async {
    if (_useMock) {
      final idx = _mockDiseases.indexWhere((d) => d.id == disease.id);
      if (idx != -1) {
        _mockDiseases[idx] = disease;
        _mockDiseases.sort((a, b) => a.code.compareTo(b.code));
      }
    } else {
      await _db!.collection('gangguan').doc(disease.id).update(disease.toMap());
    }
  }

  // --- Rules CRUD ---
  Future<List<RuleModel>> getRules() async {
    if (_useMock) {
      return List.from(_mockRules);
    } else {
      final snap = await _db!.collection('aturan').orderBy('code').get();
      return snap.docs.map((doc) => RuleModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  Future<void> addRule(RuleModel rule) async {
    if (_useMock) {
      final newRule = RuleModel(
        id: 'mock-r-${DateTime.now().millisecondsSinceEpoch}',
        code: rule.code,
        gejalaRequired: rule.gejalaRequired,
        hasilGangguan: rule.hasilGangguan,
      );
      _mockRules.add(newRule);
      _mockRules.sort((a, b) => a.code.compareTo(b.code));
    } else {
      await _db!.collection('aturan').doc(rule.code).set(rule.toMap());
    }
  }

  Future<void> deleteRule(String id) async {
    if (_useMock) {
      _mockRules.removeWhere((r) => r.id == id);
    } else {
      await _db!.collection('aturan').doc(id).delete();
    }
  }

  Future<void> updateRule(RuleModel rule) async {
    if (_useMock) {
      final idx = _mockRules.indexWhere((r) => r.id == rule.id);
      if (idx != -1) {
        _mockRules[idx] = rule;
        _mockRules.sort((a, b) => a.code.compareTo(b.code));
      }
    } else {
      await _db!.collection('aturan').doc(rule.id).update(rule.toMap());
    }
  }

  // --- Diagnostic History CRUD ---
  Future<List<HistoryModel>> getHistory(String userId) async {
    if (_useMock) {
      final list = _mockHistory.where((h) => h.userId == userId).toList();
      if (list.isEmpty) {
        // Pre-populate a default history for this user so they see a sample diagnosis
        final sampleHistory = HistoryModel(
          id: 'mock-h-default-$userId',
          userId: userId,
          tanggal: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          gejalaDipilih: ['G001', 'G002', 'G003'],
          hasilDiagnosis: 'Stress Ringan',
          diagnosisCode: 'P001',
          deskripsi: 'Kondisi di mana Anda mengalami tekanan emosional ringan. Hal ini wajar dan dapat diatasi secara mandiri dengan istirahat serta relaksasi.',
          solusi: [
            'Lakukan latihan relaksasi pernapasan (Box Breathing) 5-10 menit.',
            'Tulis jurnal mood harian untuk meluapkan beban pikiran.',
            'Istirahat tidur yang cukup (7-8 jam) dan minum air putih yang cukup.'
          ],
        );
        _mockHistory.add(sampleHistory);
        return [sampleHistory];
      }
      list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      return list;
    } else {
      final snap = await _db!
          .collection('riwayat_tes')
          .where('userId', isEqualTo: userId)
          .get();
      final list = snap.docs.map((doc) => HistoryModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.tanggal.compareTo(a.tanggal)); // Urutkan terbaru dahulu di memori
      return list;
    }
  }

  Future<void> addHistory(HistoryModel history) async {
    if (_useMock) {
      _mockHistory.add(HistoryModel(
        id: 'mock-h-${DateTime.now().millisecondsSinceEpoch}',
        userId: history.userId,
        tanggal: history.tanggal,
        gejalaDipilih: history.gejalaDipilih,
        hasilDiagnosis: history.hasilDiagnosis,
        diagnosisCode: history.diagnosisCode,
        deskripsi: history.deskripsi,
        solusi: history.solusi,
      ));
      _updateMockHistoryStream();
    } else {
      await _db!.collection('riwayat_tes').add(history.toMap());
    }
  }

  // --- Mood Tracker CRUD ---
  Future<List<MoodModel>> getMoods(String userId) async {
    if (_useMock) {
      final list = _mockMoods.where((m) => m.userId == userId).toList();
      if (list.isEmpty) {
        // Pre-populate mock moods for the user so the trend immediately works for testing!
        final now = DateTime.now();
        _mockMoods.addAll([
          MoodModel(id: 'm-1', userId: userId, tanggal: now.subtract(const Duration(days: 4)), moodLevel: 3, catatan: 'Hari yang cukup biasa.'),
          MoodModel(id: 'm-2', userId: userId, tanggal: now.subtract(const Duration(days: 3)), moodLevel: 4, catatan: 'Belajar Flutter hari ini, menyenangkan!'),
          MoodModel(id: 'm-3', userId: userId, tanggal: now.subtract(const Duration(days: 2)), moodLevel: 2, catatan: 'Sedikit lelah karena kurang tidur.'),
          MoodModel(id: 'm-4', userId: userId, tanggal: now.subtract(const Duration(days: 1)), moodLevel: 4, catatan: 'Olahraga sore sangat membantu mood.'),
          MoodModel(id: 'm-5', userId: userId, tanggal: now, moodLevel: 5, catatan: 'Sangat senang hari ini karena semua berjalan lancar!'),
        ]);
        final populatedList = _mockMoods.where((m) => m.userId == userId).toList();
        populatedList.sort((a, b) => a.tanggal.compareTo(b.tanggal));
        return populatedList;
      }
      list.sort((a, b) => a.tanggal.compareTo(b.tanggal));
      return list;
    } else {
      final snap = await _db!
          .collection('mood_tracker')
          .where('userId', isEqualTo: userId)
          .get();
      final list = snap.docs.map((doc) => MoodModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => a.tanggal.compareTo(b.tanggal)); // Urutkan terlama ke terbaru di memori
      return list;
    }
  }

  Future<void> addMood(MoodModel mood) async {
    if (_useMock) {
      _mockMoods.add(MoodModel(
        id: 'mock-m-${DateTime.now().millisecondsSinceEpoch}',
        userId: mood.userId,
        tanggal: mood.tanggal,
        moodLevel: mood.moodLevel,
        catatan: mood.catatan,
      ));
    } else {
      await _db!.collection('mood_tracker').add(mood.toMap());
    }
  }

  // --- Posters CRUD ---
  final List<String> _mockPosters = [
    'assets/poster/poster1.jpg',
    'assets/poster/poster3.jpg',
    'assets/poster/poster4.jpg',
    'assets/poster/posterr5.jpg',
  ];
  
  final StreamController<List<String>> _mockPostersController = StreamController<List<String>>.broadcast();

  void _updateMockPostersStream() {
    _mockPostersController.add(List.from(_mockPosters));
  }

  Stream<List<String>> getPostersStream() {
    if (_useMock) {
      Timer(Duration.zero, () => _updateMockPostersStream());
      return _mockPostersController.stream;
    } else {
      return _db!.collection('posters').snapshots().map((snap) {
        if (snap.docs.isEmpty) {
          return [
            'assets/poster/poster1.jpg',
            'assets/poster/poster3.jpg',
            'assets/poster/poster4.jpg',
            'assets/poster/posterr5.jpg',
          ];
        }
        return snap.docs.map((doc) => doc.data()['path'] as String).toList();
      });
    }
  }

  Future<List<String>> getPosters() async {
    if (_useMock) {
      return List.from(_mockPosters);
    } else {
      final snap = await _db!.collection('posters').get();
      if (snap.docs.isEmpty) {
        return [
          'assets/poster/poster1.jpg',
          'assets/poster/poster3.jpg',
          'assets/poster/poster4.jpg',
          'assets/poster/posterr5.jpg',
        ];
      }
      return snap.docs.map((doc) => doc.data()['path'] as String).toList();
    }
  }

  Future<void> addPoster(String path) async {
    if (_useMock) {
      if (!_mockPosters.contains(path)) {
        _mockPosters.add(path);
        _updateMockPostersStream();
      }
    } else {
      final existing = await _db!.collection('posters').where('path', isEqualTo: path).get();
      if (existing.docs.isEmpty) {
        await _db!.collection('posters').add({'path': path, 'createdAt': FieldValue.serverTimestamp()});
      }
    }
  }

  Future<void> deletePoster(String path) async {
    if (_useMock) {
      _mockPosters.remove(path);
      _updateMockPostersStream();
    } else {
      final snap = await _db!.collection('posters').where('path', isEqualTo: path).get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    }
  }

  // --- Motivations CRUD ---
  final List<String> _mockMotivations = [
    'Kesehatan mentalmu adalah prioritas. Menyadari gejala lebih awal adalah langkah bijak.',
    'Tidak apa-apa untuk tidak merasa baik-baik saja. Kamu tidak harus berpura-pura kuat sepanjang waktu.',
    'Satu langkah kecil menuju perawatan diri hari ini adalah kemenangan besar bagi mentalmu.',
    'Kesehatan mental bukanlah tujuan akhir, melainkan sebuah perjalanan harian yang patut disyukuri.',
    'Tarik napas dalam-dalam, hembuskan perlahan. Hari ini baru dimulai, dan kamu sanggup menjalaninya.',
    'Mencintai diri sendiri berarti menerima bahwa kamu juga berhak untuk beristirahat dan pulih.',
    'Pikiranmu bisa menjadi tempat yang damai jika kamu memperlakukannya dengan kebaikan dan kesabaran.',
    'Kamu berharga, tidak peduli seberapa berat hari-hari yang sedang kamu lalui saat ini.'
  ];

  final StreamController<List<String>> _mockMotivationsController = StreamController<List<String>>.broadcast();

  void _updateMockMotivationsStream() {
    _mockMotivationsController.add(List.from(_mockMotivations));
  }

  Stream<List<String>> getMotivationsStream() {
    if (_useMock) {
      Timer(Duration.zero, () => _updateMockMotivationsStream());
      return _mockMotivationsController.stream;
    } else {
      return _db!.collection('motivations').snapshots().map((snap) {
        if (snap.docs.isEmpty) {
          return [
            'Kesehatan mentalmu adalah prioritas. Menyadari gejala lebih awal adalah langkah bijak.',
            'Tidak apa-apa untuk tidak merasa baik-baik saja. Kamu tidak harus berpura-pura kuat sepanjang waktu.',
            'Satu langkah kecil menuju perawatan diri hari ini adalah kemenangan besar bagi mentalmu.',
            'Kesehatan mental bukanlah tujuan akhir, melainkan sebuah perjalanan harian yang patut disyukuri.',
            'Tarik napas dalam-dalam, hembuskan perlahan. Hari ini baru dimulai, dan kamu sanggup menjalaninya.',
            'Mencintai diri sendiri berarti menerima bahwa kamu juga berhak untuk beristirahat dan pulih.',
            'Pikiranmu bisa menjadi tempat yang damai jika kamu memperlakukannya dengan kebaikan dan kesabaran.',
            'Kamu berharga, tidak peduli seberapa berat hari-hari yang sedang kamu lalui saat ini.'
          ];
        }
        return snap.docs.map((doc) => doc.data()['text'] as String).toList();
      });
    }
  }

  Future<List<String>> getMotivations() async {
    if (_useMock) {
      return List.from(_mockMotivations);
    } else {
      final snap = await _db!.collection('motivations').get();
      if (snap.docs.isEmpty) {
        return [
          'Kesehatan mentalmu adalah prioritas. Menyadari gejala lebih awal adalah langkah bijak.',
          'Tidak apa-apa untuk tidak merasa baik-baik saja. Kamu tidak harus berpura-pura kuat sepanjang waktu.',
          'Satu langkah kecil menuju perawatan diri hari ini adalah kemenangan besar bagi mentalmu.',
          'Kesehatan mental bukanlah tujuan akhir, melainkan sebuah perjalanan harian yang patut disyukuri.',
          'Tarik napas dalam-dalam, hembuskan perlahan. Hari ini baru dimulai, dan kamu sanggup menjalaninya.',
          'Mencintai diri sendiri berarti menerima bahwa kamu juga berhak untuk beristirahat dan pulih.',
          'Pikiranmu bisa menjadi tempat yang damai jika kamu memperlakukannya dengan kebaikan dan kesabaran.',
          'Kamu berharga, tidak peduli seberapa berat hari-hari yang sedang kamu lalui saat ini.'
        ];
      }
      return snap.docs.map((doc) => doc.data()['text'] as String).toList();
    }
  }

  Future<void> addMotivation(String text) async {
    if (_useMock) {
      if (!_mockMotivations.contains(text)) {
        _mockMotivations.add(text);
        _updateMockMotivationsStream();
      }
    } else {
      final existing = await _db!.collection('motivations').where('text', isEqualTo: text).get();
      if (existing.docs.isEmpty) {
        await _db!.collection('motivations').add({'text': text, 'createdAt': FieldValue.serverTimestamp()});
      }
    }
  }

  Future<void> deleteMotivation(String text) async {
    if (_useMock) {
      _mockMotivations.remove(text);
      _updateMockMotivationsStream();
    } else {
      final snap = await _db!.collection('motivations').where('text', isEqualTo: text).get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    }
  }
}
