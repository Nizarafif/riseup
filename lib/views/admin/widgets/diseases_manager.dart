import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/diagnostic_provider.dart';
import '../../../models/disease_model.dart';
import 'admin_dialogs.dart';

class DiseasesManager extends StatelessWidget {
  const DiseasesManager({super.key});

  void _showAddDiseaseDialog(BuildContext context) {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final solutionsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9F64).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.psychology_rounded, color: Color(0xFFFF9F64), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tambah Diagnosis Baru',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 24),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: codeController,
                      decoration: InputDecoration(
                        labelText: 'Kode Diagnosis',
                        hintText: 'Contoh: P005',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Kode tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Gangguan',
                        hintText: 'Contoh: Gangguan Kecemasan',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        hintText: 'Masukkan penjelasan mengenai gangguan ini',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      maxLines: 3,
                      validator: (val) => val == null || val.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: solutionsController,
                      decoration: InputDecoration(
                        labelText: 'Solusi / Tips (Pisahkan dengan koma)',
                        hintText: 'Contoh: Olahraga, Istirahat, Konsultasi',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      maxLines: 2,
                      validator: (val) => val == null || val.isEmpty ? 'Solusi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final List<String> solList = solutionsController.text
                                  .split(',')
                                  .map((s) => s.trim())
                                  .where((s) => s.isNotEmpty)
                                  .toList();
                              
                              await Provider.of<DiagnosticProvider>(context, listen: false).addDisease(
                                codeController.text.trim().toUpperCase(),
                                nameController.text.trim(),
                                descriptionController.text.trim(),
                                solList,
                              );
                              
                              if (dialogCtx.mounted) {
                                Navigator.pop(dialogCtx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Diagnosis baru berhasil disimpan!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final List<DiseaseModel> diseases = diagnosticProvider.diseases;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Diagnosis & Gangguan',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 15),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDiseaseDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9F64),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: diseases.isEmpty
              ? AdminDialogs.buildEmptyState('Belum ada data diagnosis. Gunakan tombol awan di header untuk memuat data default.')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: diseases.length,
                  itemBuilder: (context, index) {
                    final disease = diseases[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2FE),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        disease.code,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0369A1), fontSize: 10, letterSpacing: 0.5),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      disease.name,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final confirm = await AdminDialogs.showConfirmDelete(context, 'Diagnosis ${disease.code}');
                                    if (confirm == true) {
                                      await diagnosticProvider.deleteDisease(disease.id);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFF1F2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFFF1F5F9), height: 20),
                            Text(
                              disease.description,
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Rekomendasi Tindakan / Solusi:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: disease.solutions.map((sol) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4, right: 6),
                                        child: Icon(Icons.circle, size: 5, color: Color(0xFFFF9F64)),
                                      ),
                                      Expanded(
                                        child: Text(
                                          sol,
                                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
