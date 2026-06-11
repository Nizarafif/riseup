import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diagnostic_provider.dart';
import '../../providers/mood_provider.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../screening/screening_screen.dart';
import '../monitoring/monitoring_screen.dart';
import '../../widgets/mood_theme_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedMoodLevel = 0;
  final _noteController = TextEditingController();
  bool _moodLoggedToday = false;
  int _currentIndex = 0;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user != null) {
        // Cek dan simpan mood awal yang dipilih saat onboarding
        if (authProvider.initialMoodLevel != null && authProvider.initialMoodLevel! > 0) {
          final level = authProvider.initialMoodLevel!;
          Provider.of<MoodProvider>(context, listen: false)
              .addMood(user.uid, level, '')
              .then((success) {
            if (success && mounted) {
              setState(() {
                _moodLoggedToday = true;
              });
            }
          });
          authProvider.setInitialMoodLevel(null);
        }

        Provider.of<DiagnosticProvider>(context, listen: false)
            .loadDiagnosticData(user.uid)
            .then((_) {
          if (mounted) {
            _checkFirstTimeUser();
          }
        });
        Provider.of<MoodProvider>(context, listen: false).fetchMoods(user.uid);
      }
    });
  }

  void _checkFirstTimeUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null && user.role == 'user' && diagnosticProvider.historyList.isEmpty) {
      _showWelcomeTestDialog();
    }
  }

  void _showWelcomeTestDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Selamat Datang!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
              ),
            ],
          ),
          content: const Text(
            'Untuk dapat mendeteksi awal dan memantau kondisi kesehatan mental Anda secara mandiri dengan optimal, sistem pakar kami membutuhkan data analisis awal.\n\nSilakan isi tes kuesioner singkat terlebih dahulu.',
            style: TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF505050)),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<DiagnosticProvider>(context, listen: false).resetScreening();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScreeningScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text(
                'Mulai Tes Sekarang',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitMood() async {
    if (_selectedMoodLevel == 0) return;
    
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final success = await Provider.of<MoodProvider>(context, listen: false).addMood(
      user.uid,
      _selectedMoodLevel,
      _noteController.text,
    );

    if (success && mounted) {
      setState(() {
        _moodLoggedToday = true;
        _noteController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mood harian berhasil dicatat!'),
          backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final user = authProvider.user;
    
    final paletteIdx = authProvider.selectedPaletteIndex;
    final emojiThemeIdx = authProvider.selectedEmojiThemeIndex;

    if (user == null) return const LoginScreen();

    final latestHistory = diagnosticProvider.historyList.isNotEmpty 
        ? diagnosticProvider.historyList.first 
        : null;

    if (user.role == 'admin') {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded, color: Color(0xFF6C63FF), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'RiseUp - Admin',
                style: TextStyle(color: Color(0xFF3F3D56), fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFF3F3D56)),
              onPressed: () {
                authProvider.signOut();
              },
              tooltip: 'Keluar',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${user.name}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F3D56),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Masuk sebagai Pakar/Admin',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF707070),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                    label: const Text('Panel Pakar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final List<Widget> tabs = [
      _buildHomeTab(context, user, paletteIdx, emojiThemeIdx),
      _buildScreeningTab(context, user, latestHistory, diagnosticProvider),
      const MonitoringScreen(isEmbedded: true),
      _buildSettingsTab(context, user, authProvider),
    ];

    String screenTitle = 'RiseUp';
    if (_currentIndex == 1) screenTitle = 'Skrining Gejala';
    if (_currentIndex == 2) screenTitle = 'Pemantauan';
    if (_currentIndex == 3) screenTitle = 'Pengaturan';

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, color: Color(0xFF6C63FF), size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              screenTitle,
              style: const TextStyle(color: Color(0xFF3F3D56), fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF3F3D56)),
            onPressed: () {
              authProvider.signOut();
            },
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: tabs,
          ),
          IgnorePointer(
            ignoring: !_isMenuOpen,
            child: AnimatedOpacity(
              opacity: _isMenuOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => setState(() => _isMenuOpen = false),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      color: Colors.black.withOpacity(0.18),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildFloatingItem(
            icon: Icons.spa_rounded,
            label: 'Napas Lega',
            color: Colors.purple,
            onTap: () {
              setState(() => _isMenuOpen = false);
              _showBreathingGuide();
            },
            isOpen: _isMenuOpen,
            targetBottom: 110,
            targetLeft: screenWidth / 2 - 80 - 60,
            closedBottom: 30,
            closedLeft: screenWidth / 2 - 60,
          ),
          _buildFloatingItem(
            icon: Icons.psychology_rounded,
            label: 'Tes Pakar',
            color: const Color(0xFF00C9A7),
            onTap: () {
              setState(() => _isMenuOpen = false);
              final diagProvider = Provider.of<DiagnosticProvider>(context, listen: false);
              diagProvider.resetScreening();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScreeningScreen()),
              );
            },
            isOpen: _isMenuOpen,
            targetBottom: 110,
            targetLeft: screenWidth / 2 + 80 - 60,
            closedBottom: 30,
            closedLeft: screenWidth / 2 - 60,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 85,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Beranda', const Color(0xFF6C63FF)),
                  _buildNavItem(1, Icons.psychology_outlined, Icons.psychology_rounded, 'Skrining', const Color(0xFF00C9A7)),
                  _buildMiddleAddButton(context),
                  _buildNavItem(2, Icons.analytics_outlined, Icons.analytics_rounded, 'Tren', const Color(0xFFFF9F64)),
                  _buildNavItem(3, Icons.settings_outlined, Icons.settings_rounded, 'Pengaturan', const Color(0xFF9C27B0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData solidIcon, String label, Color themeColor) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? solidIcon : outlineIcon,
                color: isSelected ? themeColor : const Color(0xFF8E8E93),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? themeColor : const Color(0xFF8E8E93),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiddleAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMenuOpen = !_isMenuOpen;
        });
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF8F8AFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: AnimatedRotation(
          turns: _isMenuOpen ? 0.125 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isOpen,
    required double targetBottom,
    required double targetLeft,
    required double closedBottom,
    required double closedLeft,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: isOpen ? Curves.easeOutBack : Curves.easeIn,
      bottom: isOpen ? targetBottom : closedBottom,
      left: isOpen ? targetLeft : closedLeft,
      child: AnimatedScale(
        scale: isOpen ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        curve: isOpen ? Curves.easeOutBack : Curves.easeIn,
        child: AnimatedOpacity(
          opacity: isOpen ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !isOpen,
            child: SizedBox(
              width: 120,
              child: GestureDetector(
                onTap: onTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cute floating bubble with thick white border and shadow
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.85),
                            color,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Dialog-like label bubble
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, UserModel user, int paletteIdx, int emojiThemeIdx) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, ${user.name}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F3D56),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bagaimana kesehatan mentalmu hari ini?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF707070),
            ),
          ),
          const SizedBox(height: 24),
          _buildQuotesCard(),
          const SizedBox(height: 24),
          _buildMoodTrackerCard(paletteIdx, emojiThemeIdx, user),
          const SizedBox(height: 24),
          _buildBreathingCard(),
        ],
      ),
    );
  }

  Widget _buildScreeningTab(BuildContext context, UserModel user, dynamic latestHistory, DiagnosticProvider diagnosticProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sistem Pakar Deteksi Gejala',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Lakukan peninjauan kesehatan mental Anda secara dini.',
            style: TextStyle(fontSize: 14, color: Color(0xFF707070)),
          ),
          const SizedBox(height: 24),
          _buildScreeningMainCard(context, latestHistory, diagnosticProvider),
        ],
      ),
    );
  }

  Widget _buildQuotesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF8F8AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Kutipan Hari Ini',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '"Kesehatan mentalmu adalah prioritas. Menyadari gejala lebih awal adalah langkah bijak."',
                  style: TextStyle(
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
          const Icon(Icons.spa_outlined, color: Colors.white, size: 48),
        ],
      ),
    );
  }

  Widget _buildMoodTrackerCard(int paletteIdx, int emojiThemeIdx, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.03), width: 1.5),
      ),
      child: _moodLoggedToday
          ? Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kamu sudah mencatat mood hari ini. Terima kasih telah peduli pada dirimu!',
                    style: TextStyle(color: Color(0xFF3F3D56), fontWeight: FontWeight.w500),
                  ),
                )
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bagaimana suasana hatimu saat ini?',
                  style: TextStyle(color: Color(0xFF707070), fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMoodEmoji(1, 'Sangat Buruk', paletteIdx, emojiThemeIdx),
                    _buildMoodEmoji(2, 'Buruk', paletteIdx, emojiThemeIdx),
                    _buildMoodEmoji(3, 'Normal', paletteIdx, emojiThemeIdx),
                    _buildMoodEmoji(4, 'Baik', paletteIdx, emojiThemeIdx),
                    _buildMoodEmoji(5, 'Sangat Baik', paletteIdx, emojiThemeIdx),
                  ],
                ),
                if (_selectedMoodLevel > 0) ...[
                  const SizedBox(height: 20),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Ada cerita apa hari ini? (Catatan opsional)',
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitMood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Simpan Catatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ]
              ],
            ),
    );
  }

  Widget _buildBreathingCard() {
    return InkWell(
      onTap: _showBreathingGuide,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.circle_notifications_outlined, color: Colors.purple, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Pemandu Latihan Pernapasan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF3F3D56)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Latihan pernapasan 4-4-4-4 untuk menurunkan kecemasan dalam 1 menit.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF707070), height: 1.3),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildScreeningMainCard(BuildContext context, dynamic latestHistory, DiagnosticProvider diagnosticProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.05), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C9A7).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.psychology_alt_outlined, color: Color(0xFF00C9A7), size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skrining Mandiri',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF3F3D56)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Metode Forward Chaining',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Melalui sistem pakar ini, Anda dapat mendeteksi indikasi awal gangguan kesehatan mental berdasarkan gejala-gejala klinis yang Anda rasakan secara valid.',
            style: TextStyle(fontSize: 13, color: Color(0xFF505050), height: 1.5),
          ),
          if (latestHistory != null) ...[
            const Divider(height: 32),
            const Text(
              'Diagnosis Terakhir Anda:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: latestHistory.diagnosisCode == 'P000'
                    ? Colors.green.withOpacity(0.06)
                    : Colors.red.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: latestHistory.diagnosisCode == 'P000' 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.red.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    latestHistory.hasilDiagnosis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: latestHistory.diagnosisCode == 'P000' ? Colors.green[800] : Colors.red[800],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    latestHistory.deskripsi,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF505050), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                diagnosticProvider.resetScreening();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScreeningScreen()),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: const Text(
                'Mulai Tes Diagnosis',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectReminderTime(BuildContext context, AuthProvider authProvider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: authProvider.selectedReminderTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF3F3D56),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      authProvider.completeReminderSetup(picked);
    }
  }

  Widget _buildSettingsTab(BuildContext context, UserModel user, AuthProvider authProvider) {
    final paletteIdx = authProvider.selectedPaletteIndex;
    final primaryColor = MoodThemeHelper.getMoodColor(paletteIdx, 4);
    final isPremium = authProvider.isPremium;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(color: Colors.black12.withOpacity(0.05), width: 1.5),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: primaryColor.withOpacity(0.15),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryColor),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPremium ? const Color(0xFFFFD54F).withOpacity(0.2) : Colors.grey.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPremium ? '👑 Premium Member' : 'Standard Member',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPremium ? const Color(0xFFB8860B) : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'Kustomisasi & Tema',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.palette_outlined,
            title: 'Kustomisasi Palet Warna & Emoji',
            subtitle: 'Ubah skema warna mood dan emoji Anda',
            onTap: () {
              authProvider.editMoodTheme();
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.wallpaper_rounded,
            title: 'Tema Latar Belakang',
            subtitle: 'Pilih tipe dekorasi latar belakang',
            trailing: DropdownButton<int>(
              value: authProvider.selectedBackgroundThemeIndex,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Doodle', style: TextStyle(fontSize: 13))),
                DropdownMenuItem(value: 1, child: Text('Cairan', style: TextStyle(fontSize: 13))),
                DropdownMenuItem(value: 2, child: Text('Malam', style: TextStyle(fontSize: 13))),
              ],
              onChanged: (val) {
                if (val != null) {
                  authProvider.updateBackgroundTheme(val);
                }
              },
            ),
          ),
          const SizedBox(height: 28),

          const Text(
            'Notifikasi & Sistem',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.access_time_rounded,
            title: 'Waktu Pengingat',
            subtitle: 'Atur jam notifikasi jurnal harian Anda',
            trailing: Text(
              authProvider.selectedReminderTime.format(context),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
            ),
            onTap: () => _selectReminderTime(context, authProvider),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                authProvider.signOut();
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: const Text(
                'Keluar dari Akun',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.005),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
      ),
    );
  }

  Widget _buildMoodEmoji(int level, String label, int paletteIndex, int emojiThemeIndex) {
    bool isSelected = _selectedMoodLevel == level;
    final themeColor = MoodThemeHelper.getMoodColor(paletteIndex, level);
    
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
              color: isSelected ? themeColor : Colors.black45,
            ),
          )
        ],
      ),
    );
  }
}

// Custom Modal Sheet for Breathing Exercise
class BreathingModal extends StatefulWidget {
  const BreathingModal({super.key});

  @override
  State<BreathingModal> createState() => _BreathingModalState();
}

class _BreathingModalState extends State<BreathingModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _guideText = "Tarik Napas";
  int _counter = 4;

  @override
  void initState() {
    super.initState();
    // 16-second box breathing cycle:
    // 4s Inhale, 4s Hold, 4s Exhale, 4s Hold
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    _animation = TweenSequence<double>([
      // Tarik napas: membesar dari 1.0 ke 2.0 (4s)
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.8).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      // Tahan: tetap besar (4s)
      TweenSequenceItem(tween: ConstantTween(1.8), weight: 25),
      // Hembuskan: mengecil kembali ke 1.0 (4s)
      TweenSequenceItem(tween: Tween(begin: 1.8, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      // Tahan: tetap kecil (4s)
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 25),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat();
      }
    });

    _controller.addListener(() {
      final double progress = _controller.value;
      String newText = "Tarik Napas";
      int newSecs = 4;

      if (progress < 0.25) {
        newText = "Tarik Napas";
        newSecs = 4 - ((progress * 16) % 4).floor();
      } else if (progress < 0.50) {
        newText = "Tahan Napas";
        newSecs = 4 - (((progress - 0.25) * 16) % 4).floor();
      } else if (progress < 0.75) {
        newText = "Hembuskan Napas";
        newSecs = 4 - (((progress - 0.50) * 16) % 4).floor();
      } else {
        newText = "Tahan Napas";
        newSecs = 4 - (((progress - 0.75) * 16) % 4).floor();
      }

      if (_guideText != newText || _counter != newSecs) {
        setState(() {
          _guideText = newText;
          _counter = newSecs;
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Latihan Relaksasi Napas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 24),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Ikuti lingkaran pemandu di bawah ini untuk menstabilkan pernapasan dan detak jantung Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
          ),
          const Spacer(),
          
          // Animated breathing circles
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                double val = _animation.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring glow effect
                    Container(
                      height: 120 * val,
                      width: 120 * val,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6C63FF).withOpacity(0.08 * (val - 0.5)),
                      ),
                    ),
                    // Middle ring
                    Container(
                      height: 90 * val,
                      width: 90 * val,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6C63FF).withOpacity(0.15),
                      ),
                    ),
                    // Inner solid circle
                    Container(
                      height: 70 * val,
                      width: 70 * val,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF8F8AFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$_counter',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          Text(
            _guideText,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Teknik Box Breathing (Kotak 4-4-4-4)',
            style: TextStyle(color: Colors.black38, fontSize: 12),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
