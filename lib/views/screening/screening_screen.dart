import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diagnostic_provider.dart';
import 'result_screen.dart';

class ScreeningScreen extends StatelessWidget {
  const ScreeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tes Kesehatan Mental',
          style: TextStyle(color: Color(0xFF3F3D56), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF3F3D56)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: diagnosticProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : diagnosticProvider.symptoms.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: [
                    // Top Hint Header
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF6C63FF).withOpacity(0.05),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.info_outline_rounded, color: Color(0xFF6C63FF), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Petunjuk Pengisian Kuesioner:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3F3D56)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pilih gejala-gejala di bawah ini yang Anda rasakan secara konsisten selama 2 minggu terakhir.',
                            style: TextStyle(color: Color(0xFF707070), fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    
                    // Symptoms Checklist List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: diagnosticProvider.symptoms.length,
                        itemBuilder: (context, index) {
                          final symptom = diagnosticProvider.symptoms[index];
                          final isChecked = diagnosticProvider.selectedSymptomCodes.contains(symptom.code);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isChecked ? Colors.white : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isChecked ? const Color(0xFF6C63FF) : Colors.black12,
                                width: isChecked ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: CheckboxListTile(
                              value: isChecked,
                              activeColor: const Color(0xFF6C63FF),
                              checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isChecked ? const Color(0xFF6C63FF).withOpacity(0.1) : Colors.black.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      symptom.code,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isChecked ? const Color(0xFF6C63FF) : Colors.black54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      symptom.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                                        color: const Color(0xFF3F3D56),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onChanged: (bool? val) {
                                diagnosticProvider.toggleSymptom(symptom.code);
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Execution Button
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
                        ]
                      ),
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${diagnosticProvider.selectedSymptomCodes.length} Gejala Terpilih',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: diagnosticProvider.selectedSymptomCodes.isEmpty
                                    ? null
                                    : () async {
                                        if (user != null) {
                                          await diagnosticProvider.runDiagnosis(user.uid);
                                          if (context.mounted) {
                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(builder: (_) => const ResultScreen()),
                                            );
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  disabledBackgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: diagnosticProvider.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'Proses Analisis Pakar',
                                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orangeAccent),
            const SizedBox(height: 16),
            const Text(
              'Basis Gejala Kosong',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Belum ada data gejala kesehatan mental di database. Hubungi admin/pakar untuk menambahkan daftar gejala di Panel Pakar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali ke Dashboard'),
            )
          ],
        ),
      ),
    );
  }
}
