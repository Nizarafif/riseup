import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/diagnostic_provider.dart';
import '../../providers/mood_provider.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../screening/screening_screen.dart';
import '../monitoring/monitoring_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedMoodLevel = 0;
  final _noteController = TextEditingController();
  bool _moodLoggedToday = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<DiagnosticProvider>(context, listen: false).loadDiagnosticData(user.uid);
        Provider.of<MoodProvider>(context, listen: false).fetchMoods(user.uid);
      }
    });
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

    if (user == null) return const LoginScreen();

    final latestHistory = diagnosticProvider.historyList.isNotEmpty 
        ? diagnosticProvider.historyList.first 
        : null;

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
              'RiseUp',
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
            // Greeting & Header
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
                      Text(
                        user.role == 'admin' ? 'Masuk sebagai Pakar/Admin' : 'Bagaimana kesehatan mentalmu hari ini?',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF707070),
                        ),
                      ),
                    ],
                  ),
                ),
                if (user.role == 'admin')
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
            const SizedBox(height: 24),

            // Wellness Quotes Card
            Container(
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
            ),
            const SizedBox(height: 24),

            // Mood Tracker Section
            if (user.role == 'user') ...[
              const Text(
                'Jurnal Mood Harian',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
              ),
              const SizedBox(height: 12),
              Container(
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
                              _buildMoodEmoji(1, '😢', 'Sangat Buruk'),
                              _buildMoodEmoji(2, '🙁', 'Buruk'),
                              _buildMoodEmoji(3, '😐', 'Normal'),
                              _buildMoodEmoji(4, '🙂', 'Baik'),
                              _buildMoodEmoji(5, '😄', 'Sangat Baik'),
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
              ),
              const SizedBox(height: 24),
            ],

            // Mental Health Screening Card (Expert System)
            const Text(
              'Sistem Pakar Deteksi Gejala',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
            ),
            const SizedBox(height: 12),
            Container(
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C9A7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.analytics_outlined, color: Color(0xFF00C9A7)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Monitoring Kesehatan Mental',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3F3D56)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              latestHistory != null
                                  ? 'Terakhir Tes: ${DateFormat('dd MMM yyyy, HH:mm').format(latestHistory.tanggal)}'
                                  : 'Kamu belum pernah melakukan monitoring.',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF707070)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  if (latestHistory != null) ...[
                    const Divider(height: 32),
                    const Text(
                      'Diagnosis Terakhir Pakar:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: latestHistory.diagnosisCode == 'P000'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        latestHistory.hasilDiagnosis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: latestHistory.diagnosisCode == 'P000' ? Colors.green[800] : Colors.red[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      latestHistory.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF505050), height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const MonitoringScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF6C63FF)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Lihat Riwayat & Grafik', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Reset state skrining
                            diagnosticProvider.resetScreening();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ScreeningScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Mulai Tes Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Wellness Breathing Exercise Box
            const Text(
              'Latihan Relaksasi Instan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
            ),
            const SizedBox(height: 12),
            InkWell(
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
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodEmoji(int level, String emoji, String label) {
    bool isSelected = _selectedMoodLevel == level;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMoodLevel = level;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.15) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              emoji,
              style: TextStyle(fontSize: isSelected ? 32 : 26),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF6C63FF) : Colors.black45,
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
