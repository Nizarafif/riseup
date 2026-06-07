import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diagnostic_provider.dart';
import '../../models/symptom_model.dart';
import '../../models/rule_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddSymptomDialog() {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Gejala Baru'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Kode Gejala (Contoh: G013)'),
                  validator: (val) => val == null || val.isEmpty ? 'Kode tidak boleh kosong' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Gejala (Deskripsi)'),
                  maxLines: 2,
                  validator: (val) => val == null || val.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await Provider.of<DiagnosticProvider>(context, listen: false).addSymptom(
                    codeController.text.trim().toUpperCase(),
                    nameController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gejala berhasil ditambahkan'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }

  void _showAddRuleDialog() {
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final List<String> selectedGejala = [];
    String? selectedDiseaseCode;
    
    final diagProvider = Provider.of<DiagnosticProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Aturan Baru'),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        controller: codeController,
                        decoration: const InputDecoration(labelText: 'Kode Aturan (Contoh: R004)'),
                        validator: (val) => val == null || val.isEmpty ? 'Kode tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pilih Gangguan (Kesimpulan):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedDiseaseCode,
                        items: diagProvider.diseases.map((d) {
                          return DropdownMenuItem(
                            value: d.code,
                            child: Text('${d.code} - ${d.name}'),
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      ...diagProvider.symptoms.map((symptom) {
                        final isChecked = selectedGejala.contains(symptom.code);
                        return CheckboxListTile(
                          value: isChecked,
                          title: Text('[${symptom.code}] ${symptom.name}', style: const TextStyle(fontSize: 12)),
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
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
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
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Aturan berhasil disimpan'), backgroundColor: Colors.green),
                              );
                            }
                          }
                        },
                  child: const Text('Simpan'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Panel Pakar / Admin',
          style: TextStyle(color: Color(0xFF3F3D56), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF3F3D56)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6C63FF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6C63FF),
          tabs: const [
            Tab(icon: Icon(Icons.psychology_outlined), text: 'Kelola Gejala'),
            Tab(icon: Icon(Icons.rule_rounded), text: 'Kelola Aturan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSymptomsManager(),
          _buildRulesManager(),
        ],
      ),
    );
  }

  Widget _buildSymptomsManager() {
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final symptoms = diagnosticProvider.symptoms;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Gejala: ${symptoms.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              ElevatedButton.icon(
                onPressed: _showAddSymptomDialog,
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('Gejala Baru', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: symptoms.isEmpty
              ? const Center(child: Text('Belum ada gejala. Tambahkan baru.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: symptoms.length,
                  itemBuilder: (context, index) {
                    final symptom = symptoms[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0.5,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                          child: Text(
                            symptom.code,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                        ),
                        title: Text(
                          symptom.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () async {
                            final confirm = await _showConfirmDeleteDialog('Gejala ${symptom.code}');
                            if (confirm == true) {
                              await diagnosticProvider.deleteSymptom(symptom.id);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRulesManager() {
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final rules = diagnosticProvider.rules;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Aturan: ${rules.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              ElevatedButton.icon(
                onPressed: _showAddRuleDialog,
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('Aturan Baru', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: rules.isEmpty
              ? const Center(child: Text('Belum ada aturan. Tambahkan baru.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0.5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    rule.code,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 12),
                                  ),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                  onPressed: () async {
                                    final confirm = await _showConfirmDeleteDialog('Aturan ${rule.code}');
                                    if (confirm == true) {
                                      await diagnosticProvider.deleteRule(rule.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'IF Gejala Terpilih:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              children: rule.gejalaRequired.map((g) {
                                return Chip(
                                  label: Text(g, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'THEN Kesimpulan Gangguan:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                rule.hasilGangguan,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent),
                              ),
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

  Future<bool?> _showConfirmDeleteDialog(String label) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus $label? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
