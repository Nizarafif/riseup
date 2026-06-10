import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/widgets/doodle_background.dart';

class ActivitySetupScreen extends StatefulWidget {
  const ActivitySetupScreen({super.key});

  @override
  State<ActivitySetupScreen> createState() => _ActivitySetupScreenState();
}

class _ActivitySetupScreenState extends State<ActivitySetupScreen> {
  final Set<String> _selectedIds = {}; // Mulai dengan kosong agar pengguna menentukan pilihannya sendiri

  final List<ActivityItem> _activities = [
    ActivityItem(
      id: 'sleep',
      title: 'Kualitas Tidur & Istirahat',
      description: 'Pantau durasi tidur nyenyak, jadwal istirahat, dan ritme relaksasi tubuh Anda.',
      icon: Icons.king_bed_rounded,
      color: const Color(0xFF6C63FF),
    ),
    ActivityItem(
      id: 'fitness',
      title: 'Kebugaran & Aktivitas Fisik',
      description: 'Pantau rutinitas olahraga harian, peregangan otot, jalan santai, atau yoga.',
      icon: Icons.self_improvement_rounded,
      color: const Color(0xFF00C9A7),
    ),
    ActivityItem(
      id: 'selfcare',
      title: 'Kesehatan Mental & Self-Care',
      description: 'Lacak aktivitas meditasi Anda, menulis jurnal, latihan napas, atau sesi konseling.',
      icon: Icons.spa_rounded,
      color: const Color(0xFFFF9F64),
    ),
    ActivityItem(
      id: 'cycle',
      title: 'Siklus Menstruasi & Hormonal',
      description: 'Pantau fase siklus bulanan, gejala PMS, dan suasana hati terkait hormon.',
      icon: Icons.female_rounded,
      color: const Color(0xFFF43F5E),
    ),
    ActivityItem(
      id: 'beauty',
      title: 'Perawatan Diri & Skincare',
      description: 'Luangkan waktu untuk skincare harian, mandi busa, atau spa relaksasi di rumah.',
      icon: Icons.face_retouching_natural_rounded,
      color: const Color(0xFFFDA4AF),
    ),
    ActivityItem(
      id: 'hobbies',
      title: 'Hobi & Ekspresi Kreatif',
      description: 'Jejaki waktu santai untuk membaca buku, melukis, bermain musik, atau gaming.',
      icon: Icons.palette_rounded,
      color: const Color(0xFF3B82F6),
    ),
    ActivityItem(
      id: 'nutrition',
      title: 'Nutrisi & Pola Makan',
      description: 'Catat keteraturan pola makan sehat, kecukupan hidrasi air, dan vitamin.',
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFEC4899),
    ),
    ActivityItem(
      id: 'social',
      title: 'Hubungan & Interaksi Sosial',
      description: 'Pantau kualitas komunikasi dengan teman terdekat, keluarga, atau komunitas.',
      icon: Icons.people_alt_rounded,
      color: const Color(0xFF8B5CF6),
    ),
    ActivityItem(
      id: 'housework',
      title: 'Pekerjaan Rumah & Merapikan',
      description: 'Pantau aktivitas membersihkan kamar, merapikan rumah, memasak, atau tata ruang.',
      icon: Icons.home_work_rounded,
      color: const Color(0xFF0EA5E9),
    ),
    ActivityItem(
      id: 'study',
      title: 'Sekolah & Pengembangan Diri',
      description: 'Belajar, menghadiri kelas, membaca artikel bermanfaat, atau menulis tugas.',
      icon: Icons.school_rounded,
      color: const Color(0xFFF59E0B),
    ),
    ActivityItem(
      id: 'weather',
      title: 'Pengaruh Cuaca & Alam',
      description: 'Pantau aktivitas luar ruangan saat cerah, hujan, atau waktu menikmati keindahan alam.',
      icon: Icons.wb_sunny_rounded,
      color: const Color(0xFF10B981),
    ),
    ActivityItem(
      id: 'work',
      title: 'Pekerjaan & Produktivitas',
      description: 'Lacak waktu menyelesaikan tugas kantor, rapat, kolaborasi, atau fokus proyek.',
      icon: Icons.work_rounded,
      color: const Color(0xFF64748B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    final textColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleColor = isDarkBg ? Colors.white70 : const Color(0xFF707070);

    return Scaffold(
      body: DoodleBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Header dengan Indikator Langkah (Titik Ketiga Aktif) & Tombol Kembali
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                      onPressed: () {
                        authProvider.resetActivitySetup();
                      },
                      tooltip: 'Kembali',
                    ),
                    // Indikator Halaman (3 titik, titik kedua aktif)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: textColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 48), // Spacer penyeimbang tombol back
                  ],
                ),
              ),

              // 2. Judul dan Subjudul
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Jejak Rutinitas Harian',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pilih beberapa fokus rutinitas harian yang ingin Anda pantau untuk melihat pengaruhnya terhadap kesehatan mental Anda dari waktu ke waktu.',
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Daftar Pilihan Aktivitas
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    final item = _activities[index];
                    final isSelected = _selectedIds.contains(item.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedIds.remove(item.id);
                            } else {
                              _selectedIds.add(item.id);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: isDarkBg 
                                ? Colors.white.withOpacity(isSelected ? 0.18 : 0.08)
                                : Colors.white.withOpacity(isSelected ? 0.95 : 0.85),
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: isSelected 
                                  ? item.color 
                                  : (isDarkBg ? Colors.white10 : Colors.grey.withOpacity(0.15)),
                              width: isSelected ? 2.5 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected 
                                    ? item.color.withOpacity(isDarkBg ? 0.15 : 0.08)
                                    : Colors.black.withOpacity(0.02),
                                blurRadius: isSelected ? 12 : 6,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              // Ikon Kategori
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: item.color.withOpacity(isSelected ? 0.18 : 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.icon,
                                  color: item.color,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Detail Teks
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: subtitleColor,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Checkbox Lingkaran Kustom
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isSelected ? item.color : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected 
                                        ? item.color 
                                        : (isDarkBg ? Colors.white38 : Colors.grey.withOpacity(0.4)),
                                    width: 2.0,
                                  ),
                                ),
                                child: isSelected 
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 4. Tombol Aksi "Berikutnya" (Pill Kuning di Bagian Bawah)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      authProvider.completeActivitySetup(_selectedIds.toList());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD54F),
                      foregroundColor: const Color(0xFF2C2C2C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Berikutnya',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
