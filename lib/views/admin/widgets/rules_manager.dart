import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/diagnostic_provider.dart';
import '../../../models/rule_model.dart';
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.transparent,
              elevation: 8,
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top accent cyan bar
                    Container(
                      height: 6,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00C9A7), Color(0xFF5BE7C4)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00C9A7).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFF00C9A7).withOpacity(0.15),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.rule_rounded, color: Color(0xFF00C9A7), size: 22),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Text(
                                    'Tambah Aturan Baru',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                      fontSize: 16,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 16),
                                height: 1,
                                color: const Color(0xFFF1F5F9),
                              ),
                              TextFormField(
                                controller: codeController,
                                decoration: InputDecoration(
                                  labelText: 'Kode Aturan',
                                  hintText: 'Contoh: R005',
                                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 13),
                                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFF00C9A7), width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFF00C9A7), width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                dropdownColor: Colors.white,
                                items: () {
                                  final seen = <String>{};
                                  return diagProvider.diseases
                                      .where((d) => seen.add(d.code))
                                      .map((d) => DropdownMenuItem(
                                            value: d.code,
                                            child: Text(
                                              '[${d.code}] ${d.name}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ))
                                      .toList();
                                }(),
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
                                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                                  borderRadius: BorderRadius.circular(14),
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
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF64748B),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF00C9A7), Color(0xFF5BE7C4)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00C9A7).withOpacity(0.25),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
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
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        disabledBackgroundColor: Colors.transparent,
                                        disabledForegroundColor: Colors.white60,
                                      ),
                                      child: const Text(
                                        'Simpan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditRuleDialog(BuildContext context, RuleModel rule) {
    final codeController = TextEditingController(text: rule.code);
    final formKey = GlobalKey<FormState>();
    final List<String> selectedGejala = List<String>.from(rule.gejalaRequired);
    final diagProvider = Provider.of<DiagnosticProvider>(context, listen: false);
    final hasDisease = diagProvider.diseases.any((d) => d.code == rule.hasilGangguan);
    String? selectedDiseaseCode = hasDisease ? rule.hasilGangguan : null;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.transparent,
              elevation: 8,
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top accent cyan bar
                    Container(
                      height: 6,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00C9A7), Color(0xFF5BE7C4)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00C9A7).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFF00C9A7).withOpacity(0.15),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.edit_note_rounded, color: Color(0xFF00C9A7), size: 22),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Text(
                                    'Edit Aturan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                      fontSize: 16,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 16),
                                height: 1,
                                color: const Color(0xFFF1F5F9),
                              ),
                              TextFormField(
                                controller: codeController,
                                decoration: InputDecoration(
                                  labelText: 'Kode Aturan',
                                  hintText: 'Contoh: R005',
                                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 13),
                                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFF00C9A7), width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: Color(0xFF00C9A7), width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                dropdownColor: Colors.white,
                                items: () {
                                  final seen = <String>{};
                                  return diagProvider.diseases
                                      .where((d) => seen.add(d.code))
                                      .map((d) => DropdownMenuItem(
                                            value: d.code,
                                            child: Text(
                                              '[${d.code}] ${d.name}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ))
                                      .toList();
                                }(),
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
                                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                                  borderRadius: BorderRadius.circular(14),
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
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF64748B),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF00C9A7), Color(0xFF5BE7C4)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00C9A7).withOpacity(0.25),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: selectedGejala.isEmpty || selectedDiseaseCode == null
                                          ? null
                                          : () async {
                                              if (formKey.currentState!.validate()) {
                                                await diagProvider.updateRule(
                                                  rule.id,
                                                  codeController.text.trim().toUpperCase(),
                                                  selectedGejala,
                                                  selectedDiseaseCode!,
                                                );
                                                if (dialogCtx.mounted) {
                                                  Navigator.pop(dialogCtx);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Perubahan aturan berhasil disimpan!'),
                                                      backgroundColor: Colors.green,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        disabledBackgroundColor: Colors.transparent,
                                        disabledForegroundColor: Colors.white60,
                                      ),
                                      child: const Text(
                                        'Simpan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.white,
                                        ),
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
                  ],
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _showEditRuleDialog(context, rule),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00C9A7).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.edit_rounded, color: Color(0xFF00C9A7), size: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
