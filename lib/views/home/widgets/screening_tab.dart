import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../models/history_model.dart';
import '../../../providers/diagnostic_provider.dart';
import '../../../providers/auth_provider.dart';

class ScreeningTab extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onStartScreening;
  const ScreeningTab({super.key, required this.user, this.onStartScreening});

  Widget _buildScreeningMainCard(
    BuildContext context,
    dynamic latestHistory,
    DiagnosticProvider diagnosticProvider,
    bool isDarkBg,
  ) {
    final cardBg = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final titleColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final bodyColor = isDarkBg ? Colors.white70 : const Color(0xFF505050);
    final borderColor = isDarkBg
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFF6C63FF).withOpacity(0.05);
    final dividerColor = isDarkBg ? Colors.white12 : Colors.black12;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkBg ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDarkBg ? 0.15 : 0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C9A7).withOpacity(isDarkBg ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.psychology_alt_outlined,
                  color: Color(0xFF00C9A7),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skrining Mandiri',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Metode Forward Chaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkBg ? Colors.white54 : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Melalui sistem pakar ini, Anda dapat mendeteksi indikasi awal gangguan kesehatan mental berdasarkan gejala-gejala klinis yang Anda rasakan secara valid.',
            style: TextStyle(fontSize: 13, color: bodyColor, height: 1.5),
          ),
          if (latestHistory != null) ...[
            Divider(height: 32, color: dividerColor),
            Text(
              'Diagnosis Terakhir Anda:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDarkBg ? Colors.white54 : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: latestHistory.diagnosisCode == 'P000'
                    ? Colors.green.withOpacity(isDarkBg ? 0.12 : 0.06)
                    : Colors.red.withOpacity(isDarkBg ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    latestHistory.diagnosisCode == 'P000'
                        ? Icons.check_circle_rounded
                        : Icons.warning_rounded,
                    color: latestHistory.diagnosisCode == 'P000'
                        ? Colors.green
                        : Colors.redAccent,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      latestHistory.hasilDiagnosis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: latestHistory.diagnosisCode == 'P000'
                            ? Colors.green
                            : Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onStartScreening,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Mulai Tes Baru',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final isDarkBg = Provider.of<AuthProvider>(context).selectedBackgroundThemeIndex == 2;
    final latestHistory = diagnosticProvider.historyList.isNotEmpty
        ? diagnosticProvider.historyList.first
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sistem Pakar Deteksi Gejala',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkBg ? Colors.white : const Color(0xFF3F3D56),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lakukan peninjauan kesehatan mental Anda secara dini.',
            style: TextStyle(
              fontSize: 14,
              color: isDarkBg ? Colors.white70 : const Color(0xFF707070),
            ),
          ),
          const SizedBox(height: 24),
          _buildScreeningMainCard(
            context,
            latestHistory,
            diagnosticProvider,
            isDarkBg,
          ),
          _buildTrendCard(context, diagnosticProvider, isDarkBg),
          if (user.role == 'admin') ...[
            const SizedBox(height: 24),
            _buildAdminSimulationButton(context, diagnosticProvider, isDarkBg),
          ]
        ],
      ),
    );
  }

  Widget _buildTrendCard(BuildContext context, DiagnosticProvider diagnosticProvider, bool isDarkBg) {
    final trend = diagnosticProvider.evaluate30DayScreeningTrend();
    if (trend['status'] == 'no_data') return const SizedBox.shrink();

    final cardBg = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final titleColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final bodyColor = isDarkBg ? Colors.white70 : const Color(0xFF505050);
    final borderColor = isDarkBg
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFF6C63FF).withOpacity(0.05);

    final Color statusColor = trend['color'] ?? Colors.grey;
    final IconData statusIcon = trend['icon'] ?? Icons.info_outline;

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkBg ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trend['title'] ?? 'Tren Kondisi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Analisis Tren 30 Hari',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkBg ? Colors.white54 : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pattern label
          Row(
            children: [
              Text(
                'Arah Perkembangan: ',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkBg ? Colors.white54 : Colors.black45,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend['pattern'] ?? '-',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            trend['message'] ?? '',
            style: TextStyle(
              fontSize: 13,
              color: bodyColor,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (trend['actions'] != null && (trend['actions'] as List).isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: isDarkBg ? Colors.white10 : Colors.black12, height: 1),
            const SizedBox(height: 16),
            Text(
              'Rekomendasi Tindakan:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: (trend['actions'] as List<dynamic>).map((action) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: statusColor, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          action as String,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: bodyColor,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminSimulationButton(
    BuildContext context,
    DiagnosticProvider diagnosticProvider,
    bool isDarkBg,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _showSimulationOptionDialog(context, diagnosticProvider, isDarkBg),
        icon: const Icon(Icons.bolt_rounded, color: Colors.amber),
        label: const Text(
          'Simulasikan Skrining 30 Hari',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.amber,
          side: const BorderSide(color: Colors.amber, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showSimulationOptionDialog(
    BuildContext context,
    DiagnosticProvider diagnosticProvider,
    bool isDarkBg,
  ) {
    final dialogBgColor = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final titleTextColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleTextColor = isDarkBg ? Colors.white70 : const Color(0xFF707070);

    showDialog(
      context: context,
      builder: (BuildContext dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            decoration: BoxDecoration(
              color: dialogBgColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDarkBg ? Colors.white10 : Colors.black.withOpacity(0.05),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkBg ? 0.4 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Simulasi Skrining 30 Hari',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: titleTextColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih skenario tren hasil tes skrining yang ingin disimulasikan untuk 30 hari terakhir:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleTextColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Option 1: Improving Condition
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogCtx);
                      await _runScreeningSimulation(context, diagnosticProvider, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Skenario 1: Kondisi Membaik',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Option 2: Worsening/Not Improving Condition
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogCtx);
                      await _runScreeningSimulation(context, diagnosticProvider, false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Skenario 2: Kondisi Belum Membaik',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  OutlinedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDarkBg ? Colors.white24 : Colors.black12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: isDarkBg ? Colors.white70 : const Color(0xFF505050),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _runScreeningSimulation(
    BuildContext context,
    DiagnosticProvider diagnosticProvider,
    bool isImproving,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menyiapkan data simulasi skrining 30 hari...')),
    );

    final List<HistoryModel> simulatedHistories = [];
    final now = DateTime.now();

    for (int day = 1; day <= 30; day++) {
      // Spread evenly over the last 30 days
      final date = DateTime(now.year, now.month, day, 10, 0).subtract(const Duration(days: 30)).add(Duration(days: day));
      
      String code;
      String title;
      String desc;
      List<String> symptoms;
      List<String> solutions;

      bool isFirstHalf = day <= 15;
      
      if (isImproving) {
        // Improving: Day 1-15: Depresi/Stress Berat, Day 16-30: Stress Ringan/Normal
        if (isFirstHalf) {
          if (day % 2 == 0) {
            code = 'P004';
            title = 'Depresi';
            desc = 'Berdasarkan analisis gejala, Anda menunjukkan indikasi suasana hati yang mendalam (depresi).';
            symptoms = ['G010', 'G011', 'G012'];
            solutions = ['Sangat disarankan segera berkonsultasi dengan Psikolog klinis atau Psikiater.', 'Jaga komunikasi aktif dengan keluarga.'];
          } else {
            code = 'P003';
            title = 'Stress Berat';
            desc = 'Tekanan mental yang Anda rasakan berada pada tingkat berat dan berisiko mengganggu kesehatan fisik.';
            symptoms = ['G007', 'G008', 'G009'];
            solutions = ['Segera konsultasikan kondisi Anda kepada Psikolog.', 'Batasi paparan terhadap pemicu stres utama.'];
          }
        } else {
          if (day % 2 == 0) {
            code = 'P001';
            title = 'Stress Ringan';
            desc = 'Kondisi di mana Anda mengalami tekanan emosional ringan. Hal ini wajar dan dapat diatasi secara mandiri.';
            symptoms = ['G001', 'G002', 'G003'];
            solutions = ['Lakukan latihan relaksasi pernapasan.', 'Tulis jurnal mood harian.'];
          } else {
            code = 'P000';
            title = 'Sehat Secara Mental (Normal)';
            desc = 'Berdasarkan hasil analisis gejala, kondisi psikologis Anda saat ini tergolong normal dan stabil.';
            symptoms = [];
            solutions = ['Pertahankan pola hidup sehat dan tidur cukup.', 'Lakukan relaksasi harian.'];
          }
        }
      } else {
        // Not Improving: Day 1-15: Normal/Stress Ringan, Day 16-30: Stress Berat/Depresi
        if (isFirstHalf) {
          if (day % 2 == 0) {
            code = 'P000';
            title = 'Sehat Secara Mental (Normal)';
            desc = 'Berdasarkan hasil analisis gejala, kondisi psikologis Anda saat ini tergolong normal dan stabil.';
            symptoms = [];
            solutions = ['Pertahankan pola hidup sehat dan tidur cukup.', 'Lakukan relaksasi harian.'];
          } else {
            code = 'P001';
            title = 'Stress Ringan';
            desc = 'Kondisi di mana Anda mengalami tekanan emosional ringan. Hal ini wajar dan dapat diatasi secara mandiri.';
            symptoms = ['G001', 'G002', 'G003'];
            solutions = ['Lakukan latihan relaksasi pernapasan.', 'Tulis jurnal mood harian.'];
          }
        } else {
          if (day % 2 == 0) {
            code = 'P004';
            title = 'Depresi';
            desc = 'Berdasarkan analisis gejala, Anda menunjukkan indikasi suasana hati yang mendalam (depresi).';
            symptoms = ['G010', 'G011', 'G012'];
            solutions = ['Sangat disarankan segera berkonsultasi dengan Psikolog klinis atau Psikiater.', 'Jaga komunikasi aktif dengan keluarga.'];
          } else {
            code = 'P003';
            title = 'Stress Berat';
            desc = 'Tekanan mental yang Anda rasakan berada pada tingkat berat dan berisiko mengganggu kesehatan fisik.';
            symptoms = ['G007', 'G008', 'G009'];
            solutions = ['Segera konsultasikan kondisi Anda kepada Psikolog.', 'Batasi paparan terhadap pemicu stres utama.'];
          }
        }
      }

      simulatedHistories.add(HistoryModel(
        id: '',
        userId: user.uid,
        tanggal: date,
        gejalaDipilih: symptoms,
        hasilDiagnosis: title,
        diagnosisCode: code,
        deskripsi: desc,
        solusi: solutions,
      ));
    }

    final success = await diagnosticProvider.addHistoryBatch(user.uid, simulatedHistories);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? 'Simulasi data skrining 30 hari berhasil dimuat!' 
              : 'Gagal memuat data skrining simulasi.'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }
}
