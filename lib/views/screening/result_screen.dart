import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diagnostic_provider.dart';
import 'map_webview_screen.dart';
import 'widgets/counselor_list_sheet.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  void _launchMaps(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MapWebviewScreen(
          url: 'https://www.google.com/maps/search/?api=1&query=psikolog+dan+psikiater+terdekat',
          title: 'Peta Psikolog & Psikiater',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final diagnosis = diagnosticProvider.latestDiagnosis;
    final isNormal = diagnosis == null || diagnosis.code == 'P000';
    final isSevere = diagnosis != null && (diagnosis.code == 'P003' || diagnosis.code == 'P004');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Header
              const Text(
                'Hasil Analisis Pakar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3D56),
                ),
              ),
              const SizedBox(height: 32),

              // Animated Outcome Icon & Label
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isNormal
                            ? Colors.green.withOpacity(0.1)
                            : isSevere
                                ? Colors.red.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isNormal 
                            ? Icons.sentiment_satisfied_alt_rounded 
                            : isSevere
                                ? Icons.mood_bad_rounded
                                : Icons.sentiment_dissatisfied_rounded,
                        size: 64,
                        color: isNormal 
                            ? Colors.green 
                            : isSevere 
                                ? Colors.redAccent 
                                : Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'DIAGNOSIS AWAL:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diagnosis?.name ?? 'Kondisi Mental Stabil (Normal)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isNormal 
                            ? Colors.green[800] 
                            : isSevere 
                                ? Colors.red[800] 
                                : Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      diagnosis?.description ??
                          'Berdasarkan gejala yang Anda input, sistem pakar menyimpulkan bahwa kondisi mental Anda saat ini tergolong normal dan stabil. Anda tidak menunjukkan indikasi stres, kecemasan, atau depresi yang signifikan menurut aturan pakar.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF505050),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Kartu Rekomendasi Utama (Untuk Stress Berat / Depresi)
              if (isSevere) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.gavel_rounded, color: Colors.redAccent, size: 22),
                          SizedBox(width: 12),
                          Text(
                            'Saran Penanganan Utama:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Kondisi kesehatan mental Anda terdeteksi berada pada level yang membutuhkan perhatian serius. Penanganan mandiri tidak disarankan sebagai terapi utama. Anda sangat direkomendasikan untuk segera berkonsultasi dengan psikolog atau psikiater profesional.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: Color(0xFF3F3D56),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const CounselorListSheet(),
                            );
                          },
                          icon: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 18),
                          label: const Text(
                            'Hubungi Psikolog / Konselor',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => _launchMaps(context),
                          icon: const Icon(Icons.map_rounded, color: Colors.redAccent, size: 18),
                          label: const Text(
                            'Cari Psikolog / Psikiater Terdekat',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Actionable Solutions Checklist
              const Text(
                'Rekomendasi Penanganan Pertama:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3D56),
                ),
              ),
              const SizedBox(height: 12),
              
              // Solutions list
              ..._buildSolutionsList(diagnosis?.solutions ?? [
                'Pertahankan rutinitas tidur teratur (7-8 jam per hari).',
                'Lakukan relaksasi/meditasi 10 menit saat merasa penat.',
                'Pertahankan hubungan sosial yang harmonis dengan orang terdekat.'
              ]),
              const SizedBox(height: 24),

              // Disclaimer Card (Responsible Health UX)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.gavel_rounded, color: Colors.orange, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'PENTING: Aplikasi ini menggunakan metode Sistem Pakar Forward Chaining sebagai langkah deteksi awal (monitoring). Hasil tes bukan merupakan diagnosis final medis/klinis resmi. Jika kondisi Anda memburuk atau mengganggu aktivitas sehari-hari, segera hubungi psikolog atau psikiater profesional.',
                        style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Done Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Kembali ke Dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Selesai & Kembali',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSolutionsList(List<String> solutions) {
    return solutions.map((solution) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_box_rounded, color: Color(0xFF00C9A7), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                solution,
                style: const TextStyle(fontSize: 13, color: Color(0xFF3F3D56), height: 1.4),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
