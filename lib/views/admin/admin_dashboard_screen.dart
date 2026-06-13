import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' show ImageFilter;
import 'package:intl/intl.dart';
import '../../providers/diagnostic_provider.dart';
import '../auth/widgets/doodle_background.dart';
import '../../models/disease_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int initialTabIndex;
  const AdminDashboardScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DiagnosticProvider _diagnosticProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTabIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _diagnosticProvider.listenToAdminData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _diagnosticProvider = Provider.of<DiagnosticProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _diagnosticProvider.cancelAdminListeners();
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
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_task_rounded, color: Color(0xFF6C63FF), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tambah Gejala Baru',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 24),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Kode Gejala',
                      hintText: 'Contoh: G013',
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
                        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Kode tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Gejala',
                      hintText: 'Masukkan nama/deskripsi gejala',
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
                        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: 2,
                    validator: (val) => val == null || val.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                                const SnackBar(
                                  content: Text('Gejala baru berhasil disimpan!'),
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
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                              onPressed: () => Navigator.pop(context),
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
                                        if (context.mounted) {
                                          Navigator.pop(context);
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
    final symptoms = diagnosticProvider.symptoms;
    final rules = diagnosticProvider.rules;
    final diseases = diagnosticProvider.diseases;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildStatsRow(symptoms.length, rules.length),
              const SizedBox(height: 16),
              _buildTabSelector(),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.025),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSymptomsManager(symptoms, diagnosticProvider),
                      _buildRulesManager(rules, diagnosticProvider),
                      _buildDiseasesManager(diseases, diagnosticProvider),
                      _buildStatsAndTrends(diagnosticProvider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF475569), size: 14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Panel Kontrol Pakar',
                  style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 2),
                Text(
                  'Atur Basis Pengetahuan & Aturan',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Inisialisasi Database', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                        const Divider(height: 20, thickness: 1, color: Color(0xFFF1F5F9)),
                        const Text(
                          'Apakah Anda ingin memuat data gejala, gangguan, dan aturan default ke Firebase?',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Ya, Muat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
              if (confirm == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Memproses inisialisasi database...')),
                );
                await Provider.of<DiagnosticProvider>(context, listen: false).seedDatabase();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Database berhasil diinisialisasi!'), backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_download_rounded, color: Color(0xFF6C63FF), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int symptomCount, int ruleCount) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: const Border(left: BorderSide(color: Color(0xFF8B5CF6), width: 4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.spa_rounded, color: Color(0xFF8B5CF6), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$symptomCount Gejala',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 13),
                      ),
                      const Text(
                        'Telah terdaftar',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: const Border(left: BorderSide(color: Color(0xFF10B981), width: 4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.rule_folder_rounded, color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$ruleCount Aturan',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 13),
                      ),
                      const Text(
                        'Telah terkonfigurasi',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: const Color(0xFF1E293B),
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Gejala'),
            Tab(text: 'Aturan'),
            Tab(text: 'Diagnosis'),
            Tab(text: 'Statistik'),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsManager(List<dynamic> symptoms, DiagnosticProvider diagnosticProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Gejala Klinis',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 15),
              ),
              ElevatedButton.icon(
                onPressed: _showAddSymptomDialog,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
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
          child: symptoms.isEmpty
              ? _buildEmptyStateWidget('Basis gejala kosong. Gunakan tombol awan di header untuk memuat data default atau tambah gejala manual.')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: symptoms.length,
                  itemBuilder: (context, index) {
                    final symptom = symptoms[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              symptom.code,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          symptom.name,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF334155), height: 1.4),
                        ),
                        trailing: GestureDetector(
                          onTap: () async {
                            final confirm = await _showConfirmDeleteDialog('Gejala ${symptom.code}');
                            if (confirm == true) {
                              await diagnosticProvider.deleteSymptom(symptom.id);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF1F2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRulesManager(List<dynamic> rules, DiagnosticProvider diagnosticProvider) {
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
                onPressed: _showAddRuleDialog,
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
              ? _buildEmptyStateWidget('Belum ada aturan keputusan. Gunakan tombol awan di header untuk memuat data default atau tambah manual.')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                    final confirm = await _showConfirmDeleteDialog('Aturan ${rule.code}');
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

  Widget _buildEmptyStateWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, size: 48, color: Color(0xFFD97706)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Database Kosong',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), height: 1.4, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDeleteDialog(String label) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Konfirmasi Hapus',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16),
                ),
                const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 24),
                const SizedBox(height: 4),
                Text(
                  'Apakah Anda yakin ingin menghapus $label? Tindakan ini tidak dapat dibatalkan.',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddDiseaseDialog() {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final solutionsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
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
                          onPressed: () => Navigator.pop(context),
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
                              
                              if (context.mounted) {
                                Navigator.pop(context);
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

  void _showAddAdminDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                                color: const Color(0xFF6C63FF).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_add_rounded, color: Color(0xFF6C63FF), size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Tambah Admin / Pakar Baru',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 24),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: nameController,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',
                            hintText: 'Contoh: Dr. Rudi H.',
                            labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          enabled: !isSubmitting,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Contoh: rudi@riseup.com',
                            labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF64748B)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Email tidak boleh kosong';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          enabled: !isSubmitting,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Minimal 6 karakter',
                            labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Password tidak boleh kosong';
                            if (val.length < 6) return 'Password minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: isSubmitting ? null : () => Navigator.pop(context),
                              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        setState(() {
                                          isSubmitting = true;
                                        });
                                        try {
                                          await Provider.of<DiagnosticProvider>(context, listen: false)
                                              .registerNewAdmin(
                                            nameController.text.trim(),
                                            emailController.text.trim(),
                                            passwordController.text,
                                          );
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Admin baru berhasil terdaftar!'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          setState(() {
                                            isSubmitting = false;
                                          });
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Gagal mendaftarkan admin: ${e.toString().replaceAll('Exception: ', '')}'),
                                                backgroundColor: Colors.redAccent,
                                              ),
                                            );
                                          }
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
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildDiseasesManager(List<DiseaseModel> diseases, DiagnosticProvider diagnosticProvider) {
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
                onPressed: _showAddDiseaseDialog,
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
              ? _buildEmptyStateWidget('Belum ada data diagnosis. Gunakan tombol awan di header untuk memuat data default.')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                    final confirm = await _showConfirmDeleteDialog('Diagnosis ${disease.code}');
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

  Widget _buildStatsAndTrends(DiagnosticProvider diagnosticProvider) {
    if (diagnosticProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final users = diagnosticProvider.allUsers;
    final histories = diagnosticProvider.allHistories;
    
    // Hitung persentase tiap hasil diagnosis
    final Map<String, int> distribution = {};
    for (var h in histories) {
      final key = h.hasilDiagnosis;
      distribution[key] = (distribution[key] ?? 0) + 1;
    }

    final int totalTests = histories.length;

    // Filter daftar pengguna role "user" saja agar tidak menampilkan admin
    final listUsers = users.where((u) => u.role != 'admin').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kartu indikator ringkasan
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  icon: Icons.people_alt_rounded,
                  title: 'Total Pengguna',
                  value: '${listUsers.length}',
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  icon: Icons.history_edu_rounded,
                  title: 'Total Skrining',
                  value: '$totalTests',
                  color: const Color(0xFF6C63FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Bagian Distribusi Diagnosis
          const Text(
            'Distribusi Diagnosis Skrining',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: totalTests == 0
                ? const Center(
                    child: Text(
                      'Belum ada data riwayat skrining dari pengguna.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  )
                : Column(
                    children: distribution.entries.map((entry) {
                      final name = entry.key;
                      final count = entry.value;
                      final percent = (count / totalTests * 100).toStringAsFixed(1);
                      final double fraction = count / totalTests;
                      
                      // Berikan warna khusus berdasarkan jenis diagnosis
                      Color progressColor = const Color(0xFF6C63FF);
                      if (name.contains('Berat') || name.contains('Depresi')) {
                        progressColor = Colors.redAccent;
                      } else if (name.contains('Sedang')) {
                        progressColor = Colors.orangeAccent;
                      } else if (name.contains('Normal') || name.contains('Sehat')) {
                        progressColor = Colors.green;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF334155)),
                                ),
                                Text(
                                  '$count kasus ($percent%)',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: fraction,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 20),

          // Bagian Daftar Monitoring Pengguna
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monitoring Pengguna',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
              ),
              ElevatedButton.icon(
                onPressed: _showAddAdminDialog,
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text('Tambah Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          listUsers.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: const Text('Belum ada pengguna terdaftar.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listUsers.length,
                  itemBuilder: (context, idx) {
                    final u = listUsers[idx];
                    
                    // Temukan riwayat tes terbaru pengguna ini
                    final userHistories = histories.where((h) => h.userId == u.uid).toList();
                    String lastResult = 'Belum pernah tes';
                    Color resultColor = const Color(0xFF64748B);
                    
                    if (userHistories.isNotEmpty) {
                      // Urutkan berdasarkan tanggal terbaru
                      userHistories.sort((a, b) => b.tanggal.compareTo(a.tanggal));
                      final latest = userHistories.first;
                      lastResult = latest.hasilDiagnosis;
                      
                      if (lastResult.contains('Berat') || lastResult.contains('Depresi')) {
                        resultColor = Colors.redAccent;
                      } else if (lastResult.contains('Sedang')) {
                        resultColor = Colors.orangeAccent;
                      } else if (lastResult.contains('Normal') || lastResult.contains('Sehat')) {
                        resultColor = Colors.green;
                      } else {
                        resultColor = const Color(0xFF6C63FF);
                      }
                    }

                    final String joinDate = DateFormat('dd MMM yyyy, HH:mm').format(u.createdAt);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.person_outline_rounded, color: Color(0xFF6C63FF)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  u.email,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Gabung: $joinDate',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: resultColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              lastResult,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: resultColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
