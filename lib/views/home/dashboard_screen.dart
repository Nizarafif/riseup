import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diagnostic_provider.dart';
import '../../providers/mood_provider.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../screening/screening_screen.dart';
import '../monitoring/monitoring_screen.dart';
import '../auth/widgets/doodle_background.dart';
import '../music/ambient_music_sheet.dart';
import 'widgets/breathing_modal.dart';
import 'widgets/home_tab.dart';
import 'widgets/screening_tab.dart';
import 'widgets/settings_tab.dart';
import 'widgets/book_reader.dart';
import '../screening/map_webview_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static void startScreeningTest(BuildContext context, DiagnosticProvider diagnosticProvider) {
    if (diagnosticProvider.hasTestedToday) {
      showDialog(
        context: context,
        builder: (context) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
          final dialogBgColor = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
          final textColor = isDarkBg ? Colors.white : const Color(0xFF1E293B);
          
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: dialogBgColor,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Batasan Harian',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Anda sudah melakukan tes skrining hari ini. Sesuai dengan anjuran klinis, tes skrining sebaiknya dilakukan maksimal sekali sehari untuk memantau kondisi perkembangan emosi secara optimal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDarkBg ? Colors.white70 : const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Mengerti',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      diagnosticProvider.resetScreening();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ScreeningScreen()),
      );
    }
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isMenuOpen = false;
  DateTime? _lastPressedAt;
  late DiagnosticProvider _diagnosticProvider;

  Future<bool> _onWillPop() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null && user.role != 'admin' && _currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }

    final now = DateTime.now();
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    final snackBarBgColor = isDarkBg
        ? const Color(0xFF1E1E38)
        : const Color(0xFF3F3D56);
    final borderSide = isDarkBg
        ? const BorderSide(color: Colors.white10, width: 1)
        : BorderSide.none;

    if (_lastPressedAt == null ||
        now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(
                Icons.exit_to_app_rounded,
                color: Color(0xFF00C9A7),
                size: 20,
              ),
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
        if (user.role == 'admin') {
          _diagnosticProvider.listenToAdminData();
        }
        if (authProvider.initialMoodLevel != null &&
            authProvider.initialMoodLevel! > 0) {
          final level = authProvider.initialMoodLevel!;
          Provider.of<MoodProvider>(
            context,
            listen: false,
          ).addMood(user.uid, level, '');
          authProvider.setInitialMoodLevel(null);
        }

        _diagnosticProvider.loadDiagnosticData(user.uid).then((_) {
          if (mounted) {
            _checkFirstTimeUser();
          }
        });
        Provider.of<MoodProvider>(context, listen: false).fetchMoods(user.uid);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _diagnosticProvider = Provider.of<DiagnosticProvider>(context, listen: false);
    _diagnosticProvider.listenToPosters();
    _diagnosticProvider.listenToMotivations();
  }

  void _checkFirstTimeUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final diagnosticProvider = Provider.of<DiagnosticProvider>(
      context,
      listen: false,
    );
    final user = authProvider.user;

    if (user != null &&
        user.role == 'user' &&
        !diagnosticProvider.hasTestedToday) {
      if (diagnosticProvider.historyList.isEmpty) {
        _showWelcomeTestDialog();
      } else {
        _showDailyScreeningReminderDialog();
      }
    }
  }

  void _showDailyScreeningReminderDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
        final dialogBgColor = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
        final titleColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
        final contentColor = isDarkBg ? Colors.white70 : const Color(0xFF505050);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: dialogBgColor,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF00C9A7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Evaluasi Harian',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ],
          ),
          content: Text(
            'Hari baru telah dimulai! Yuk, sempatkan waktu 1 menit untuk melakukan tes skrining harian agar perkembangan emosi dan kesehatan mentalmu tetap terpantau dengan baik.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: contentColor,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  DashboardScreen.startScreeningTest(context, Provider.of<DiagnosticProvider>(context, listen: false));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'Mulai Skrining',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showWelcomeTestDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
        final dialogBgColor = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
        final titleColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
        final contentColor = isDarkBg ? Colors.white70 : const Color(0xFF505050);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: dialogBgColor,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ],
          ),
          content: Text(
            'Untuk dapat mendeteksi awal dan memantau kondisi kesehatan mental Anda secara mandiri dengan optimal, sistem pakar kami membutuhkan data analisis awal.\n\nSilakan isi tes kuesioner singkat terlebih dahulu.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: contentColor,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  DashboardScreen.startScreeningTest(context, Provider.of<DiagnosticProvider>(context, listen: false));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'Mulai Tes Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _diagnosticProvider.cancelAdminListeners();
    _diagnosticProvider.cancelPostersListener();
    _diagnosticProvider.cancelMotivationsListener();
    super.dispose();
  }

  void _showBreathingGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BreathingModal(),
    );
  }

  void _showAmbientMusicSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AmbientMusicSheet(),
    );
  }

  void _showBookReader() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const BookReaderScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) return const LoginScreen();

    if (user.role == 'admin') {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: const AdminDashboardScreen(),
      );
    }

    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;

    final List<Widget> tabs = [
      HomeTab(user: user),
      ScreeningTab(
        user: user,
        onStartScreening: () {
          DashboardScreen.startScreeningTest(context, _diagnosticProvider);
        },
      ),
      const MonitoringScreen(isEmbedded: true),
      SettingsTab(user: user),
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
            backgroundColor: isDarkBg
                ? Colors.transparent
                : Colors.white.withOpacity(0.9),
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkBg
                        ? Colors.white.withOpacity(0.12)
                        : const Color(0xFF6C63FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: isDarkBg
                        ? const Color(0xFF00C9A7)
                        : const Color(0xFF6C63FF),
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
              IndexedStack(index: _currentIndex, children: tabs),
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
                        child: Container(color: Colors.black.withOpacity(0.18)),
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
                targetBottom: 105,
                targetLeft: screenWidth / 2 - 120 - 60,
                closedBottom: 30,
                closedLeft: screenWidth / 2 - 60,
              ),
              _buildFloatingItem(
                icon: Icons.map_rounded,
                label: 'Peta Pakar',
                color: Colors.indigo,
                onTap: () {
                  setState(() => _isMenuOpen = false);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MapWebviewScreen(
                        url: 'https://www.google.com/maps/search/?api=1&query=psikolog+dan+psikiater+terdekat',
                        title: 'Peta Psikolog & Psikiater',
                      ),
                    ),
                  );
                },
                isOpen: _isMenuOpen,
                targetBottom: 175,
                targetLeft: screenWidth / 2 - 45 - 60,
                closedBottom: 30,
                closedLeft: screenWidth / 2 - 60,
              ),
              _buildFloatingItem(
                icon: Icons.menu_book_rounded,
                label: 'Baca Buku',
                color: const Color(0xFF00C9A7),
                onTap: () {
                  setState(() => _isMenuOpen = false);
                  _showBookReader();
                },
                isOpen: _isMenuOpen,
                targetBottom: 175,
                targetLeft: screenWidth / 2 + 45 - 60,
                closedBottom: 30,
                closedLeft: screenWidth / 2 - 60,
              ),
              _buildFloatingItem(
                icon: Icons.music_note_rounded,
                label: 'Melodi Damai',
                color: const Color(0xFFEC4899),
                onTap: () {
                  setState(() => _isMenuOpen = false);
                  _showAmbientMusicSheet();
                },
                isOpen: _isMenuOpen,
                targetBottom: 105,
                targetLeft: screenWidth / 2 + 120 - 60,
                closedBottom: 30,
                closedLeft: screenWidth / 2 - 60,
              ),
            ],
          ),
          bottomNavigationBar: Container(
            height: 85,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            decoration: const BoxDecoration(color: Colors.transparent),
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
                      _buildNavItem(
                        0,
                        Icons.home_outlined,
                        Icons.home_rounded,
                        'Beranda',
                        isDarkBg
                            ? const Color(0xFF00C9A7)
                            : const Color(0xFF6C63FF),
                      ),
                      _buildNavItem(
                        1,
                        Icons.psychology_outlined,
                        Icons.psychology_rounded,
                        'Skrining',
                        const Color(0xFF00C9A7),
                      ),
                      _buildMiddleAddButton(context),
                      _buildNavItem(
                        2,
                        Icons.analytics_outlined,
                        Icons.analytics_rounded,
                        'Tren',
                        isDarkBg
                            ? const Color(0xFFFF9F64)
                            : const Color(0xFFFF9F64),
                      ),
                      _buildNavItem(
                        3,
                        Icons.settings_outlined,
                        Icons.settings_rounded,
                        'Pengaturan',
                        isDarkBg
                            ? const Color(0xFFB39DDB)
                            : const Color(0xFF9C27B0),
                      ),
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

  Widget _buildNavItem(
    int index,
    IconData outlineIcon,
    IconData solidIcon,
    String label,
    Color themeColor,
  ) {
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
            ),
          ],
        ),
        child: AnimatedRotation(
          turns: _isMenuOpen ? 0.125 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
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
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.85), color],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
}
