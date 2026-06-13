import 'dart:ui' show ImageFilter;
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diagnostic_provider.dart';
import '../../providers/mood_provider.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../screening/screening_screen.dart';
import '../monitoring/monitoring_screen.dart';
import '../../widgets/mood_theme_helper.dart';
import '../onboarding/palette_setup_screen.dart';
import '../auth/widgets/doodle_background.dart';

class AvatarData {
  final String emoji;
  final List<Color> gradientColors;
  const AvatarData(this.emoji, this.gradientColors);
}

const List<AvatarData> presetAvatars = [
  AvatarData('😊', [Color(0xFF80EE98), Color(0xFF46CDCF)]), // Happy face / teal
  AvatarData('🌸', [Color(0xFFFEC8D8), Color(0xFFD291BC)]), // Cherry blossom / pink/purple
  AvatarData('⭐', [Color(0xFFFFE57F), Color(0xFFFFD54F)]), // Star / yellow
  AvatarData('☁️', [Color(0xFFBAE6FD), Color(0xFF38BDF8)]), // Cloud / sky blue
  AvatarData('🍃', [Color(0xFFA7F3D0), Color(0xFF059669)]), // Leaf / emerald
  AvatarData('🐱', [Color(0xFFFFD1A9), Color(0xFFFF9E79)]), // Cat / orange
  AvatarData('🌟', [Color(0xFFFFF176), Color(0xFFF57F17)]), // Glowing Star / deep gold
  AvatarData('🌈', [Color(0xFFFFD1D1), Color(0xFFD1E8E2)]), // Rainbow / pastel multi
  AvatarData('🧸', [Color(0xFFE2B4BD), Color(0xFF9B5DE5)]), // Teddy Bear / soft purple
  AvatarData('🦊', [Color(0xFFFFE3E3), Color(0xFFFF7043)]), // Fox / coral red
  AvatarData('☕', [Color(0xFFD7CCC8), Color(0xFF8D6E63)]), // Coffee cup / warm brown
  AvatarData('🎨', [Color(0xFFE1BEE7), Color(0xFF8E24AA)]), // Palette / violet
];

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
  DateTime? _lastPressedAt;

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:')) {
      return NetworkImage(path);
    }
    if (kIsWeb) {
      return NetworkImage(path);
    } else {
      return FileImage(io.File(path));
    }
  }

  Future<bool> _onWillPop() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    // Jika pengguna adalah non-admin dan tidak di tab pertama (Beranda),
    // alihkan ke tab Beranda terlebih dahulu sebelum keluar.
    if (user != null && user.role != 'admin' && _currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }

    final now = DateTime.now();
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    final snackBarBgColor = isDarkBg ? const Color(0xFF1E1E38) : const Color(0xFF3F3D56);
    final borderSide = isDarkBg ? const BorderSide(color: Colors.white10, width: 1) : BorderSide.none;

    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.exit_to_app_rounded, color: Color(0xFF00C9A7), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ketuk sekali lagi atau geser kembali untuk keluar aplikasi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderSide,
          ),
          backgroundColor: snackBarBgColor.withOpacity(0.95),
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        ),
      );
      return false;
    }
    return true;
  }

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
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
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
      ),
    );
    }

    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;

    final List<Widget> tabs = [
      _buildHomeTab(context, user, paletteIdx, emojiThemeIdx, isDarkBg),
      _buildScreeningTab(context, user, latestHistory, diagnosticProvider, isDarkBg),
      const MonitoringScreen(isEmbedded: true),
      _buildSettingsTab(context, user, authProvider),
    ];

    String screenTitle = 'RiseUp';
    if (_currentIndex == 1) screenTitle = 'Skrining Gejala';
    if (_currentIndex == 2) screenTitle = 'Pemantauan';
    if (_currentIndex == 3) screenTitle = 'Pengaturan';

    final double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: DoodleBackground(
        child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: isDarkBg ? Colors.transparent : Colors.white.withOpacity(0.9),
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkBg ? Colors.white.withOpacity(0.12) : const Color(0xFF6C63FF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_rounded, 
                  color: isDarkBg ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF), 
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                screenTitle,
                style: TextStyle(
                  color: isDarkBg ? Colors.white : const Color(0xFF3F3D56), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 20,
                ),
              ),
            ],
          ),
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
            color: isDarkBg
                ? const Color(0xFF1A1A3E).withOpacity(0.92)
                : Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDarkBg
                  ? Colors.white.withOpacity(0.12)
                  : Colors.white.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkBg
                    ? Colors.black.withOpacity(0.35)
                    : const Color(0xFF6C63FF).withOpacity(0.08),
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
                  _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Beranda', isDarkBg ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF)),
                  _buildNavItem(1, Icons.psychology_outlined, Icons.psychology_rounded, 'Skrining', const Color(0xFF00C9A7)),
                  _buildMiddleAddButton(context),
                  _buildNavItem(2, Icons.analytics_outlined, Icons.analytics_rounded, 'Tren', isDarkBg ? const Color(0xFFFF9F64) : const Color(0xFFFF9F64)),
                  _buildNavItem(3, Icons.settings_outlined, Icons.settings_rounded, 'Pengaturan', isDarkBg ? const Color(0xFFB39DDB) : const Color(0xFF9C27B0)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
  );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData solidIcon, String label, Color themeColor) {
    final isSelected = _currentIndex == index;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    final unselectedColor = isDarkBg ? Colors.white38 : const Color(0xFF8E8E93);
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
                color: isSelected ? themeColor : unselectedColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? themeColor : unselectedColor,
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

  Widget _buildHomeTab(BuildContext context, UserModel user, int paletteIdx, int emojiThemeIdx, bool isDarkBg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, ${user.name}!',
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
          _buildMoodTrackerCard(paletteIdx, emojiThemeIdx, user, isDarkBg),
          const SizedBox(height: 24),
          _buildBreathingCard(isDarkBg),
        ],
      ),
    );
  }

  Widget _buildScreeningTab(BuildContext context, UserModel user, dynamic latestHistory, DiagnosticProvider diagnosticProvider, bool isDarkBg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sistem Pakar Deteksi Gejala',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkBg ? Colors.white : const Color(0xFF3F3D56)),
          ),
          const SizedBox(height: 4),
          Text(
            'Lakukan peninjauan kesehatan mental Anda secara dini.',
            style: TextStyle(fontSize: 14, color: isDarkBg ? Colors.white70 : const Color(0xFF707070)),
          ),
          const SizedBox(height: 24),
          _buildScreeningMainCard(context, latestHistory, diagnosticProvider, isDarkBg),
        ],
      ),
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
          )
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
                const Text(
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
          Icon(
            Icons.spa_outlined,
            color: isDarkBg ? const Color(0xFF00C9A7) : Colors.white,
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTrackerCard(int paletteIdx, int emojiThemeIdx, UserModel user, bool isDarkBg) {
    final cardBg = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final textColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleColor = isDarkBg ? Colors.white70 : const Color(0xFF707070);
    final borderColor = isDarkBg ? Colors.white10 : const Color(0xFF6C63FF).withOpacity(0.03);

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
          )
        ],
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: _moodLoggedToday
          ? Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kamu sudah mencatat mood hari ini. Terima kasih telah peduli pada dirimu!',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                  ),
                )
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
                    _buildMoodEmoji(1, 'Sangat Buruk', paletteIdx, emojiThemeIdx, isDarkBg),
                    _buildMoodEmoji(2, 'Buruk', paletteIdx, emojiThemeIdx, isDarkBg),
                    _buildMoodEmoji(3, 'Normal', paletteIdx, emojiThemeIdx, isDarkBg),
                    _buildMoodEmoji(4, 'Baik', paletteIdx, emojiThemeIdx, isDarkBg),
                    _buildMoodEmoji(5, 'Sangat Baik', paletteIdx, emojiThemeIdx, isDarkBg),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: isDarkBg ? Colors.white.withOpacity(0.05) : Colors.transparent,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkBg ? Colors.white24 : Colors.black12,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
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

  Widget _buildBreathingCard(bool isDarkBg) {
    final cardBg = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final titleColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleColor = isDarkBg ? Colors.white60 : const Color(0xFF707070);
    final arrowColor = isDarkBg ? Colors.white30 : Colors.black26;
    final borderColor = isDarkBg
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFF6C63FF).withOpacity(0.15);

    return InkWell(
      onTap: _showBreathingGuide,
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
            )
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: titleColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Latihan pernapasan 4-4-4-4 untuk menurunkan kecemasan dalam 1 menit.',
                    style: TextStyle(fontSize: 12, color: subtitleColor, height: 1.3),
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

  Widget _buildScreeningMainCard(BuildContext context, dynamic latestHistory, DiagnosticProvider diagnosticProvider, bool isDarkBg) {
    final cardBg = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final titleColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final bodyColor = isDarkBg ? Colors.white70 : const Color(0xFF505050);
    final borderColor = isDarkBg
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFF6C63FF).withOpacity(0.05);
    final dividerColor = isDarkBg ? Colors.white12 : Colors.black12;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkBg ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDarkBg ? 0.15 : 0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C9A7).withOpacity(isDarkBg ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.psychology_alt_outlined, color: Color(0xFF00C9A7), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skrining Mandiri',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: titleColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Metode Forward Chaining',
                      style: TextStyle(fontSize: 12, color: isDarkBg ? Colors.white54 : Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Melalui sistem pakar ini, Anda dapat mendeteksi indikasi awal gangguan kesehatan mental berdasarkan gejala-gejala klinis yang Anda rasakan secara valid.',
            style: TextStyle(fontSize: 13, color: bodyColor, height: 1.5),
          ),
          if (latestHistory != null) ...[
            Divider(height: 32, color: dividerColor),
            Text(
              'Diagnosis Terakhir Anda:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDarkBg ? Colors.white54 : Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: latestHistory.diagnosisCode == 'P000'
                    ? Colors.green.withOpacity(isDarkBg ? 0.12 : 0.06)
                    : Colors.red.withOpacity(isDarkBg ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: latestHistory.diagnosisCode == 'P000'
                      ? Colors.green.withOpacity(isDarkBg ? 0.25 : 0.1)
                      : Colors.red.withOpacity(isDarkBg ? 0.25 : 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    latestHistory.hasilDiagnosis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: latestHistory.diagnosisCode == 'P000'
                          ? (isDarkBg ? Colors.greenAccent : Colors.green[800])
                          : (isDarkBg ? Colors.redAccent : Colors.red[800]),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    latestHistory.deskripsi,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: bodyColor, height: 1.4),
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

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(text: authProvider.user?.name ?? '');
    final photoUrlController = TextEditingController(text: authProvider.user?.photoUrl ?? '');
    int selectedAvatarIndex = authProvider.user?.avatarIndex ?? 0;
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
            final textColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
            final subtitleColor = isDarkBg ? Colors.white70 : const Color(0xFF707070);
            
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkBg ? const Color(0xFF16162D) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isDarkBg ? Colors.white24 : Colors.black12,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Ubah Profil',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Pilih Avatar Bawaan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: presetAvatars.length,
                          itemBuilder: (context, idx) {
                            final isSelected = selectedAvatarIndex == idx && photoUrlController.text.trim().isEmpty;
                            final avatar = presetAvatars[idx];
                            
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedAvatarIndex = idx;
                                  photoUrlController.clear();
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 56,
                                height: 56,
                                margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: avatar.gradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF6C63FF).withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          )
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                ),
                                child: Center(
                                  child: Text(
                                    avatar.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Foto Profil Kustom',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: isDarkBg ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FD),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: photoUrlController.text.trim().isNotEmpty
                                    ? const Color(0xFF6C63FF)
                                    : Colors.transparent,
                                width: 2,
                              ),
                              image: photoUrlController.text.trim().isNotEmpty
                                  ? DecorationImage(
                                      image: _getImageProvider(photoUrlController.text.trim()),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: photoUrlController.text.trim().isEmpty
                                ? Icon(
                                    Icons.no_photography_outlined,
                                    color: textColor.withOpacity(0.4),
                                    size: 24,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final ImagePicker picker = ImagePicker();
                                    final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 85,
                                    );
                                    if (image != null) {
                                      setModalState(() {
                                        photoUrlController.text = image.path;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.photo_library_rounded, size: 16),
                                  label: const Text(
                                    'Pilih dari Galeri',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C63FF).withOpacity(0.12),
                                    foregroundColor: const Color(0xFF6C63FF),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                                if (photoUrlController.text.trim().isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  TextButton.icon(
                                    onPressed: () {
                                      setModalState(() {
                                        photoUrlController.clear();
                                      });
                                    },
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                                    label: const Text(
                                      'Hapus Foto Kustom',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nama Pengguna',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameController,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Nama Lengkap',
                          hintStyle: TextStyle(color: subtitleColor.withOpacity(0.6), fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          filled: true,
                          fillColor: isDarkBg ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FD),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: isDarkBg ? Colors.white10 : Colors.black.withOpacity(0.04),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF6C63FF),
                              width: 1.8,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          if (value.trim().length < 2) {
                            return 'Nama minimal terdiri dari 2 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSaving ? null : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDarkBg ? Colors.white30 : Colors.grey.withOpacity(0.3),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        setModalState(() {
                                          isSaving = true;
                                        });
                                        
                                        final success = await authProvider.updateProfile(
                                          nameController.text.trim(),
                                          selectedAvatarIndex,
                                          photoUrlController.text.trim(),
                                        );
                                        
                                        if (success) {
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Profil berhasil diperbarui!'),
                                                backgroundColor: Color(0xFF00C9A7),
                                              ),
                                            );
                                          }
                                        } else {
                                          setModalState(() {
                                            isSaving = false;
                                          });
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Gagal memperbarui profil.'),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Simpan',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
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
      },
    );
  }

  Widget _buildSettingsTab(BuildContext context, UserModel user, AuthProvider authProvider) {
    final paletteIdx = authProvider.selectedPaletteIndex;
    final primaryColor = MoodThemeHelper.getMoodColor(paletteIdx, 4);
    final isPremium = authProvider.isPremium;
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showEditProfileDialog(context, authProvider),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkBg ? const Color(0xFF1E1E38) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
                border: Border.all(
                  color: isDarkBg ? Colors.white10 : Colors.black12.withOpacity(0.05),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  user.photoUrl.isNotEmpty
                      ? Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDarkBg ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ],
                            image: DecorationImage(
                              image: _getImageProvider(user.photoUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: presetAvatars[user.avatarIndex].gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: presetAvatars[user.avatarIndex].gradientColors[0].withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              presetAvatars[user.avatarIndex].emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkBg ? Colors.white : const Color(0xFF3F3D56),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkBg ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPremium
                                ? const Color(0xFFFFD54F).withOpacity(0.2)
                                : isDarkBg
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.grey.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPremium ? '👑 Premium Member' : 'Standard Member',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPremium
                                  ? const Color(0xFFFFD54F)
                                  : isDarkBg
                                      ? Colors.white70
                                      : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'Kustomisasi & Tema',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkBg ? Colors.white38 : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context: context,
            icon: Icons.palette_outlined,
            title: 'Kustomisasi Palet Warna & Emoji',
            subtitle: 'Ubah skema warna mood dan emoji Anda',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PaletteSetupScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context: context,
            icon: Icons.wallpaper_rounded,
            title: 'Tema Latar Belakang',
            subtitle: 'Pilih tipe dekorasi latar belakang',
            trailing: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: isDarkBg ? const Color(0xFF1E1E38) : Colors.white,
              ),
              child: DropdownButton<int>(
                value: authProvider.selectedBackgroundThemeIndex,
                underline: const SizedBox.shrink(),
                dropdownColor: isDarkBg ? const Color(0xFF1E1E38) : Colors.white,
                iconEnabledColor: isDarkBg ? Colors.white70 : const Color(0xFF3F3D56),
                style: TextStyle(
                  color: isDarkBg ? Colors.white : const Color(0xFF3F3D56),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                items: [
                  DropdownMenuItem(value: 0, child: Text('Doodle', style: TextStyle(color: isDarkBg ? Colors.white : const Color(0xFF3F3D56)))),
                  DropdownMenuItem(value: 1, child: Text('Cairan', style: TextStyle(color: isDarkBg ? Colors.white : const Color(0xFF3F3D56)))),
                  DropdownMenuItem(value: 2, child: Text('Malam', style: TextStyle(color: isDarkBg ? Colors.white : const Color(0xFF3F3D56)))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    authProvider.updateBackgroundTheme(val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            'Notifikasi & Sistem',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkBg ? Colors.white38 : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingsTile(
            context: context,
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
                    final dialogBgColor = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
                    final titleTextColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
                    final subtitleTextColor = isDarkBg ? Colors.white70 : const Color(0xFF707070);

                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Container(
                        decoration: BoxDecoration(
                          color: dialogBgColor,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDarkBg ? Colors.white10 : Colors.black.withOpacity(0.05),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDarkBg ? 0.4 : 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.logout_rounded, 
                                  color: Colors.redAccent, 
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Keluar dari RiseUp?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: titleTextColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sesi Anda akan berakhir. Tapi tenang, seluruh riwayat jurnal dan monitoring Anda tetap tersimpan dengan aman.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtitleTextColor,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: isDarkBg ? Colors.white12 : Colors.black12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Text(
                                          'Batal',
                                          style: TextStyle(
                                            color: isDarkBg ? Colors.white70 : const Color(0xFF505050),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          authProvider.signOut();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: const Text(
                                          'Keluar',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
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
                    );
                  },
                );
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
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkBg ? const Color(0xFF1E1E38) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkBg ? Colors.white10 : Colors.black.withOpacity(0.03),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkBg ? 0.2 : 0.005),
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
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold, 
            color: isDarkBg ? Colors.white : const Color(0xFF3F3D56),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11, 
            color: isDarkBg ? Colors.white70 : Colors.grey,
          ),
        ),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 12, color: isDarkBg ? Colors.white70 : Colors.grey),
      ),
    );
  }

  Widget _buildMoodEmoji(int level, String label, int paletteIndex, int emojiThemeIndex, bool isDarkBg) {
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    final bgColor = isDarkBg ? const Color(0xFF16162D) : Colors.white;
    final titleColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleColor = isDarkBg ? Colors.white54 : Colors.grey;
    final guideTextColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final techTextColor = isDarkBg ? Colors.white38 : Colors.black38;
    final closeIconColor = isDarkBg ? Colors.white70 : Colors.black54;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: isDarkBg
            ? Border.all(color: Colors.white.withOpacity(0.08), width: 1)
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latihan Relaksasi Napas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, size: 24, color: closeIconColor),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Ikuti lingkaran pemandu di bawah ini untuk menstabilkan pernapasan dan detak jantung Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: subtitleColor, fontSize: 13, height: 1.4),
          ),
          const Spacer(),

          // Animated breathing circles
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                double val = _animation.value;
                final ringColor = isDarkBg ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF);
                final gradientColors = isDarkBg
                    ? [const Color(0xFF00C9A7), const Color(0xFF0088A9)]
                    : [const Color(0xFF6C63FF), const Color(0xFF8F8AFF)];
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring glow effect
                    Container(
                      height: 120 * val,
                      width: 120 * val,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ringColor.withOpacity(0.08 * (val - 0.5).clamp(0, 1)),
                      ),
                    ),
                    // Middle ring
                    Container(
                      height: 90 * val,
                      width: 90 * val,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ringColor.withOpacity(0.15),
                      ),
                    ),
                    // Inner solid circle
                    Container(
                      height: 70 * val,
                      width: 70 * val,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ringColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$_counter',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: guideTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Teknik Box Breathing (Kotak 4-4-4-4)',
            style: TextStyle(color: techTextColor, fontSize: 12),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkBg ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
