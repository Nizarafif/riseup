import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/diagnostic_provider.dart';
import 'admin_dialogs.dart';

class RulesManager extends StatelessWidget {
  const RulesManager({super.key});

  void _showAddRuleDialog(BuildContext context) {
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final List<String> selectedGejala = [];
    String? selectedDiseaseCode;
    
    final diagProvider = Provider.of<DiagnosticProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setState) {
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
                                color: const Color(0xFF00C9A7).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.rule_rounded, color: Color(0xFF00C9A7), size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Tambah Aturan Baru',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 24),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: codeController,
                          decoration: InputDecoration(
                            labelText: 'Kode Aturan',
                            hintText: 'Contoh: R005',
                            labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF00C9A7), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Kode tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Pilih Gangguan (THEN):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedDiseaseCode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF00C9A7), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          dropdownColor: Colors.white,
                          items: diagProvider.diseases.map((d) {
                            return DropdownMenuItem(
                              value: d.code,
                              child: Text('[${d.code}] ${d.name}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedDiseaseCode = val);
                          },
                          validator: (val) => val == null ? 'Pilih kesimpulan gangguan' : null,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Pilih Gejala Prasyarat (IF):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 180),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: ListView(
                            shrinkWrap: true,
                            children: diagProvider.symptoms.map((symptom) {
                              final isChecked = selectedGejala.contains(symptom.code);
                              return CheckboxListTile(
                                value: isChecked,
                                activeColor: const Color(0xFF00C9A7),
                                checkColor: Colors.white,
                                title: Text(
                                  '[${symptom.code}] ${symptom.name}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                                ),
                                controlAffinity: ListTileControlAffinity.leading,
                                dense: true,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      selectedGejala.add(symptom.code);
                                    } else {
                                      selectedGejala.remove(symptom.code);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
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
                              onPressed: selectedGejala.isEmpty || selectedDiseaseCode == null
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        await diagProvider.addRule(
                                          codeController.text.trim().toUpperCase(),
                                          selectedGejala,
                                          selectedDiseaseCode!,
                                        );
                                        if (dialogCtx.mounted) {
                                          Navigator.pop(dialogCtx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Aturan baru berhasil disimpan!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C9A7),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey[200],
                                disabledForegroundColor: Colors.grey[400],
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'Simpan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final rules = diagnosticProvider.rules;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Aturan Keputusan',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 15),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddRuleDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C9A7),
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
          child: rules.isEmpty
              ? AdminDialogs.buildEmptyState('Belum ada aturan keputusan. Gunakan tombol awan di header untuk memuat data default atau tambah manual.')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final rule = rules[index];
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    rule.code,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706), fontSize: 10, letterSpacing: 0.5),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final confirm = await AdminDialogs.showConfirmDelete(context, 'Aturan ${rule.code}');
                                    if (confirm == true) {
                                      await diagnosticProvider.deleteRule(rule.id);
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
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    'IF ',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF6C63FF)),
                                  ),
                                ),
                                Expanded(
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: rule.gejalaRequired.map<Widget>((g) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          g,
                                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'THEN ',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF00C9A7)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    rule.hasilGangguan,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5, color: Color(0xFF047857)),
                                  ),
                                ),
                              ],
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
