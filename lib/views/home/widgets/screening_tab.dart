import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
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
        ],
      ),
    );
  }
}
