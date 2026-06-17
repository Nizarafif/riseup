import 'package:flutter/material.dart';
import '../../../models/book_model.dart';
import '../../../services/firestore_service.dart';

class BooksManager extends StatefulWidget {
  const BooksManager({super.key});

  @override
  State<BooksManager> createState() => _BooksManagerState();
}

class _BooksManagerState extends State<BooksManager> {
  final _dbService = FirestoreService();

  // Helper to map icon name to IconData
  IconData _getBookIcon(String iconName) {
    switch (iconName) {
      case 'self_improvement':
        return Icons.self_improvement_rounded;
      case 'wb_sunny':
        return Icons.wb_sunny_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'health_and_safety':
        return Icons.health_and_safety_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  // Predefined gradient presets for cover colors
  final List<List<int>> _gradientPresets = [
    [0xFF0284C7, 0xFF38BDF8], // Blue (WHO)
    [0xFF6C63FF, 0xFF8F8AFF], // Purple (Seni Berdamai)
    [0xFF00C9A7, 0xFF5BE7C4], // Teal (Lorong Depresi)
    [0xFFFF9F64, 0xFFFFBD96], // Orange (Penang Cemas)
    [0xFFEF4444, 0xFFF87171], // Red/Pink
    [0xFF1E293B, 0xFF475569], // Dark Slate
  ];

  // Predefined icons presets
  final List<Map<String, dynamic>> _iconPresets = [
    {'name': 'menu_book', 'label': 'Buku Saku', 'icon': Icons.menu_book_rounded},
    {'name': 'self_improvement', 'label': 'Meditasi / Ketenangan', 'icon': Icons.self_improvement_rounded},
    {'name': 'wb_sunny', 'label': 'Harapan / Cerah', 'icon': Icons.wb_sunny_rounded},
    {'name': 'health_and_safety', 'label': 'Kesehatan / Medis', 'icon': Icons.health_and_safety_rounded},
  ];

  TextAlign _getTextAlign(String alignName) {
    switch (alignName) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      case 'left':
      default:
        return TextAlign.left;
    }
  }

  Widget _buildAlignIconButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7).withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF94A3B8),
          size: 18,
        ),
      ),
    );
  }

  void _showAddEditBookDialog({BookModel? book}) {
    final isEdit = book != null;
    final titleController = TextEditingController(text: book?.title ?? '');
    final authorController = TextEditingController(text: book?.author ?? '');
    final durationController = TextEditingController(text: book?.duration ?? '10 Menit Baca');
    
    // Default selection
    List<int> selectedColors = book?.coverColors ?? _gradientPresets[0];
    String selectedIcon = book?.icon ?? 'menu_book';
    
    // Chapters list state
    List<BookChapter> chaptersList = book != null 
        ? List<BookChapter>.from(book.chapters) 
        : [BookChapter(title: 'Bab 1: ', content: '')];

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                    // Top Accent Line
                    Container(
                      height: 6,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    
                    // Dialog Title Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF0284C7).withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.library_books_rounded, color: Color(0xFF0284C7), size: 22),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            isEdit ? 'Edit Buku / Novel' : 'Tambah Buku Baru',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 24),

                    // Scrollable Content area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title Input
                              TextFormField(
                                controller: titleController,
                                decoration: _buildInputDecoration('Judul Buku', 'Contoh: Mengatasi Overthinking'),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Judul tidak boleh kosong' : null,
                              ),
                              const SizedBox(height: 16),
                              
                              // Author Input
                              TextFormField(
                                controller: authorController,
                                decoration: _buildInputDecoration('Penulis', 'Contoh: Tim Psikolog RiseUp'),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Penulis tidak boleh kosong' : null,
                              ),
                              const SizedBox(height: 16),

                              // Duration Input
                              TextFormField(
                                controller: durationController,
                                decoration: _buildInputDecoration('Durasi Baca', 'Contoh: 10 Menit Baca'),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Durasi tidak boleh kosong' : null,
                              ),
                              const SizedBox(height: 20),

                              // Cover Colors Picker
                              const Text(
                                'Pilih Warna Sampul (Gradien)',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 12),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: _gradientPresets.map((colors) {
                                  final isSelected = colors[0] == selectedColors[0] && colors[1] == selectedColors[1];
                                  return GestureDetector(
                                    onTap: () {
                                      setDialogState(() {
                                        selectedColors = colors;
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: colors.map((c) => Color(c)).toList(),
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                                          width: 3,
                                        ),
                                        boxShadow: isSelected
                                            ? [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 3))]
                                            : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),

                              // Icon Dropdown/Picker
                              const Text(
                                'Pilih Ikon Buku',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 12),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: selectedIcon,
                                decoration: _buildInputDecoration('Ikon Buku', ''),
                                items: _iconPresets.map((preset) {
                                  return DropdownMenuItem<String>(
                                    value: preset['name'],
                                    child: Row(
                                      children: [
                                        Icon(preset['icon'], color: const Color(0xFF0284C7), size: 20),
                                        const SizedBox(width: 12),
                                        Text(preset['label'], style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() {
                                      selectedIcon = val;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 24),

                              // --- CHAPTERS HEADER & ADD BUTTON ---
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Daftar Bab & Cerita',
                                    style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 14),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setDialogState(() {
                                        chaptersList.add(BookChapter(
                                          title: 'Bab ${chaptersList.length + 1}: ',
                                          content: '',
                                        ));
                                      });
                                    },
                                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                                    label: const Text('Tambah Bab', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF0284C7),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 16),

                              // Chapters Forms List
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: chaptersList.length,
                                itemBuilder: (chapterCtx, index) {
                                  final ch = chaptersList[index];
                                  final chTitleController = TextEditingController(text: ch.title);
                                  final chContentController = TextEditingController(text: ch.content);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Bab #${index + 1}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF475569),
                                                fontSize: 12,
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _buildAlignIconButton(
                                                  icon: Icons.format_align_left_rounded,
                                                  isSelected: ch.textAlign == 'left',
                                                  onTap: () {
                                                    setDialogState(() {
                                                      chaptersList[index] = BookChapter(
                                                        title: chaptersList[index].title,
                                                        content: chaptersList[index].content,
                                                        textAlign: 'left',
                                                      );
                                                    });
                                                  },
                                                ),
                                                _buildAlignIconButton(
                                                  icon: Icons.format_align_center_rounded,
                                                  isSelected: ch.textAlign == 'center',
                                                  onTap: () {
                                                    setDialogState(() {
                                                      chaptersList[index] = BookChapter(
                                                        title: chaptersList[index].title,
                                                        content: chaptersList[index].content,
                                                        textAlign: 'center',
                                                      );
                                                    });
                                                  },
                                                ),
                                                _buildAlignIconButton(
                                                  icon: Icons.format_align_right_rounded,
                                                  isSelected: ch.textAlign == 'right',
                                                  onTap: () {
                                                    setDialogState(() {
                                                      chaptersList[index] = BookChapter(
                                                        title: chaptersList[index].title,
                                                        content: chaptersList[index].content,
                                                        textAlign: 'right',
                                                      );
                                                    });
                                                  },
                                                ),
                                                _buildAlignIconButton(
                                                  icon: Icons.format_align_justify_rounded,
                                                  isSelected: ch.textAlign == 'justify',
                                                  onTap: () {
                                                    setDialogState(() {
                                                      chaptersList[index] = BookChapter(
                                                        title: chaptersList[index].title,
                                                        content: chaptersList[index].content,
                                                        textAlign: 'justify',
                                                      );
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            if (chaptersList.length > 1)
                                              GestureDetector(
                                                onTap: () {
                                                  setDialogState(() {
                                                    chaptersList.removeAt(index);
                                                  });
                                                },
                                                child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 20),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Chapter Title
                                        TextFormField(
                                          controller: chTitleController,
                                          decoration: _buildInputDecoration('Judul Bab', 'Misal: Bab 1: Mengenal Luka'),
                                          validator: (val) => val == null || val.trim().isEmpty ? 'Judul bab tidak boleh kosong' : null,
                                          onChanged: (val) {
                                            chaptersList[index] = BookChapter(
                                              title: val,
                                              content: chaptersList[index].content,
                                              textAlign: chaptersList[index].textAlign,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        // Chapter Content
                                        TextFormField(
                                          controller: chContentController,
                                          maxLines: 6,
                                          textAlign: _getTextAlign(ch.textAlign),
                                          decoration: _buildInputDecoration('Konten / Cerita Bab', 'Tulis cerita novel di sini...'),
                                          validator: (val) => val == null || val.trim().isEmpty ? 'Konten bab tidak boleh kosong' : null,
                                          onChanged: (val) {
                                            chaptersList[index] = BookChapter(
                                              title: chaptersList[index].title,
                                              content: val,
                                              textAlign: chaptersList[index].textAlign,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 16),
                    // Action Buttons Footer
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0284C7).withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  final newBookData = BookModel(
                                    id: isEdit ? book.id : '',
                                    title: titleController.text.trim(),
                                    author: authorController.text.trim(),
                                    duration: durationController.text.trim(),
                                    coverColors: selectedColors,
                                    icon: selectedIcon,
                                    chapters: chaptersList,
                                  );

                                  if (isEdit) {
                                    await _dbService.updateBook(newBookData);
                                  } else {
                                    await _dbService.addBook(newBookData);
                                  }

                                  Navigator.pop(dialogCtx);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                isEdit ? 'Simpan Perubahan' : 'Tambah Buku',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
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

  void _showDeleteBookConfirmation(String id, String title) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
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
                // Top Accent Red Line
                Container(
                  height: 6,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.15), width: 1),
                        ),
                        child: const Center(
                          child: Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 26),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Konfirmasi Hapus Buku',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Apakah Anda yakin ingin menghapus buku "$title" dari perpustakaan? Tindakan ini tidak dapat dibatalkan.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                await _dbService.deleteBook(id);
                                Navigator.pop(dialogCtx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'Hapus Buku',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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
        borderSide: const BorderSide(color: Color(0xFF0284C7), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditBookDialog(),
        backgroundColor: const Color(0xFF0284C7),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: StreamBuilder<List<BookModel>>(
        stream: _dbService.getBooksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memuat buku: ${snapshot.error}',
                  style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.library_books_rounded, color: Color(0xFF0284C7), size: 48),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Perpustakaan Kosong',
                      style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A), fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Belum ada buku atau novel yang ditambahkan. Klik tombol "+" di bawah untuk menambahkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final book = books[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Book Cover gradient preview
                      Container(
                        width: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: book.coverColors.map((c) => Color(c)).toList(),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getBookIcon(book.icon),
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      
                      // Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Oleh ${book.author} • ${book.duration}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${book.chapters.length} Bab cerita',
                                style: const TextStyle(
                                  color: Color(0xFF0284C7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Edit and Delete Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Color(0xFF0284C7), size: 20),
                            onPressed: () => _showAddEditBookDialog(book: book),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            onPressed: () => _showDeleteBookConfirmation(book.id, book.title),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
