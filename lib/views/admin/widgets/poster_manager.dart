import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';
import '../../../providers/diagnostic_provider.dart';
import 'admin_dialogs.dart';

class PosterManager extends StatelessWidget {
  const PosterManager({super.key});

  void _showAddMotivationDialog(BuildContext context, DiagnosticProvider diagnosticProvider) {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
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
                        child: const Icon(Icons.format_quote_rounded, color: Color(0xFF6C63FF), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tambah Motivasi Baru',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 24),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: textController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Kata Motivasi / Kutipan',
                      hintText: 'Tulis kalimat motivasi kesehatan mental...',
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
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Teks tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            await diagnosticProvider.addMotivation(textController.text.trim());
                            if (dialogCtx.mounted) {
                              Navigator.pop(dialogCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Motivasi baru berhasil ditambahkan!'),
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

  @override
  Widget build(BuildContext context) {
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final activePosters = diagnosticProvider.posters;
    final motivations = diagnosticProvider.motivations;
    
    final defaultAssetPosters = const [
      'assets/poster/poster1.jpg',
      'assets/poster/poster3.jpg',
      'assets/poster/poster4.jpg',
      'assets/poster/posterr5.jpg',
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: TabBar(
            labelColor: Color(0xFF6C63FF),
            unselectedLabelColor: Color(0xFF64748B),
            indicatorColor: Color(0xFF6C63FF),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Poster Edukasi'),
              Tab(text: 'Kata Motivasi'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Poster Edukasi
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kelola Poster Beranda',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${activePosters.length} Poster aktif',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                          if (image != null) {
                            await diagnosticProvider.addPoster(image.path);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Poster kustom berhasil ditambahkan!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.photo_library_rounded, size: 14),
                        label: const Text('Pilih Foto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Poster Aktif Saat Ini',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 11.5),
                        ),
                        const SizedBox(height: 8),
                        activePosters.isEmpty
                            ? Container(
                                height: 100,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Text(
                                  'Tidak ada poster aktif. Menggunakan poster bawaan.',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.5,
                                ),
                                itemCount: activePosters.length,
                                itemBuilder: (context, index) {
                                  final path = activePosters[index];
                                  final isAsset = path.startsWith('assets/');

                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Image(
                                              image: isAsset
                                                  ? AssetImage(path) as ImageProvider
                                                  : FileImage(io.File(path)),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            left: 6,
                                            top: 6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isAsset ? Colors.blue.withOpacity(0.85) : Colors.green.withOpacity(0.85),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                isAsset ? 'Bawaan' : 'Kustom',
                                                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 6,
                                            top: 6,
                                            child: GestureDetector(
                                              onTap: () async {
                                                final confirm = await AdminDialogs.showConfirmDelete(context, 'Poster dari daftar aktif');
                                                if (confirm == true) {
                                                  await diagnosticProvider.deletePoster(path);
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(5),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        const SizedBox(height: 20),
                        const Text(
                          'Preset Poster Bawaan (Klik untuk aktifkan)',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 11.5),
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: defaultAssetPosters.length,
                          itemBuilder: (context, index) {
                            final path = defaultAssetPosters[index];
                            final isAlreadyActive = activePosters.contains(path);

                            return GestureDetector(
                              onTap: isAlreadyActive
                                  ? null
                                  : () async {
                                      await diagnosticProvider.addPoster(path);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Poster preset diaktifkan!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    },
                              child: Opacity(
                                opacity: isAlreadyActive ? 0.4 : 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isAlreadyActive ? Colors.transparent : const Color(0xFF6C63FF).withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Image.asset(path, fit: BoxFit.cover),
                                        ),
                                        if (isAlreadyActive)
                                          Positioned.fill(
                                            child: Container(
                                              color: Colors.black26,
                                              child: const Center(
                                                child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Tab 2: Kata Motivasi
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kelola Kutipan Motivasi',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${motivations.length} Motivasi terdaftar',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddMotivationDialog(context, diagnosticProvider),
                        icon: const Icon(Icons.add_rounded, size: 14),
                        label: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 16),
                Expanded(
                  child: motivations.isEmpty
                      ? AdminDialogs.buildEmptyState('Belum ada kata motivasi terdaftar. Klik tombol Tambah di atas untuk membuat kata motivasi kustom.')
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: motivations.length,
                          itemBuilder: (context, index) {
                            final quote = motivations[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF).withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.format_quote_rounded, color: Color(0xFF6C63FF), size: 18),
                                ),
                                title: Text(
                                  '"$quote"',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF334155),
                                    height: 1.4,
                                  ),
                                ),
                                trailing: GestureDetector(
                                  onTap: () async {
                                    final confirm = await AdminDialogs.showConfirmDelete(context, 'Kutipan motivasi ini');
                                    if (confirm == true) {
                                      await diagnosticProvider.deleteMotivation(quote);
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
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
