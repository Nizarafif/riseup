import 'dart:async';
import 'package:flutter/material.dart';
import '../models/symptom_model.dart';
import '../models/disease_model.dart';
import '../models/rule_model.dart';
import '../models/history_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/expert_system_service.dart';
import '../services/auth_service.dart';
import 'mood_provider.dart';
import '../services/notification_service.dart';

class DiagnosticProvider extends ChangeNotifier {
  StreamSubscription<List<UserModel>>? _usersSubscription;
  StreamSubscription<List<HistoryModel>>? _historySubscription;
  final FirestoreService _dbService = FirestoreService();

  List<SymptomModel> _symptoms = [];
  List<DiseaseModel> _diseases = [];
  List<RuleModel> _rules = [];
  List<HistoryModel> _historyList = [];
  
  List<UserModel> _allUsers = [];
  List<HistoryModel> _allHistories = [];
  List<String> _posters = [];
  StreamSubscription<List<String>>? _postersSubscription;
  List<String> _motivations = [];
  StreamSubscription<List<String>>? _motivationsSubscription;

  final List<String> _selectedSymptomCodes = [];
  bool _isLoading = false;
  DiseaseModel? _latestDiagnosis;
  bool _inferenceCompleted = false;

  // Getters
  List<SymptomModel> get symptoms => _symptoms;
  List<DiseaseModel> get diseases => _diseases;
  List<RuleModel> get rules => _rules;
  List<HistoryModel> get historyList => _historyList;
  List<UserModel> get allUsers => _allUsers;
  List<HistoryModel> get allHistories => _allHistories;
  List<String> get posters => _posters;
  List<String> get motivations => _motivations;
  List<String> get selectedSymptomCodes => _selectedSymptomCodes;
  bool get isLoading => _isLoading;
  DiseaseModel? get latestDiagnosis => _latestDiagnosis;
  bool get hasTestedToday {
    if (_historyList.isEmpty) return false;
    final now = DateTime.now();
    return _historyList.any((history) {
      final date = history.tanggal;
      return date.year == now.year && date.month == now.month && date.day == now.day;
    });
  }

  // Memuat data analitik admin (one-time read fallback)
  Future<void> loadAdminData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allUsers = await _dbService.getAllUsers();
      _allHistories = await _dbService.getAllHistory();
    } catch (e) {
      debugPrint("Gagal memuat data admin: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Memantau data analitik secara real-time
  void listenToAdminData() {
    _usersSubscription?.cancel();
    _historySubscription?.cancel();

    _isLoading = true;
    notifyListeners();

    _usersSubscription = _dbService.getUsersStream().listen(
      (users) {
        _allUsers = users;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Error mendengarkan stream pengguna: $e");
        _isLoading = false;
        notifyListeners();
      },
    );

    _historySubscription = _dbService.getHistoryStream().listen(
      (histories) {
        _allHistories = histories;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Error mendengarkan stream riwayat: $e");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Menghentikan pemantauan data real-time
  void cancelAdminListeners() {
    _usersSubscription?.cancel();
    _usersSubscription = null;
    _historySubscription?.cancel();
    _historySubscription = null;
  }

  // Memuat data awal dari database
  Future<void> loadDiagnosticData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _symptoms = await _dbService.getSymptoms();
      
      // Auto-seeding jika database kosong di real Firestore
      if (!_dbService.useMock && _symptoms.isEmpty) {
        debugPrint("Database gejala kosong. Melakukan auto-seeding ke Firestore...");
        await _dbService.seedDefaultData();
        _symptoms = await _dbService.getSymptoms();
      }

      _diseases = await _dbService.getDiseases();
      _rules = await _dbService.getRules();
      await fetchHistory(userId);
    } catch (e) {
      debugPrint("Gagal memuat data diagnostik: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Melakukan seeding database secara manual (misal dari Panel Pakar)
  Future<void> seedDatabase() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _dbService.seedDefaultData();
      _symptoms = await _dbService.getSymptoms();
      _diseases = await _dbService.getDiseases();
      _rules = await _dbService.getRules();
    } catch (e) {
      debugPrint("Gagal melakukan seeding database: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mengambil riwayat tes pengguna
  Future<void> fetchHistory(String userId) async {
    try {
      _historyList = await _dbService.getHistory(userId);
      notifyListeners();
    } catch (e) {
      debugPrint("Gagal mengambil riwayat: $e");
    }
  }

  // Toggle pilihan gejala pengguna
  void toggleSymptom(String code) {
    if (_selectedSymptomCodes.contains(code)) {
      _selectedSymptomCodes.remove(code);
    } else {
      _selectedSymptomCodes.add(code);
    }
    notifyListeners();
  }

  // Mereset kuesioner
  void resetScreening() {
    _selectedSymptomCodes.clear();
    _latestDiagnosis = null;
    _inferenceCompleted = false;
    notifyListeners();
  }

  // Menjalankan Forward Chaining
  Future<void> runDiagnosis(String userId) async {
    if (_selectedSymptomCodes.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    // 1. Eksekusi Forward Chaining
    final diagnosis = ExpertSystemService.runForwardChaining(
      selectedSymptomCodes: _selectedSymptomCodes,
      rules: _rules,
      diseases: _diseases,
    );

    _latestDiagnosis = diagnosis;
    _inferenceCompleted = true;

    // 2. Simpan hasil diagnosis ke Firestore
    final historyItem = HistoryModel(
      id: '', // Diisi otomatis oleh Firestore / Mock generator
      userId: userId,
      tanggal: DateTime.now(),
      gejalaDipilih: List.from(_selectedSymptomCodes),
      hasilDiagnosis: diagnosis != null ? diagnosis.name : 'Sehat Secara Mental (Normal)',
      diagnosisCode: diagnosis != null ? diagnosis.code : 'P000',
      deskripsi: diagnosis != null 
          ? diagnosis.description 
          : 'Berdasarkan hasil analisis gejala, kondisi psikologis Anda saat ini tergolong normal dan stabil. Tetap jaga kesehatan mental Anda.',
      solusi: diagnosis != null 
          ? diagnosis.solutions 
          : [
              'Lanjutkan pola hidup sehat dan cukup tidur.',
              'Luangkan waktu untuk relaksasi dan berolahraga.',
              'Pertahankan hubungan positif dengan kerabat dekat.'
            ],
    );

    try {
      await _dbService.addHistory(historyItem);
      // Perbarui riwayat lokal
      await fetchHistory(userId);
      
      // Reschedule pengingat notifikasi harian agar dilewati untuk hari ini
      await NotificationService().onScreeningCompleted();
    } catch (e) {
      debugPrint("Gagal menyimpan riwayat diagnosis: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================= Admin Operations (CRUD) =================

  // --- Symptoms ---
  Future<void> addSymptom(String code, String name) async {
    final symptom = SymptomModel(id: '', code: code, name: name);
    await _dbService.addSymptom(symptom);
    _symptoms = await _dbService.getSymptoms();
    notifyListeners();
  }

  Future<void> deleteSymptom(String id) async {
    await _dbService.deleteSymptom(id);
    _symptoms = await _dbService.getSymptoms();
    notifyListeners();
  }

  Future<void> updateSymptom(String id, String code, String name) async {
    final symptom = SymptomModel(id: id, code: code, name: name);
    await _dbService.updateSymptom(symptom);
    _symptoms = await _dbService.getSymptoms();
    notifyListeners();
  }

  // --- Diseases ---
  Future<void> addDisease(String code, String name, String description, List<String> solutions) async {
    final disease = DiseaseModel(
      id: '',
      code: code,
      name: name,
      description: description,
      solutions: solutions,
    );
    await _dbService.addDisease(disease);
    _diseases = await _dbService.getDiseases();
    notifyListeners();
  }

  Future<void> deleteDisease(String id) async {
    await _dbService.deleteDisease(id);
    _diseases = await _dbService.getDiseases();
    notifyListeners();
  }

  Future<void> updateDisease(String id, String code, String name, String description, List<String> solutions) async {
    final disease = DiseaseModel(
      id: id,
      code: code,
      name: name,
      description: description,
      solutions: solutions,
    );
    await _dbService.updateDisease(disease);
    _diseases = await _dbService.getDiseases();
    notifyListeners();
  }

  // --- Rules ---
  Future<void> addRule(String code, List<String> gejalaRequired, String hasilGangguan) async {
    final rule = RuleModel(
      id: '',
      code: code,
      gejalaRequired: gejalaRequired,
      hasilGangguan: hasilGangguan,
    );
    await _dbService.addRule(rule);
    _rules = await _dbService.getRules();
    notifyListeners();
  }

  Future<void> deleteRule(String id) async {
    await _dbService.deleteRule(id);
    _rules = await _dbService.getRules();
    notifyListeners();
  }

  Future<void> updateRule(String id, String code, List<String> gejalaRequired, String hasilGangguan) async {
    final rule = RuleModel(
      id: id,
      code: code,
      gejalaRequired: gejalaRequired,
      hasilGangguan: hasilGangguan,
    );
    await _dbService.updateRule(rule);
    _rules = await _dbService.getRules();
    notifyListeners();
  }

  // --- Register New Admin ---
  Future<void> registerNewAdmin(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final authService = AuthService();
      await authService.registerNewAdmin(name, email, password);
      // Data ter-update secara otomatis jika real-time stream aktif, 
      // tetapi untuk keamanan pemicu manual one-time fallback:
      if (_usersSubscription == null) {
        _allUsers = await _dbService.getAllUsers();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Delete User ---
  Future<void> deleteUser(String uid) async {
    try {
      await _dbService.deleteUser(uid);
      if (_usersSubscription == null) {
        _allUsers = await _dbService.getAllUsers();
        _allHistories = await _dbService.getAllHistory();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Gagal menghapus pengguna: $e");
      rethrow;
    }
  }

  // --- Clear Admin Test Data (Screening & Moods) ---
  Future<bool> clearAdminTestData(String userId, MoodProvider moodProvider) async {
    try {
      await _dbService.clearUserTestData(userId);
      await fetchHistory(userId);
      await moodProvider.fetchMoods(userId);
      
      if (_usersSubscription == null) {
        _allUsers = await _dbService.getAllUsers();
        _allHistories = await _dbService.getAllHistory();
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Gagal mereset data uji coba admin: $e");
      return false;
    }
  }

  // --- Add History Batch ---
  Future<bool> addHistoryBatch(String userId, List<HistoryModel> histories) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _dbService.addHistoryBatch(histories);
      await fetchHistory(userId);
      
      if (_usersSubscription == null) {
        _allHistories = await _dbService.getAllHistory();
      }
      return true;
    } catch (e) {
      debugPrint("Gagal menyimpan batch riwayat: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Evaluate 30 Day Screening Trend ---
  Map<String, dynamic> evaluate30DayScreeningTrend() {
    if (_historyList.isEmpty) {
      return {
        'status': 'no_data',
        'title': 'Belum Ada Data',
        'message': 'Belum ada data skrining yang cukup untuk dianalisis.',
        'color': Colors.grey,
        'icon': Icons.info_outline,
        'pattern': '-',
        'actions': <String>[],
      };
    }
    
    // Sort by date ascending (oldest first)
    final sortedHistory = List<HistoryModel>.from(_historyList)
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    if (sortedHistory.length < 3) {
      return {
        'status': 'insufficient_data',
        'title': 'Data Belum Cukup',
        'message': 'Lakukan setidaknya 3 kali tes skrining untuk melihat analisis tren kondisi kesehatan mental Anda.',
        'color': Colors.amber,
        'icon': Icons.pending_actions_rounded,
        'pattern': '-',
        'actions': <String>[],
      };
    }

    // Map diagnosis code to severity level
    int getSeverity(String code) {
      switch (code) {
        case 'P000': return 0;
        case 'P001': return 1;
        case 'P002': return 2;
        case 'P003': return 3;
        case 'P004': return 4;
        default: return 0;
      }
    }

    String getSeverityLabel(double avg) {
      if (avg < 0.8) return 'Normal';
      if (avg < 1.8) return 'Ringan';
      if (avg < 2.8) return 'Sedang';
      if (avg < 3.8) return 'Berat';
      return 'Depresi';
    }

    // Split into first half (older) and second half (newer)
    final mid = sortedHistory.length ~/ 2;
    final firstHalf = sortedHistory.sublist(0, mid);
    final secondHalf = sortedHistory.sublist(mid);

    double avgFirst = firstHalf.map((h) => getSeverity(h.diagnosisCode)).reduce((a, b) => a + b) / firstHalf.length;
    double avgSecond = secondHalf.map((h) => getSeverity(h.diagnosisCode)).reduce((a, b) => a + b) / secondHalf.length;

    final patternStr = '${getSeverityLabel(avgFirst)} ➔ ${getSeverityLabel(avgSecond)}';

    if (avgFirst < 0.8 && avgSecond < 0.8) {
      return {
        'status': 'stable_normal',
        'title': 'Kondisi Stabil & Prima',
        'pattern': patternStr,
        'message': 'Kesehatan mental Anda stabil dalam kondisi sangat baik selama 30 hari terakhir. Pertahankan pola ini!',
        'color': Colors.green,
        'icon': Icons.sentiment_very_satisfied_rounded,
        'actions': <String>[
          'Pertahankan pola tidur yang teratur (7-8 jam per malam).',
          'Lakukan meditasi atau olahraga ringan secara rutin di pagi hari.',
          'Tetap aktif mencatat mood harian Anda untuk menjaga kesadaran emosional.'
        ],
      };
    } else if (avgSecond < avgFirst) {
      return {
        'status': 'improving',
        'title': 'Kondisi Mulai Membaik',
        'pattern': patternStr,
        'message': 'Kabar baik! Tren menunjukkan kondisi mental Anda mulai membaik dari sebelumnya secara bertahap. Pertahankan perkembangan positif ini!',
        'color': Colors.green,
        'icon': Icons.trending_down_rounded,
        'actions': <String>[
          'Lanjutkan latihan relaksasi pernapasan (Box Breathing) saat merasa lelah.',
          'Pertahankan kebiasaan menulis jurnal mood harian Anda.',
          'Berikan apresiasi pada diri Anda atas kemajuan kecil yang telah dicapai.'
        ],
      };
    } else if (avgSecond > avgFirst && avgSecond >= 2.0) {
      return {
        'status': 'worsening',
        'title': 'Kondisi Menunjukkan Penurunan',
        'pattern': patternStr,
        'message': 'Perhatian: Hasil tes menunjukkan kondisi mental Anda mengalami penurunan yang cukup signifikan akhir-akhir ini.',
        'color': Colors.redAccent,
        'icon': Icons.trending_up_rounded,
        'actions': <String>[
          'Segera kurangi beban aktivitas harian Anda untuk beristirahat secara fisik dan mental.',
          'Lakukan latihan relaksasi pernapasan 3 kali sehari (pagi, siang, malam).',
          'Sangat disarankan berkonsultasi dengan Psikolog Profesional di Panel Pakar RiseUp.'
        ],
      };
    } else {
      return {
        'status': 'stable_bad',
        'title': 'Kondisi Mengalami Tekanan Konstan',
        'pattern': patternStr,
        'message': 'Kondisi mental Anda terpantau berada dalam tekanan konstan dan belum menunjukkan tanda pemulihan dalam sebulan ini.',
        'color': Colors.redAccent,
        'icon': Icons.warning_amber_rounded,
        'actions': <String>[
          'Segera jadwalkan sesi konsultasi klinis dengan Psikolog Profesional.',
          'Ceritakan beban pikiran Anda kepada keluarga atau kerabat dekat yang Anda percayai.',
          'Gunakan layanan hotline darurat kesehatan jika Anda mulai merasa sangat kewalahan.'
        ],
      };
    }
  }

  @override
  void dispose() {
    cancelAdminListeners();
    cancelPostersListener();
    cancelMotivationsListener();
    super.dispose();
  }

  // --- Posters CRUD & Sync ---
  void listenToPosters() {
    _postersSubscription?.cancel();
    _postersSubscription = _dbService.getPostersStream().listen((postersList) {
      _posters = postersList;
      notifyListeners();
    });
  }

  void cancelPostersListener() {
    _postersSubscription?.cancel();
    _postersSubscription = null;
  }

  Future<void> addPoster(String path) async {
    await _dbService.addPoster(path);
    if (_postersSubscription == null) {
      _posters = await _dbService.getPosters();
      notifyListeners();
    }
  }

  Future<void> deletePoster(String path) async {
    await _dbService.deletePoster(path);
    if (_postersSubscription == null) {
      _posters = await _dbService.getPosters();
      notifyListeners();
    }
  }

  // --- Motivations CRUD & Sync ---
  void listenToMotivations() {
    _motivationsSubscription?.cancel();
    _motivationsSubscription = _dbService.getMotivationsStream().listen((motivationsList) {
      _motivations = motivationsList;
      notifyListeners();
    });
  }

  void cancelMotivationsListener() {
    _motivationsSubscription?.cancel();
    _motivationsSubscription = null;
  }

  Future<void> addMotivation(String text) async {
    await _dbService.addMotivation(text);
    if (_motivationsSubscription == null) {
      _motivations = await _dbService.getMotivations();
      notifyListeners();
    }
  }

  Future<void> deleteMotivation(String text) async {
    await _dbService.deleteMotivation(text);
    if (_motivationsSubscription == null) {
      _motivations = await _dbService.getMotivations();
      notifyListeners();
    }
  }
}
