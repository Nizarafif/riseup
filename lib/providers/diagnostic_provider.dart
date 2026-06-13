import 'package:flutter/material.dart';
import '../models/symptom_model.dart';
import '../models/disease_model.dart';
import '../models/rule_model.dart';
import '../models/history_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/expert_system_service.dart';

class DiagnosticProvider extends ChangeNotifier {
  final FirestoreService _dbService = FirestoreService();

  List<SymptomModel> _symptoms = [];
  List<DiseaseModel> _diseases = [];
  List<RuleModel> _rules = [];
  List<HistoryModel> _historyList = [];
  
  List<UserModel> _allUsers = [];
  List<HistoryModel> _allHistories = [];

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
  List<String> get selectedSymptomCodes => _selectedSymptomCodes;
  bool get isLoading => _isLoading;
  DiseaseModel? get latestDiagnosis => _latestDiagnosis;
  bool get inferenceCompleted => _inferenceCompleted;

  // Memuat data analitik admin
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
}
