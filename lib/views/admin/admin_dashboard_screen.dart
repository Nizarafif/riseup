import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diagnostic_provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/symptoms_manager.dart';
import 'widgets/rules_manager.dart';
import 'widgets/diseases_manager.dart';
import 'widgets/stats_trends_manager.dart';
import 'widgets/poster_manager.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int initialTabIndex;
  const AdminDashboardScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late DiagnosticProvider _diagnosticProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _diagnosticProvider.listenToAdminData();
      _diagnosticProvider.listenToPosters();
      _diagnosticProvider.listenToMotivations();
      
      // Jika dipanggil dengan initialTabIndex tertentu, langsung arahkan ke modul tersebut
      if (widget.initialTabIndex != 0) {
        _navigateToInitialTab();
      }
    });
  }

  void _navigateToInitialTab() {
    String title = 'Manajemen Gejala';
    Widget manager = const SymptomsManager();
    
    if (widget.initialTabIndex == 1) {
      title = 'Aturan Pakar';
      manager = const RulesManager();
    } else if (widget.initialTabIndex == 2) {
      title = 'Daftar Gangguan';
      manager = const DiseasesManager();
    } else if (widget.initialTabIndex == 3) {
      title = 'Statistik & Tren';
      manager = const StatsTrendsManager();
    } else if (widget.initialTabIndex == 4) {
      title = 'Poster Edukasi';
      manager = const PosterManager();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminSubScreen(title: title, child: manager),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _diagnosticProvider = Provider.of<DiagnosticProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _diagnosticProvider.cancelAdminListeners();
    _diagnosticProvider.cancelPostersListener();
    _diagnosticProvider.cancelMotivationsListener();
    super.dispose();
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

  Widget _buildHeader(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final userName = user?.name ?? 'Pakar';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Color(0xFF6C63FF),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Pakar / Administrator',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showLogoutConfirmationDialog(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.power_settings_new_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int symptomCount, int ruleCount, int diseaseCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('$symptomCount', 'Gejala', const Color(0xFF8B5CF6)),
          Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
          _buildStatItem('$ruleCount', 'Aturan', const Color(0xFF10B981)),
          Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
          _buildStatItem('$diseaseCount', 'Gangguan', const Color(0xFFFF9F64)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget destination,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminSubScreen(title: title, child: destination),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFCBD5E1),
                size: 14,
              ),
            ],
          ),
        ),
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildStatsRow(symptoms.length, rules.length, diseases.length),
              const SizedBox(height: 28),
              const Text(
                'MENU PANEL KONTROL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              _buildMenuCard(
                context,
                title: 'Manajemen Gejala',
                subtitle: 'Kelola basis data indikator gejala psikologis',
                icon: Icons.spa_rounded,
                iconColor: const Color(0xFF8B5CF6),
                destination: const SymptomsManager(),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                title: 'Aturan Pakar',
                subtitle: 'Atur basis aturan relasi gejala dan diagnosis',
                icon: Icons.rule_folder_rounded,
                iconColor: const Color(0xFF10B981),
                destination: const RulesManager(),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                title: 'Daftar Gangguan',
                subtitle: 'Kelola diagnosis & kategori gangguan mental',
                icon: Icons.psychology_rounded,
                iconColor: const Color(0xFFFF9F64),
                destination: const DiseasesManager(),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                title: 'Statistik & Tren',
                subtitle: 'Monitoring pengguna & analitik data skrining',
                icon: Icons.analytics_rounded,
                iconColor: const Color(0xFF0284C7),
                destination: const StatsTrendsManager(),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                title: 'Poster Edukasi',
                subtitle: 'Kelola materi edukasi tips kesehatan aktif',
                icon: Icons.photo_library_rounded,
                iconColor: const Color(0xFF6C63FF),
                destination: const PosterManager(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminSubScreen extends StatelessWidget {
  final String title;
  final Widget child;
  const AdminSubScreen({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
