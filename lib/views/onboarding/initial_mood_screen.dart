import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/mood_theme_helper.dart';
import '../auth/widgets/doodle_background.dart';

class InitialMoodScreen extends StatefulWidget {
  const InitialMoodScreen({super.key});

  @override
  State<InitialMoodScreen> createState() => _InitialMoodScreenState();
}

class _InitialMoodScreenState extends State<InitialMoodScreen> {
  DateTime _selectedDateTime = DateTime.now();
  int _selectedMoodLevel = 0; // 0 berarti belum dipilih

  void _proceedToLogin() {
    Provider.of<AuthProvider>(context, listen: false).completeInitialMoodSetup();
  }

  void _goBack() {
    Provider.of<AuthProvider>(context, listen: false).resetInitialMoodSetup();
  }

  /// Memformat Tanggal seperti "Hari Ini, 10 Juni"
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) {
      return 'Hari Ini, ${DateFormat('d MMMM', 'id_ID').format(date)}';
    }
    return DateFormat('EEEE, d MMMM', 'id_ID').format(date);
  }

  /// Memformat Waktu seperti "21.34"
  String _formatTime(DateTime date) {
    return DateFormat('HH.mm').format(date);
  }

  /// Mendapatkan Label Bahasa Indonesia yang Sesuai dengan Emoji
  String _getMoodLabel(int level) {
    switch (level) {
      case 5:
        return 'Keren';
      case 4:
        return 'Baik';
      case 3:
        return 'Biasa';
      case 2:
        return 'Buruk';
      case 1:
        return 'Sangat Buruk';
      default:
        return 'Biasa';
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00C9A7),
              onPrimary: Colors.white,
              surface: Color(0xFF16162D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00C9A7),
              onPrimary: Colors.white,
              surface: Color(0xFF16162D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _selectMood(int level) {
    setState(() {
      _selectedMoodLevel = level;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Simpan pilihan level mood awal ke AuthProvider
    authProvider.setInitialMoodLevel(level);

    // Berikan delay sedikit (500ms) untuk feedback visual sentuhan sebelum berpindah halaman
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _proceedToLogin();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final paletteIdx = authProvider.selectedPaletteIndex;
    final emojiThemeIdx = authProvider.selectedEmojiThemeIndex;

    return Scaffold(
      body: DoodleBackground(
        themeIndexOverride: 2, // Paksa tema gelap premium (Starry Night)
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header (Tombol Kembali & Tombol Close X)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: _goBack,
                          tooltip: 'Kembali',
                        ),
                        // Tombol Close X dengan lingkaran transparan (Berfungsi melompati tanpa pilih mood)
                        InkWell(
                          onTap: _proceedToLogin,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white12, width: 1),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 2. Pertanyaan Utama
                  const Text(
                    'Bagaimana kabarmu sekarang?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Tombol Pemilih Tanggal & Waktu (Interaktif)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pemilih Tanggal
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined, color: Color(0xFF00C9A7), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(_selectedDateTime),
                                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: Colors.white38, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Pemilih Waktu
                      GestureDetector(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, color: Color(0xFF00C9A7), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                _formatTime(_selectedDateTime),
                                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: Colors.white38, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // 4. Baris Emoticon (Level 5 s.d 1 dari Kiri ke Kanan mengikuti referensi gambar)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMoodItem(5, 'keren', paletteIdx, emojiThemeIdx),
                        _buildMoodItem(4, 'baik', paletteIdx, emojiThemeIdx),
                        _buildMoodItem(3, 'biasa', paletteIdx, emojiThemeIdx),
                        _buildMoodItem(2, 'buruk', paletteIdx, emojiThemeIdx),
                        _buildMoodItem(1, 'sangat buruk', paletteIdx, emojiThemeIdx),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Tooltip "Pilih moodmu..." (Balon teks dengan segitiga kecil di atas)
                  Center(
                    child: Column(
                      children: [
                        // Segitiga kecil mengarah ke atas
                        CustomPaint(
                          size: const Size(16, 8),
                          painter: TooltipTrianglePainter(),
                        ),
                        // Balon teks utama
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: Text(
                            _selectedMoodLevel > 0
                                ? 'Memilih: ${_getMoodLabel(_selectedMoodLevel)}...'
                                : 'Pilih moodmu...',
                            style: const TextStyle(
                              color: Color(0xFF2C2C2C),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),

                  // 6. Tombol "Edit Mood" di pojok kanan bawah
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0, bottom: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Opsi edit mood bisa dipetakan ke alur pengaturan palet ulang
                            authProvider.editMoodTheme();
                          },
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF00C9A7), size: 18),
                          label: const Text(
                            'Edit Mood',
                            style: TextStyle(
                              color: Color(0xFF00C9A7),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            backgroundColor: Colors.white.withOpacity(0.04),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: const Color(0xFF00C9A7).withOpacity(0.2)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodItem(int level, String label, int paletteIndex, int emojiThemeIndex) {
    final isSelected = _selectedMoodLevel == level;
    final themeColor = MoodThemeHelper.getMoodColor(paletteIndex, level);

    return GestureDetector(
      onTap: () => _selectMood(level),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.25 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: MoodEmojiWidget(
              level: level,
              size: 52,
              paletteIndex: paletteIndex,
              emojiThemeIndex: emojiThemeIndex,
              isSelected: isSelected,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? themeColor : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter untuk menggambar segitiga kecil pada tooltip penunjuk mood
class TooltipTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
