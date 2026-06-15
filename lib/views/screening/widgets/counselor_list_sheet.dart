import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/auth_provider.dart';

class CounselorListSheet extends StatelessWidget {
  const CounselorListSheet({super.key});

  void _launchWhatsApp(BuildContext context, String phoneNumber, String name) async {
    final message = Uri.encodeComponent(
      "Halo, saya pengguna aplikasi RiseUp. Saya baru saja melakukan skrining mandiri kesehatan mental dan disarankan untuk berkonsultasi dengan profesional. Apakah saya bisa bertanya-tanya atau menjadwalkan konseling secara online?"
    );
    final url = "https://wa.me/$phoneNumber?text=$message";
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka WhatsApp. Silakan periksa koneksi Anda.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _launchPhone(BuildContext context, String phoneNumber) async {
    final url = "tel:$phoneNumber";
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat melakukan panggilan ke $phoneNumber.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    final bgColor = isDarkBg ? const Color(0xFF16162D) : Colors.white;
    final titleColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleColor = isDarkBg ? Colors.white70 : const Color(0xFF64748B);
    final cardBgColor = isDarkBg ? const Color(0xFF232343) : const Color(0xFFF8F9FD);
    final cardBorderColor = isDarkBg ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0);
    final closeIconColor = isDarkBg ? Colors.white70 : Colors.black54;

    final List<Map<String, dynamic>> counselors = [
      {
        'name': 'Laksita Educare Online',
        'title': 'Layanan Konseling & Terapi Emosi Online',
        'specialty': 'Konseling Kecemasan, Stres Akademik, Karir, & Remaja',
        'phone': '628170434500', // WhatsApp Resmi Laksita Educare (Aktif)
        'type': 'whatsapp',
        'tag': 'Konseling Chat',
        'tagColor': const Color(0xFFEC4899),
        'icon': Icons.favorite_rounded,
        'method': 'Online WhatsApp Chat & Sesi Terjadwal',
        'description': 'Biro layanan psikologi terpercaya yang menyediakan konsultasi psikologi online via WhatsApp chat. Anda dapat langsung bertanya, berkonsultasi secara santai, privat, dan aman.',
      },
      {
        'name': 'Yayasan Pulih',
        'title': 'Konseling Psikologi Klinis Online Terpercaya',
        'specialty': 'Depresi, Stres, Masalah Hubungan, & Pemulihan Trauma',
        'phone': '628118436633', // WhatsApp Resmi Yayasan Pulih (Aktif)
        'type': 'whatsapp',
        'tag': 'Psikolog Online',
        'tagColor': const Color(0xFF6C63FF),
        'icon': Icons.chat_bubble_rounded,
        'method': 'Online Chat & Video Call (Tarif Subsidi)',
        'description': 'Konseling online dengan psikolog klinis profesional berlisensi secara terstruktur via chat atau Zoom. Pendaftaran mudah via WhatsApp admin.',
      },
      {
        'name': 'Riliv Support (Konseling Online)',
        'title': 'Konseling Online Praktis bersama Psikolog Berlisensi',
        'specialty': 'Konseling Chat / Call bersama Psikolog Klinis Resmi',
        'phone': '6282336661719', // WhatsApp Resmi Riliv Support (Aktif)
        'type': 'whatsapp',
        'tag': 'Platform Konseling',
        'tagColor': const Color(0xFF2196F3),
        'icon': Icons.smartphone_rounded,
        'method': 'Online App Chat / Call',
        'description': 'Tanya jawab mengenai pendaftaran konseling online via aplikasi Riliv. Menghubungkan Anda langsung dengan psikolog klinis resmi HIMPSI secara mudah.',
      },
      {
        'name': 'Klinik Terpadu Psikologi UI',
        'title': 'Layanan Psikologi Online Universitas Indonesia',
        'specialty': 'Konseling Individu, Keluarga, & Terapi Perilaku Online',
        'phone': '6281510073561', // WhatsApp Resmi KPT UI (Aktif)
        'type': 'whatsapp',
        'tag': 'Konseling Akademis',
        'tagColor': const Color(0xFF3F51B5),
        'icon': Icons.school_rounded,
        'method': 'Online Sesi Terjadwal',
        'description': 'Layanan konsultasi psikologi online resmi yang ditangani oleh psikolog klinis senior lulusan Universitas Indonesia secara privat dan profesional.',
      },
      {
        'name': 'Personal Growth Online',
        'title': 'Konseling Psikologi Online Premium',
        'specialty': 'Konseling Psikoterapi, Karir, Hubungan, & Pengembangan Diri',
        'phone': '6281808090395', // WhatsApp Resmi Personal Growth (Aktif)
        'type': 'whatsapp',
        'tag': 'Lembaga Profesional',
        'tagColor': const Color(0xFFFF9F64),
        'icon': Icons.psychology_rounded,
        'method': 'Online Chat & Video Call',
        'description': 'Layanan konsultasi online eksklusif bersama psikolog klinis senior profesional dari Personal Growth (didirikan oleh Ratih Ibrahim).',
      },
      {
        'name': 'Layanan SEJIWA 119',
        'title': 'Kemenkes RI - Layanan Darurat Panggilan',
        'specialty': 'Konseling Krisis & Tanggap Darurat Kesehatan Mental',
        'phone': '119',
        'type': 'phone',
        'tag': 'Panggilan Darurat',
        'tagColor': const Color(0xFFE53935),
        'icon': Icons.phone_in_talk_rounded,
        'method': 'Online Call Telepon (Bebas Pulsa)',
        'description': 'Layanan dukungan psikososial gratis dan darurat resmi dari Kementerian Kesehatan RI. Hubungi lewat telepon seluler kapan saja secara nasional.',
      },
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkBg ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Layanan Konseling Online',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: closeIconColor,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Hubungi salah satu layanan konsultasi online terpercaya di bawah ini untuk mengobrol, curhat, atau bertanya-tanya secara langsung.',
            style: TextStyle(
              color: subtitleColor,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: counselors.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final item = counselors[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cardBorderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkBg ? 0.15 : 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: item['tagColor'].withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item['icon'],
                              color: item['tagColor'],
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item['tagColor'].withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item['tag'],
                                        style: TextStyle(
                                          color: item['tagColor'],
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF00C9A7),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Online / Aktif',
                                          style: TextStyle(
                                            color: isDarkBg ? Colors.white54 : Colors.black45,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: titleColor,
                                  ),
                                ),
                                Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: item['tagColor'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: cardBorderColor, thickness: 1),
                      const SizedBox(height: 8),
                      Text(
                        'METODE LAYANAN:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDarkBg ? Colors.white38 : Colors.black38,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['method'],
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'KEAHLIAN TANYA JAWAB:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDarkBg ? Colors.white38 : Colors.black38,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['specialty'],
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkBg ? Colors.white60 : const Color(0xFF505050),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (item['type'] == 'whatsapp') {
                              _launchWhatsApp(context, item['phone'], item['name']);
                            } else {
                              _launchPhone(context, item['phone']);
                            }
                          },
                          icon: Icon(
                            item['type'] == 'whatsapp'
                                ? Icons.chat_bubble_rounded
                                : Icons.phone_forwarded_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: Text(
                            item['type'] == 'whatsapp' ? 'Tanya via WhatsApp' : 'Hubungi Telepon',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item['tagColor'],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
