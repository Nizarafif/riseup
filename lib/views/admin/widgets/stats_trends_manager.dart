import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/diagnostic_provider.dart';
import '../../../providers/auth_provider.dart';

class StatsTrendsManager extends StatelessWidget {
  const StatsTrendsManager({super.key});

  void _showAddAdminDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
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
                              onPressed: isSubmitting ? null : () => Navigator.pop(dialogCtx),
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
                                          if (dialogCtx.mounted) {
                                            Navigator.pop(dialogCtx);
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
                                          if (dialogCtx.mounted) {
                                            ScaffoldMessenger.of(dialogCtx).showSnackBar(
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

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
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
                  'Konfirmasi Keluar',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16),
                ),
                const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 24),
                const SizedBox(height: 4),
                const Text(
                  'Apakah Anda yakin ingin keluar dari sesi pakar/admin saat ini?',
                  style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
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
                      onPressed: () {
                        Navigator.pop(dialogCtx); // Close dialog
                        Provider.of<AuthProvider>(context, listen: false).signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Keluar',
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

  void _showSeedConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
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
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogCtx); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Memproses inisialisasi database...')),
                      );
                      await Provider.of<DiagnosticProvider>(context, listen: false).seedDatabase();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Database berhasil diinisialisasi!'), backgroundColor: Colors.green),
                        );
                      }
                    },
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

  @override
  Widget build(BuildContext context) {
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                onPressed: () => _showAddAdminDialog(context),
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
              const SizedBox(height: 24),
              // Bagian Kontrol Sistem
              const Text(
                'Kontrol & Pengaturan Sistem',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_download_rounded, color: Color(0xFF6C63FF), size: 20),
                      ),
                      title: const Text('Inisialisasi Database', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                      subtitle: const Text('Muat ulang data gejala & aturan default ke Firebase', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                      onTap: () => _showSeedConfirmationDialog(context),
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                      ),
                      title: const Text('Keluar Akun (Logout)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent)),
                      subtitle: const Text('Keluar dari sesi pakar/admin saat ini', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.redAccent),
                      onTap: () => _showLogoutConfirmationDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
        ],
      ),
    );
  }
}
