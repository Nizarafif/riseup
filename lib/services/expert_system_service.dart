import '../models/disease_model.dart';
import '../models/rule_model.dart';

class ExpertSystemService {
  /// Menjalankan mesin inferensi Forward Chaining.
  /// 
  /// Menerima daftar kode gejala yang dialami pengguna [selectedSymptomCodes],
  /// daftar aturan [rules] dari basis pengetahuan, dan daftar gangguan/penyakit [diseases].
  /// Mengembalikan [DiseaseModel] yang terdeteksi, atau `null` jika tidak memenuhi aturan apa pun.
  static DiseaseModel? runForwardChaining({
    required List<String> selectedSymptomCodes,
    required List<RuleModel> rules,
    required List<DiseaseModel> diseases,
  }) {
    if (selectedSymptomCodes.isEmpty || rules.isEmpty || diseases.isEmpty) {
      return null;
    }

    // 1. Inisialisasi basis data fakta dengan gejala awal yang dirasakan pengguna
    final Set<String> facts = Set.from(selectedSymptomCodes);
    final Set<String> firedRuleIds = {};
    bool newFactAdded = true;

    // 2. Proses inferensi (looping terus selama ditemukan kesimpulan baru)
    while (newFactAdded) {
      newFactAdded = false;

      for (var rule in rules) {
        // Lewati jika aturan ini sudah aktif/dijalankan
        if (firedRuleIds.contains(rule.id)) continue;

        // Cek apakah seluruh gejala yang dipersyaratkan oleh aturan ada di dalam kumpulan fakta saat ini
        bool allRequiredFactsExist = rule.gejalaRequired.every((req) => facts.contains(req));

        if (allRequiredFactsExist) {
          // Aturan terpenuhi (Fire)!
          firedRuleIds.add(rule.id);

          // Masukkan kesimpulan aturan ke dalam basis fakta
          if (!facts.contains(rule.hasilGangguan)) {
            facts.add(rule.hasilGangguan);
            newFactAdded = true; // Menandai adanya fakta baru untuk iterasi selanjutnya
          }
        }
      }
    }

    // 3. Cari diagnosis akhir dari kumpulan fakta yang terkumpul
    DiseaseModel? finalDiagnosis;
    
    // Cari penyakit/gangguan mana yang kodenya tercantum di set fakta akhir
    for (var disease in diseases) {
      if (facts.contains(disease.code)) {
        // Jika ada beberapa gangguan yang berpotensi terdeteksi, kita ambil yang paling spesifik
        // (biasanya aturan pakar dirancang agar hanya mengerucut ke satu diagnosis utama,
        // namun di sini kita antisipasi dengan mengambil diagnosis yang paling akhir disimpulkan).
        finalDiagnosis = disease;
      }
    }

    return finalDiagnosis;
  }
}
