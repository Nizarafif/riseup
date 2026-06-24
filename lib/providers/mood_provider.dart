import 'package:flutter/material.dart';
import '../models/mood_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class MoodProvider extends ChangeNotifier {
  final FirestoreService _dbService = FirestoreService();

  List<MoodModel> _moods = [];
  bool _isLoading = false;

  List<MoodModel> get moods => _moods;
  bool get isLoading => _isLoading;

  bool get hasLoggedMoodToday {
    if (_moods.isEmpty) return false;
    final now = DateTime.now();
    return _moods.any((mood) {
      final date = mood.tanggal;
      return date.year == now.year && date.month == now.month && date.day == now.day;
    });
  }

  // Mengambil data mood pengguna
  Future<void> fetchMoods(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _moods = await _dbService.getMoods(userId);
    } catch (e) {
      debugPrint("Gagal mengambil data mood: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menambahkan entri mood baru
  Future<bool> addMood(String userId, int moodLevel, String catatan, {DateTime? date}) async {
    final mood = MoodModel(
      id: '',
      userId: userId,
      tanggal: date ?? DateTime.now(),
      moodLevel: moodLevel,
      catatan: catatan,
    );

    try {
      await _dbService.addMood(mood);
      await fetchMoods(userId); // Sinkronisasi ulang data lokal
      
      // Reschedule pengingat notifikasi harian agar dilewati untuk hari ini
      await NotificationService().onMoodLogged();
      
      return true;
    } catch (e) {
      debugPrint("Gagal menyimpan mood: $e");
      return false;
    }
  }

  // Menambahkan entri mood baru secara batch (simulasi)
  Future<bool> addMoodsBatch(String userId, List<Map<String, dynamic>> moodDataList) async {
    final List<MoodModel> moods = moodDataList.map((data) {
      return MoodModel(
        id: '',
        userId: userId,
        tanggal: data['date'] ?? DateTime.now(),
        moodLevel: data['level'] ?? 3,
        catatan: data['note'] ?? '',
      );
    }).toList();

    try {
      await _dbService.addMoodsBatch(moods);
      await fetchMoods(userId); // Sinkronisasi sekali di akhir
      await NotificationService().onMoodLogged(); // Reschedule sekali di akhir
      return true;
    } catch (e) {
      debugPrint("Gagal menyimpan batch mood: $e");
      return false;
    }
  }

  // Menghapus/mereset semua entri mood user
  Future<bool> clearMoods(String userId) async {
    try {
      await _dbService.clearUserTestData(userId);
      await fetchMoods(userId); // Sinkronisasi ulang data lokal
      return true;
    } catch (e) {
      debugPrint("Gagal mereset data mood: $e");
      return false;
    }
  }
}
