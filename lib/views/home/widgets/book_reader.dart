import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class BookModel {
  final String title;
  final String author;
  final String duration;
  final List<Color> coverColors;
  final IconData icon;
  final List<BookChapter> chapters;

  const BookModel({
    required this.title,
    required this.author,
    required this.duration,
    required this.coverColors,
    required this.icon,
    required this.chapters,
  });
}

class BookChapter {
  final String title;
  final String content;

  const BookChapter({required this.title, required this.content});
}

final List<BookModel> bookList = [
  const BookModel(
    title: 'Seni Berdamai dengan Diri',
    author: 'Tim Konselor RiseUp',
    duration: '8 Menit Baca',
    coverColors: [Color(0xFF6C63FF), Color(0xFF8F8AFF)],
    icon: Icons.self_improvement_rounded,
    chapters: [
      BookChapter(
        title: 'Bab 1: Mengenal Luka Lama',
        content: 'Berdamai dengan diri sendiri dimulai dengan keberanian untuk melihat ke belakang. Luka di masa lalu, baik berupa kegagalan, kekecewaan, atau penolakan, sering kali meninggalkan bekas yang tidak terlihat namun terus memengaruhi keputusan kita hari ini.\n\nMenerima bahwa masa lalu telah terjadi adalah langkah awal yang sangat penting. Kita tidak bisa mengubah apa yang sudah berlalu, tetapi kita memiliki kendali penuh atas bagaimana kita merespons masa lalu tersebut di masa kini. Tarik napas perlahan, dan katakan pada dirimu sendiri bahwa apa yang terjadi di masa lalu telah membentukmu menjadi sosok yang tangguh seperti sekarang.',
      ),
      BookChapter(
        title: 'Bab 2: Memaafkan untuk Melangkah',
        content: 'Memaafkan diri sendiri sering kali jauh lebih sulit daripada memaafkan orang lain. Kita cenderung menjadi kritikus paling kejam bagi diri kita sendiri. Setiap kesalahan kecil terus diungkit dalam pikiran.\n\nSadarlah bahwa sebagai manusia, kita terbatas dan tidak luput dari kesalahan. Memaafkan diri sendiri bukan berarti membenarkan tindakan buruk di masa lalu, melainkan melepaskan beban rasa bersalah agar kita dapat melangkah maju dengan hati yang lebih ringan. Mulailah berbicara kepada dirimu sendiri dengan kelembutan, layaknya kamu berbicara kepada seorang sahabat karib.',
      ),
      BookChapter(
        title: 'Bab 3: Merangkul Ketidaksempurnaan',
        content: 'Kita hidup di dunia yang sering kali menuntut kesempurnaan. Media sosial menampilkan kehidupan orang lain yang tampak tanpa celah, memicu kita untuk membandingkan diri secara tidak adil.\n\nKetidaksempurnaan adalah bagian alami dari menjadi manusia. Keindahan sejati terletak pada keunikan dan proses perjuangan kita masing-masing. Berhentilah mengejar standar yang tidak realistis. Rayakan setiap pencapaian kecil yang kamu raih hari ini, dan ingatlah bahwa kamu sudah cukup berharga apa adanya.',
      ),
    ],
  ),
  const BookModel(
    title: 'Keluar dari Lorong Depresi',
    author: 'Dr. Sarah (Pakar Mental)',
    duration: '5 Menit Baca',
    coverColors: [Color(0xFF00C9A7), Color(0xFF5BE7C4)],
    icon: Icons.wb_sunny_rounded,
    chapters: [
      BookChapter(
        title: 'Bab 1: Ketika Awan Gelap Datang',
        content: 'Depresi sering kali digambarkan seperti awan mendung tebal yang menggelapkan seluruh sudut kehidupan. Hal-hal yang dulunya membawa kebahagiaan mendadak terasa hambar. Energi tubuh terasa terkuras habis, bahkan untuk melakukan aktivitas paling sederhana sekalipun.\n\nJika kamu merasakan hal ini, ketahuilah bahwa ini bukanlah kelemahan karaktermu. Ini adalah respon kesehatan mental yang membutuhkan perhatian dan kelembutan. Jangan memaksakan dirimu untuk langsung sembuh dalam semalam. Mengakui bahwa kamu sedang berjuang adalah langkah awal yang luar biasa.',
      ),
      BookChapter(
        title: 'Bab 2: Cahaya di Ujung Lorong',
        content: 'Harapan adalah kunci utama dalam pemulihan dari depresi. Meskipun saat ini lorong terasa sangat gelap dan tanpa ujung, ketahuilah bahwa cahaya itu ada.\n\nLangkah-langkah kecil sangatlah berarti. Mulailah dengan membuka jendela kamar, membiarkan sinar matahari pagi masuk, atau meminum segelas air hangat. Jangan ragu untuk mencari bantuan profesional. Berbicara dengan psikolog atau orang terdekat akan meruntuhkan tembok isolasi yang dibangun oleh depresi. Kamu tidak harus berjalan di lorong ini sendirian.',
      ),
    ],
  ),
  const BookModel(
    title: 'Buku Saku Penenang Cemas',
    author: 'Tim Psikologi RiseUp',
    duration: '6 Menit Baca',
    coverColors: [Color(0xFFFF9F64), Color(0xFFFFBD96)],
    icon: Icons.menu_book_rounded,
    chapters: [
      BookChapter(
        title: 'Bab 1: Napas dan Kesadaran',
        content: 'Kecemasan sering kali datang tanpa mengetuk pintu. Jantung berdegup kencang, pikiran melayang memikirkan kemungkinan terburuk di masa depan, dan tubuh menjadi tegang.\n\nKetika kecemasan menyerang, jangkar terbaikmu adalah napasmu. Teknik pernapasan lambat mengaktifkan sistem saraf parasimpatik yang memberi sinyal aman ke otak Anda. Cobalah tarik napas selama 4 detik, tahan selama 4 detik, hembuskan selama 4 detik, dan tahan kembali selama 4 detik. Lakukan ini beberapa kali hingga Anda merasa kembali terhubung dengan momen saat ini.',
      ),
      BookChapter(
        title: 'Bab 2: Menghadapi Serangan Panik',
        content: 'Serangan panik terasa sangat menakutkan, seolah-olah Anda kehilangan kendali total atas tubuh Anda. Ingatlah satu hal penting: serangan panik akan berlalu. Ia memuncak dalam beberapa menit dan perlahan akan mereda.\n\nFokuskan indramu ke lingkungan sekitar dengan teknik 5-4-3-2-1: Sebutkan 5 benda yang kamu lihat, 4 benda yang bisa kamu sentuh, 3 suara yang kamu dengar, 2 bau yang kamu cium, dan 1 rasa yang kamu rasakan. Ini akan membantu mengalihkan fokus otak Anda dari ancaman imajiner kembali ke realitas fisik yang aman.',
      ),
    ],
  ),
  const BookModel(
    title: 'Hal yang Perlu Dilakukan Saat Stres',
    author: 'World Health Organization (WHO)',
    duration: '12 Menit Baca',
    coverColors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
    icon: Icons.health_and_safety_rounded,
    chapters: [
      BookChapter(
        title: 'Bab 1: Menstabilkan Diri (Grounding)',
        content: 'Ketika badai stres datang menyerang, pikiran kita sering kali melayang ke masa depan yang menakutkan atau terjebak dalam penyesalan masa lalu. Grounding membantu kita \'mendaratkan\' kembali kesadaran pada saat ini.\n\nLangkah pertama adalah menyadari apa yang sedang terjadi pada dirimu. Akui pikiran dan perasaanmu yang sedang berkecamuk tanpa menghakiminya. Tarik napas secara perlahan. Rasakan kakimu menapak kuat di lantai, rasakan berat tubuhmu disangga oleh kursi atau tanah.\n\nSelanjutnya, lakukan teknik koneksi kembali dengan indramu. Perhatikan sekelilingmu: sebutkan secara perlahan 5 benda yang bisa kamu lihat, dengarkan suara-suara di sekitarmu, hirup aroma udara saat ini. Dengan membumikan perhatianmu, kamu membantu otakmu menyadari bahwa saat ini, di sini, kamu berada dalam kondisi yang aman.',
      ),
      BookChapter(
        title: 'Bab 2: Melepaskan Diri (Unhooking)',
        content: 'Pikiran dan emosi negatif sering kali bertindak seperti kail pancing (hook) yang mencengkeram perhatian kita. Ketika kita terjerat (hooked), kita cenderung bertindak secara impulsif atau menjauh dari nilai-nilai kebaikan.\n\nMulai dengan menyadari kehadiran kail tersebut. Katakan pada dirimu sendiri: \'Ah, ini ada pikiran bahwa saya tidak mampu,\' atau \'Ada perasaan cemas yang sedang mencengkeram saya.\' Dengan menamainya, kamu membuat jarak antara dirimu dan pikiran tersebut.\n\nIngatlah bahwa pikiran hanyalah kata-kata di dalam kepala, dan emosi hanyalah sensasi di dalam tubuh. Kamu tidak harus menuruti atau melawan pikiran tersebut. Cukup biarkan ia ada di sana tanpa membiarkannya mengendalikan tindakanmu. Fokuskan kembali perhatianmu pada apa yang sedang kamu lakukan.',
      ),
      BookChapter(
        title: 'Bab 3: Bertindak Sesuai Nilai Diri',
        content: 'Bahkan di tengah situasi yang sangat penuh stres sekalipun, kita masih memiliki kebebasan untuk memilih bagaimana kita ingin bertindak. Nilai-nilai diri (values) adalah kompas moral yang memandu perilaku kita.\n\nTanyakan pada dirimu sendiri: \'Orang seperti apa yang ingin saya jadikan diri saya di tengah kesulitan ini? Apakah saya ingin menjadi orang yang penuh kasih, sabar, bertanggung jawab, atau protektif?\'\n\nTindakan sekecil apa pun yang selaras dengan nilai-nilai dirimu dapat memberikan rasa kebermaknaan dan kekuatan. Jika kamu menghargai kasih sayang, hubungi teman yang membutuhkan atau bersikaplah lembut pada dirimu sendiri. Fokuslah pada apa yang berada dalam kendalimu, bukan pada hal-hal yang tidak dapat kamu ubah.',
      ),
      BookChapter(
        title: 'Bab 4: Bersikap Baik pada Diri & Sesama',
        content: 'Saat stres melanda, kita cenderung bersikap keras kepada diri sendiri. Kita menyalahkan diri atas kesalahan atau ketidakberdayaan kita. Namun, obat terbaik untuk hati yang lelah adalah belas kasih (compassion).\n\nBersikap baik pada diri sendiri berarti memperlakukan dirimu seperti memperlakukan seorang sahabat karib yang sedang mengalami kesulitan. Hindari kritik diri yang kasar. Katakan kalimat yang menenangkan, seperti: \'Ini adalah momen yang sulit, tetapi saya melakukan yang terbaik yang saya bisa.\'\n\nSelain itu, carilah kesempatan untuk bersikap baik pada sesama. Tindakan menolong orang lain tidak hanya membantu mereka, tetapi juga memperkuat koneksi sosial kita sendiri dan meningkatkan kesejahteraan mental kita. Kita menghadapi kesulitan bersama-sama.',
      ),
    ],
  ),
];

class BookReaderScreen extends StatefulWidget {
  const BookReaderScreen({super.key});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    
    final backgroundColor = isDarkBg ? const Color(0xFF0F0F26) : const Color(0xFFF8FAFC);
    final cardColor = isDarkBg ? const Color(0xFF1E1E38) : Colors.white;
    final textColor = isDarkBg ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDarkBg ? Colors.white70 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Perpustakaan Ketenangan',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bacaan Terpilih Untukmu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Temukan ketenangan dan inspirasi melalui buku saku dan cerita pendek pilihan kami.',
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookList.length,
              itemBuilder: (context, idx) {
                final book = bookList[idx];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReadingViewScreen(book: book),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkBg ? Colors.white10 : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDarkBg ? 0.3 : 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Book Cover
                          Container(
                            width: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: book.coverColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                book.icon,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          // Book Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      book.duration,
                                      style: const TextStyle(
                                        color: Color(0xFF6C63FF),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    book.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: textColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Oleh ${book.author}',
                                    style: TextStyle(
                                      color: subtitleColor,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: subtitleColor.withOpacity(0.5),
                            size: 16,
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReadingViewScreen extends StatefulWidget {
  final BookModel book;
  const ReadingViewScreen({super.key, required this.book});

  @override
  State<ReadingViewScreen> createState() => _ReadingViewScreenState();
}

class _ReadingViewScreenState extends State<ReadingViewScreen> {
  int _currentChapterIdx = 0;
  double _fontSize = 15.0;
  bool _useSepiaMode = false; // Sepia theme option for e-reader

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    
    // Background and text colors inside e-reader
    Color readerBgColor;
    Color readerTextColor;
    Color topBarColor;

    if (_useSepiaMode) {
      readerBgColor = const Color(0xFFFAF6EE);
      readerTextColor = const Color(0xFF4C3627);
      topBarColor = const Color(0xFFF3EAD8);
    } else if (isDarkBg) {
      readerBgColor = const Color(0xFF13132B);
      readerTextColor = Colors.white70;
      topBarColor = const Color(0xFF1E1E38);
    } else {
      readerBgColor = Colors.white;
      readerTextColor = const Color(0xFF2C3E50);
      topBarColor = const Color(0xFFF8FAFC);
    }

    final chapter = widget.book.chapters[_currentChapterIdx];
    final progress = (_currentChapterIdx + 1) / widget.book.chapters.length;

    return Scaffold(
      backgroundColor: readerBgColor,
      appBar: AppBar(
        backgroundColor: topBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: isDarkBg ? Colors.white : const Color(0xFF3F3D56)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.book.title,
          style: TextStyle(
            color: isDarkBg ? Colors.white : const Color(0xFF3F3D56),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Sepia toggle
          IconButton(
            icon: Icon(
              Icons.palette_rounded, 
              color: _useSepiaMode ? Colors.amber.shade700 : (isDarkBg ? Colors.white : const Color(0xFF3F3D56)),
            ),
            onPressed: () {
              setState(() {
                _useSepiaMode = !_useSepiaMode;
              });
            },
            tooltip: 'Gaya Bacaan',
          ),
          // Font size controls
          IconButton(
            icon: Icon(Icons.text_fields_rounded, color: isDarkBg ? Colors.white : const Color(0xFF3F3D56)),
            onPressed: () {
              setState(() {
                if (_fontSize < 24.0) _fontSize += 2.0;
                else _fontSize = 15.0; // Reset
              });
            },
            tooltip: 'Ukuran Huruf',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chapter navigation bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: topBarColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _currentChapterIdx > 0
                      ? () {
                          setState(() {
                            _currentChapterIdx--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                Text(
                  '${_currentChapterIdx + 1} / ${widget.book.chapters.length} Bab',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkBg ? Colors.white70 : const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  onPressed: _currentChapterIdx < widget.book.chapters.length - 1
                      ? () {
                          setState(() {
                            _currentChapterIdx++;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.skip_next_rounded),
                ),
              ],
            ),
          ),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: isDarkBg ? Colors.white10 : const Color(0xFFE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            minHeight: 3,
          ),
          // Reading Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: TextStyle(
                      fontSize: _fontSize + 4,
                      fontWeight: FontWeight.w900,
                      color: _useSepiaMode ? const Color(0xFF3C2617) : (isDarkBg ? Colors.white : const Color(0xFF0F172A)),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    chapter.content,
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: readerTextColor,
                      height: 1.6,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
