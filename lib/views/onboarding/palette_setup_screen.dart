import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/mood_theme_helper.dart';
import '../auth/widgets/doodle_background.dart';

class PaletteSetupScreen extends StatefulWidget {
  const PaletteSetupScreen({super.key});

  @override
  State<PaletteSetupScreen> createState() => _PaletteSetupScreenState();
}

class _PaletteSetupScreenState extends State<PaletteSetupScreen> {
  int _selectedPaletteIndex = 0;
  int _selectedEmojiThemeIndex = 0;
  int _selectedBackgroundThemeIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _selectedPaletteIndex = authProvider.selectedPaletteIndex;
        _selectedEmojiThemeIndex = authProvider.selectedEmojiThemeIndex;
        _selectedBackgroundThemeIndex = authProvider.selectedBackgroundThemeIndex;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = _selectedBackgroundThemeIndex == 2;
    final textColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleColor = isDarkBg ? Colors.white70 : const Color(0xFF707070);

    return Scaffold(
      body: DoodleBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Header dengan Indikator Langkah (Tiga Titik) & Tombol Kembali
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                      onPressed: () {
                        authProvider.resetPaletteSetup();
                      },
                      tooltip: 'Kembali',
                    ),
                    // Indikator Halaman (3 titik, titik pertama aktif)
                    Row(
                      children: [
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
                      'Buat Palet Warna Anda',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cocokkan warna mood Anda ke kepribadian Anda. Anda dapat mengubah emoji, nama, dan bahkan menambah yang baru di kemudian waktu.',
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
              const SizedBox(height: 20),

              // 3. Area Konten Pilihan
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Bagian LATAR BELAKANG (Horizontal List)
                      Text(
                        'Latar Belakang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: 3, // Doodle, Cairan, Malam
                          itemBuilder: (context, index) {
                            final isSelected = _selectedBackgroundThemeIndex == index;
                            String name = '';
                            IconData icon = Icons.circle;
                            Color iconColor = Colors.grey;

                            if (index == 0) {
                              name = 'Doodle';
                              icon = Icons.brush_outlined;
                              iconColor = const Color(0xFFFF9F64);
                            } else if (index == 1) {
                              name = 'Cairan';
                              icon = Icons.bubble_chart_outlined;
                              iconColor = const Color(0xFF00C9A7);
                            } else {
                              name = 'Malam';
                              icon = Icons.nights_stay_outlined;
                              iconColor = const Color(0xFF6C63FF);
                            }

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedBackgroundThemeIndex = index;
                                });
                                Provider.of<AuthProvider>(context, listen: false)
                                    .updateBackgroundTheme(index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 14, bottom: 8, top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
                                    width: 3.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6C63FF).withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(icon, color: iconColor, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: Color(0xFF3F3D56),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bagian WARNA (Horizontal List)
                      Text(
                        'Warna',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: MoodThemeHelper.palettes.length,
                          itemBuilder: (context, index) {
                            final palette = MoodThemeHelper.palettes[index];
                            final isSelected = _selectedPaletteIndex == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPaletteIndex = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 14, bottom: 8, top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
                                    width: 3.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6C63FF).withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    palette.colors.length,
                                    (cIdx) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: palette.colors[cIdx],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Bagian TEMA EMOJI (Vertical List)
                      Text(
                        'Tema Emoji',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // List Tema Emoji Vertikal (10 Tema Emoji)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedEmojiThemeIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedEmojiThemeIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
                                  width: 3.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C63FF).withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: List.generate(
                                  5,
                                  (levelIdx) => MoodEmojiWidget(
                                    level: levelIdx + 1,
                                    size: 38,
                                    paletteIndex: _selectedPaletteIndex,
                                    emojiThemeIndex: index,
                                    isSelected: false,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
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
                      authProvider.completePaletteSetup(
                        _selectedPaletteIndex,
                        _selectedEmojiThemeIndex,
                        _selectedBackgroundThemeIndex,
                      );
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
