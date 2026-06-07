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
    SymptomModel(id: 's1', code: 'G001', name: 'Merasa mulut kering atau sering haus tanpa sebab fisik'),
    SymptomModel(id: 's2', code: 'G002', name: 'Mengalami kesulitan bernapas (napas pendek/cepat)'),
    SymptomModel(id: 's3', code: 'G003', name: 'Anggota tubuh gemetar (tangan/kaki) saat cemas'),
    SymptomModel(id: 's4', code: 'G004', name: 'Khawatir berlebihan tentang situasi yang dapat membuat panik'),
    SymptomModel(id: 's5', code: 'G005', name: 'Merasa sedih, muram, dan tertekan sepanjang hari'),
    SymptomModel(id: 's6', code: 'G006', name: 'Merasa sangat sulit memulai aktivitas atau kehilangan minat'),
    SymptomModel(id: 's7', code: 'G007', name: 'Merasa tidak ada masa depan yang baik (putus asa)'),
    SymptomModel(id: 's8', code: 'G008', name: 'Merasa diri tidak berharga atau hidup terasa sia-sia'),
    SymptomModel(id: 's9', code: 'G009', name: 'Merasa mudah marah, tersinggung, atau tidak sabar'),
    SymptomModel(id: 's10', code: 'G010', name: 'Merasa sangat gelisah, cemas, dan sulit untuk duduk tenang'),
    SymptomModel(id: 's11', code: 'G011', name: 'Merasa sulit untuk relaksasi atau mengendurkan ketegangan'),
    SymptomModel(id: 's12', code: 'G012', name: 'Mudah terkejut atau merasa sangat sensitif terhadap suara bising'),
  ];

  final List<DiseaseModel> _mockDiseases = [
    DiseaseModel(
      id: 'd1',
      code: 'P001',
      name: 'Gangguan Kecemasan (Anxiety)',
      description: 'Gangguan kecemasan ditandai dengan kecemasan dan kekhawatiran yang berlebihan pada aktivitas atau peristiwa sehari-hari.',
      solutions: [
        'Lakukan latihan pernapasan dalam (Deep Breathing) secara teratur.',
        'Batasi konsumsi kafein dan alkohol yang dapat memicu kecemasan.',
        'Gunakan jurnal harian untuk mencurahkan pikiran cemas Anda.',
        'Konsultasikan dengan psikolog jika kecemasan mengganggu aktivitas harian Anda.'
      ],
    ),
    DiseaseModel(
      id: 'd2',
      code: 'P002',
      name: 'Gangguan Depresi (Depression)',
      description: 'Depresi adalah gangguan suasana hati yang ditandai dengan perasaan sedih yang mendalam dan kehilangan minat terhadap hal-hal yang disukai.',
      solutions: [
        'Cobalah berolahraga ringan minimal 15 menit sehari.',
        'Bicarakan perasaan Anda kepada orang terdekat yang Anda percayai.',
        'Cobalah buat jadwal harian kecil untuk menghindari kecenderungan mengurung diri.',
        'Hubungi layanan kesehatan mental atau psikolog klinis untuk konseling.'
      ],
    ),
    DiseaseModel(
      id: 'd3',
      code: 'P003',
      name: 'Gangguan Stres (Stress)',
      description: 'Stres adalah reaksi tubuh terhadap situasi yang tampak sulit atau berbahaya. Stres berkepanjangan dapat merusak kesehatan fisik dan mental.',
      solutions: [
        'Praktikkan meditasi mindfulness atau latihan relaksasi otot progresif.',
        'Luangkan waktu untuk hobi atau hal yang menyenangkan diri sendiri (self-care).',
        'Atur skala prioritas pekerjaan untuk mengurangi beban pikiran.',
        'Istirahat tidur yang cukup (7-8 jam per hari).'
      ],
    ),
  ];

  final List<RuleModel> _mockRules = [
    RuleModel(id: 'r1', code: 'R001', gejalaRequired: ['G001', 'G002', 'G003', 'G004'], hasilGangguan: 'P001'),
    RuleModel(id: 'r2', code: 'R002', gejalaRequired: ['G005', 'G006', 'G007', 'G008'], hasilGangguan: 'P002'),
    RuleModel(id: 'r3', code: 'R003', gejalaRequired: ['G009', 'G010', 'G011', 'G012'], hasilGangguan: 'P003'),
  ];

  final List<HistoryModel> _mockHistory = [];
  final List<MoodModel> _mockMoods = [];

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
  }

  // --- Users CRUD ---
  Future<void> createUserProfile(UserModel user) async {
    if (_useMock) {
      _mockUsers.removeWhere((u) => u.uid == user.uid);
      _mockUsers.add(user);
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
      await _db!.collection('gejala').add(symptom.toMap());
    }
  }

  Future<void> deleteSymptom(String id) async {
    if (_useMock) {
      _mockSymptoms.removeWhere((s) => s.id == id);
    } else {
      await _db!.collection('gejala').doc(id).delete();
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
      await _db!.collection('gangguan').add(disease.toMap());
    }
  }

  Future<void> deleteDisease(String id) async {
    if (_useMock) {
      _mockDiseases.removeWhere((d) => d.id == id);
    } else {
      await _db!.collection('gangguan').doc(id).delete();
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
      await _db!.collection('aturan').add(rule.toMap());
    }
  }

  Future<void> deleteRule(String id) async {
    if (_useMock) {
      _mockRules.removeWhere((r) => r.id == id);
    } else {
      await _db!.collection('aturan').doc(id).delete();
    }
  }

  // --- Diagnostic History CRUD ---
  Future<List<HistoryModel>> getHistory(String userId) async {
    if (_useMock) {
      return _mockHistory.where((h) => h.userId == userId).toList()
        ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
    } else {
      final snap = await _db!
          .collection('riwayat_tes')
          .where('userId', isEqualTo: userId)
          .orderBy('tanggal', descending: true)
          .get();
      return snap.docs.map((doc) => HistoryModel.fromMap(doc.data(), doc.id)).toList();
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
    } else {
      await _db!.collection('riwayat_tes').add(history.toMap());
    }
  }

  // --- Mood Tracker CRUD ---
  Future<List<MoodModel>> getMoods(String userId) async {
    if (_useMock) {
      final list = _mockMoods.where((m) => m.userId == userId).toList();
      list.sort((a, b) => a.tanggal.compareTo(b.tanggal));
      return list;
    } else {
      final snap = await _db!
          .collection('mood_tracker')
          .where('userId', isEqualTo: userId)
          .orderBy('tanggal', descending: false)
          .get();
      return snap.docs.map((doc) => MoodModel.fromMap(doc.data(), doc.id)).toList();
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
}
