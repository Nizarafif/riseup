import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/mood_provider.dart';
import '../../../models/user_model.dart';
import '../../../models/mood_model.dart';
import '../../../widgets/mood_theme_helper.dart';
import '../../../providers/diagnostic_provider.dart';
import 'breathing_modal.dart';
import 'health_banner_carousel.dart';
import '../../auth/widgets/guest_redirect_dialog.dart';

const List<String> mentalHealthQuotes = [
  'Kesehatan mentalmu adalah prioritas. Menyadari gejala lebih awal adalah langkah bijak.',
  'Tidak apa-apa untuk tidak merasa baik-baik saja. Kamu tidak harus berpura-pura kuat sepanjang waktu.',
  'Satu langkah kecil menuju perawatan diri hari ini adalah kemenangan besar bagi mentalmu.',
  'Kesehatan mental bukanlah tujuan akhir, melainkan sebuah perjalanan harian yang patut disyukuri.',
  'Tarik napas dalam-dalam, hembuskan perlahan. Hari ini baru dimulai, dan kamu sanggup menjalaninya.',
  'Mencintai diri sendiri berarti menerima bahwa kamu juga berhak untuk beristirahat dan pulih.',
  'Pikiranmu bisa menjadi tempat yang damai jika kamu memperlakukannya dengan kebaikan dan kesabaran.',
  'Kamu berharga, tidak peduli seberapa berat hari-hari yang sedang kamu lalui saat ini.'
];

class HomeTab extends StatefulWidget {
  final UserModel user;
  const HomeTab({super.key, required this.user});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _selectedMoodLevel = 0;
  final _noteController = TextEditingController();
  bool _moodLoggedToday = false;
  late String _currentQuote;
  DateTime _selectedMoodDate = DateTime.now();
  bool _isAnimatingSimulation = false;
  int _visibleSimulationDays = 0;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _currentQuote = mentalHealthQuotes[math.Random().nextInt(mentalHealthQuotes.length)];
  }

  @override
  void dispose() {
    _noteController.dispose();
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _submitMood() async {
    if (_selectedMoodLevel == 0) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    final diagnosticProvider = Provider.of<DiagnosticProvider>(context, listen: false);
    final isGuest = user.email == 'guest@riseup.com' || user.email.isEmpty || user.name == 'Tamu RiseUp';
    final hasDiagnosis = diagnosticProvider.historyList.isNotEmpty || diagnosticProvider.latestDiagnosis != null;
    if (isGuest && hasDiagnosis) {
      GuestRedirectDialog.show(context);
      return;
    }

    final isAdmin = user.role == 'admin';
    final success = await Provider.of<MoodProvider>(
      context,
      listen: false,
    ).addMood(
      user.uid,
      _selectedMoodLevel,
      _noteController.text,
      date: isAdmin ? _selectedMoodDate : null,
    );

    if (success && mounted) {
      setState(() {
        if (!isAdmin) {
          _moodLoggedToday = true;
        }
        _noteController.clear();
        _selectedMoodLevel = 0;
        _selectedMoodDate = DateTime.now(); // reset date
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mood harian berhasil dicatat!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _simulate30DaysMood() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) return;

    setState(() {
      _selectedMoodLevel = 0; // reset
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menyiapkan data simulasi mood 30 hari...')),
    );

    final random = math.Random();
    
    final sampleNotes = [
      'Hari yang menyenangkan!',
      'Sedikit lelah setelah aktivitas harian.',
      'Sangat produktif hari ini.',
      'Olahraga sore sangat membantu rileks.',
      'Kualitas tidur cukup baik malam tadi.',
      'Menghabiskan waktu membaca buku penenang.',
      'Biasa saja hari ini, tidak ada yang spesial.',
      'Merasa sangat berenergi dan bahagia.',
    ];

    final now = DateTime.now();
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    final List<Map<String, dynamic>> moodDataList = [];
    
    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(now.year, now.month, day, 12, 0);
      final level = random.nextInt(5) + 1;
      final note = sampleNotes[random.nextInt(sampleNotes.length)];
      
      moodDataList.add({
        'date': date,
        'level': level,
        'note': note,
      });
    }

    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final success = await moodProvider.addMoodsBatch(user.uid, moodDataList);

    if (success) {
      setState(() {
        _isAnimatingSimulation = true;
        _visibleSimulationDays = 0;
      });
      _simulationTimer?.cancel();
      _simulationTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _visibleSimulationDays++;
          if (_visibleSimulationDays >= totalDays) {
            timer.cancel();
            _isAnimatingSimulation = false;
          }
        });
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? 'Simulasi data mood 30 hari berhasil dimuat!' 
              : 'Gagal memuat data mood simulasi.'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  void _showBreathingGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BreathingModal(),
    );
  }

  Widget _buildQuotesCard(bool isDarkBg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDarkBg
            ? const LinearGradient(
                colors: [Color(0xFF1A1A3E), Color(0xFF2D2B55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF8F8AFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        border: isDarkBg
            ? Border.all(color: Colors.white.withOpacity(0.1), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: isDarkBg
                ? Colors.black.withOpacity(0.4)
                : const Color(0xFF6C63FF).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kutipan Hari Ini',
                  style: TextStyle(
                    color: isDarkBg ? const Color(0xFF00C9A7) : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"$_currentQuote"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.spa_outlined,
            color: isDarkBg ? const Color(0xFF00C9A7) : Colors.white,
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodEmoji(
    int level,
    String label,
    int paletteIndex,
    int emojiThemeIndex,
    bool isDarkBg,
  ) {
    bool isSelected = _selectedMoodLevel == level;
    final themeColor = MoodThemeHelper.getMoodColor(paletteIndex, level);
    final unselectedColor = isDarkBg ? Colors.white38 : Colors.black45;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMoodLevel = level;
        });
      },
      child: Column(
        children: [
          MoodEmojiWidget(
            level: level,
            size: isSelected ? 48 : 38,
            paletteIndex: paletteIndex,
            emojiThemeIndex: emojiThemeIndex,
            isSelected: isSelected,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? themeColor : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTrackerCard(
    int paletteIdx,
    int emojiThemeIdx,
    UserModel user,
    bool isDarkBg,
  ) {
    final cardBg = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final textColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleColor = isDarkBg ? Colors.white70 : const Color(0xFF707070);
    final borderColor = isDarkBg
        ? Colors.white10
        : const Color(0xFF6C63FF).withOpacity(0.03);
    final moodProvider = Provider.of<MoodProvider>(context);
    final isAdmin = widget.user.role == 'admin';
    final isMoodLogged = (_moodLoggedToday || moodProvider.hasLoggedMoodToday) && !isAdmin;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkBg ? 0.25 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: isMoodLogged
          ? Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kamu sudah mencatat mood hari ini. Terima kasih telah peduli pada dirimu!',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bagaimana suasana hatimu saat ini?',
                  style: TextStyle(color: subtitleColor, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMoodEmoji(
                      1,
                      'Sangat Buruk',
                      paletteIdx,
                      emojiThemeIdx,
                      isDarkBg,
                    ),
                    _buildMoodEmoji(
                      2,
                      'Buruk',
                      paletteIdx,
                      emojiThemeIdx,
                      isDarkBg,
                    ),
                    _buildMoodEmoji(
                      3,
                      'Normal',
                      paletteIdx,
                      emojiThemeIdx,
                      isDarkBg,
                    ),
                    _buildMoodEmoji(
                      4,
                      'Baik',
                      paletteIdx,
                      emojiThemeIdx,
                      isDarkBg,
                    ),
                    _buildMoodEmoji(
                      5,
                      'Sangat Baik',
                      paletteIdx,
                      emojiThemeIdx,
                      isDarkBg,
                    ),
                  ],
                ),
                if (_selectedMoodLevel > 0) ...[
                  const SizedBox(height: 20),
                  TextField(
                    controller: _noteController,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ada cerita apa hari ini? (Catatan opsional)',
                      hintStyle: TextStyle(fontSize: 13, color: subtitleColor),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: isDarkBg
                          ? Colors.white.withOpacity(0.05)
                          : Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkBg ? Colors.white24 : Colors.black12,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6C63FF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tanggal Entri: ${DateFormat('dd MMMM yyyy').format(_selectedMoodDate)}',
                          style: TextStyle(color: subtitleColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedMoodDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 31)),
                              builder: (context, child) {
                                return Theme(
                                  data: isDarkBg
                                      ? ThemeData.dark().copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Color(0xFF6C63FF),
                                            onPrimary: Colors.white,
                                            surface: Color(0xFF1E1E38),
                                            onSurface: Colors.white,
                                          ),
                                          dialogBackgroundColor: const Color(0xFF1E1E38),
                                        )
                                      : ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: const Color(0xFF6C63FF),
                                            onPrimary: Colors.white,
                                            onSurface: textColor,
                                          ),
                                        ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedMoodDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF6C63FF)),
                          label: const Text(
                            'Ubah Tanggal',
                            style: TextStyle(color: Color(0xFF6C63FF), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitMood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Catatan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _simulate30DaysMood,
                        icon: const Icon(Icons.bolt_rounded, size: 16, color: Colors.amber),
                        label: const Text(
                          'Simulasikan Mood 30 Hari',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber[800],
                          side: const BorderSide(color: Colors.amber, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
    );
  }

  Widget _buildBreathingCard(bool isDarkBg) {
    final cardBg = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final titleColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleColor = isDarkBg ? Colors.white60 : const Color(0xFF707070);
    final arrowColor = isDarkBg ? Colors.white30 : Colors.black26;
    final borderColor = isDarkBg
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFF6C63FF).withOpacity(0.15);

    return InkWell(
      onTap: () {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;
        if (user != null) {
          final diagnosticProvider = Provider.of<DiagnosticProvider>(context, listen: false);
          final isGuest = user.email == 'guest@riseup.com' || user.email.isEmpty || user.name == 'Tamu RiseUp';
          final hasDiagnosis = diagnosticProvider.historyList.isNotEmpty || diagnosticProvider.latestDiagnosis != null;
          if (isGuest && hasDiagnosis) {
            GuestRedirectDialog.show(context);
            return;
          }
        }
        _showBreathingGuide();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkBg ? 0.25 : 0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(isDarkBg ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.circle_notifications_outlined,
                color: isDarkBg ? Colors.purpleAccent : Colors.purple,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pemandu Latihan Pernapasan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Latihan pernapasan 4-4-4-4 untuk menurunkan kecemasan dalam 1 menit.',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: arrowColor, size: 16),
          ],
        ),
      ),
    );
  }

  void _showMoodDetail(
    BuildContext context,
    MoodModel mood,
    int paletteIdx,
    int emojiThemeIdx,
    bool isDarkBg,
  ) {
    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dateStr = '${mood.tanggal.day} ${monthNames[mood.tanggal.month - 1]} ${mood.tanggal.year}';
    final dialogBgColor = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final textColor = isDarkBg ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDarkBg ? Colors.white70 : const Color(0xFF64748B);
    
    final moodColor = MoodThemeHelper.getMoodColor(paletteIdx, mood.moodLevel);
    final buttonTextColor = moodColor.computeLuminance() > 0.5 ? const Color(0xFF1F2937) : Colors.white;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: dialogBgColor,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: subtitleColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: subtitleColor,
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                MoodEmojiWidget(
                  level: mood.moodLevel,
                  size: 64,
                  paletteIndex: paletteIdx,
                  emojiThemeIndex: emojiThemeIdx,
                  isSelected: true,
                ),
                const SizedBox(height: 12),
                Text(
                  MoodThemeHelper.getMoodName(mood.moodLevel),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: moodColor,
                  ),
                ),
                if (mood.catatan != null && mood.catatan!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkBg ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkBg ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      mood.catatan!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: moodColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      'Tutup',
                      style: TextStyle(color: buttonTextColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoodCalendarCard(
    int paletteIdx,
    int emojiThemeIdx,
    bool isDarkBg,
  ) {
    final cardBg = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final textColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleColor = isDarkBg ? Colors.white70 : const Color(0xFF707070);
    final borderColor = isDarkBg
        ? Colors.white10
        : const Color(0xFF6C63FF).withOpacity(0.03);

    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final monthName = '${monthNames[month - 1]} $year';

    final firstDayOfMonth = DateTime(year, month, 1);
    final startWeekday = firstDayOfMonth.weekday - 1; // 0 for Monday, 6 for Sunday
    final totalDays = DateTime(year, month + 1, 0).day;

    final moods = Provider.of<MoodProvider>(context).moods;
    final Map<int, MoodModel> moodMap = {};
    for (final mood in moods) {
      final date = mood.tanggal;
      if (date.year == year && date.month == month) {
        if (_isAnimatingSimulation) {
          if (date.day <= _visibleSimulationDays) {
            moodMap[date.day] = mood;
          }
        } else {
          moodMap[date.day] = mood;
        }
      }
    }

    final daysOfWeek = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkBg ? 0.25 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kalender Mood',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              Text(
                monthName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: const Color(0xFF6C63FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek.map((day) {
              return SizedBox(
                width: 32,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: subtitleColor,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: startWeekday + totalDays,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
             itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox();
              }
              final day = index - startWeekday + 1;
              final hasMood = moodMap.containsKey(day);
              final isToday = day == now.day;

              Color cellColor = isDarkBg ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9);
              Color textCellColor = isDarkBg ? Colors.white70 : const Color(0xFF475569);
              BoxBorder? border;

              if (isToday) {
                border = Border.all(
                  color: const Color(0xFF6C63FF),
                  width: 2,
                );
              }

              return GestureDetector(
                onTap: hasMood
                    ? () => _showMoodDetail(context, moodMap[day]!, paletteIdx, emojiThemeIdx, isDarkBg)
                    : null,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hasMood ? Colors.transparent : cellColor,
                    shape: BoxShape.circle,
                    border: border,
                  ),
                  child: hasMood
                      ? ShiftingMoodEmojiWidget(
                          targetLevel: moodMap[day]!.moodLevel,
                          size: 34,
                          paletteIndex: paletteIdx,
                          emojiThemeIndex: emojiThemeIdx,
                          shouldShift: _isAnimatingSimulation && day == _visibleSimulationDays,
                        )
                      : Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: textCellColor,
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final paletteIdx = authProvider.selectedPaletteIndex;
    final emojiThemeIdx = authProvider.selectedEmojiThemeIndex;
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;

    final quotesList = diagnosticProvider.motivations.isNotEmpty 
        ? diagnosticProvider.motivations 
        : mentalHealthQuotes;

    if (!quotesList.contains(_currentQuote)) {
      _currentQuote = quotesList[math.Random().nextInt(quotesList.length)];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, ${widget.user.name}!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkBg ? Colors.white : const Color(0xFF3F3D56),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bagaimana kesehatan mentalmu hari ini?',
            style: TextStyle(
              fontSize: 14,
              color: isDarkBg ? Colors.white70 : const Color(0xFF707070),
            ),
          ),
          const SizedBox(height: 24),
          _buildQuotesCard(isDarkBg),
          const SizedBox(height: 24),
          HealthBannerCarousel(isDarkBg: isDarkBg),
          const SizedBox(height: 24),
          _buildMoodTrackerCard(paletteIdx, emojiThemeIdx, widget.user, isDarkBg),
          const SizedBox(height: 24),
          _buildMoodCalendarCard(paletteIdx, emojiThemeIdx, isDarkBg),
          const SizedBox(height: 24),
          _buildBreathingCard(isDarkBg),
        ],
      ),
    );
  }
}

class ShiftingMoodEmojiWidget extends StatefulWidget {
  final int targetLevel;
  final double size;
  final int paletteIndex;
  final int emojiThemeIndex;
  final bool shouldShift;

  const ShiftingMoodEmojiWidget({
    super.key,
    required this.targetLevel,
    required this.size,
    required this.paletteIndex,
    required this.emojiThemeIndex,
    required this.shouldShift,
  });

  @override
  State<ShiftingMoodEmojiWidget> createState() => _ShiftingMoodEmojiWidgetState();
}

class _ShiftingMoodEmojiWidgetState extends State<ShiftingMoodEmojiWidget> {
  late int _currentLevel;
  Timer? _timer;
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.shouldShift ? (math.Random().nextInt(5) + 1) : widget.targetLevel;
    _settled = !widget.shouldShift;
    
    if (widget.shouldShift) {
      int count = 0;
      _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        count++;
        if (count >= 5) {
          timer.cancel();
          setState(() {
            _currentLevel = widget.targetLevel;
            _settled = true;
          });
        } else {
          setState(() {
            _currentLevel = (math.Random().nextInt(5) + 1);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('${widget.targetLevel}_${widget.shouldShift}_$_settled'),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: MoodEmojiWidget(
            level: _currentLevel,
            size: widget.size,
            paletteIndex: widget.paletteIndex,
            emojiThemeIndex: widget.emojiThemeIndex,
            isSelected: false,
          ),
        );
      },
    );
  }
}
