import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/symptom_model.dart';
import '../models/disease_model.dart';
import '../models/rule_model.dart';
import '../models/history_model.dart';
import '../models/mood_model.dart';
import '../models/book_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore? _db;
  bool _useMock = true; // Default ke true, diubah di initialize() jika Firebase siap

  // Database Simulasi (In-Memory Mock Database)
  final List<UserModel> _mockUsers = [];
  
  final List<SymptomModel> _mockSymptoms = [
    SymptomModel(id: 's1', code: 'G001', name: 'Sering merasa lelah setelah bekerja ringan'),
    SymptomModel(id: 's2', code: 'G002', name: 'Mengalami ketegangan otot ringan di leher/bahu'),
    SymptomModel(id: 's3', code: 'G003', name: 'Merasa sulit rileks sejenak setelah aktivitas harian'),
    SymptomModel(id: 's4', code: 'G004', name: 'Mengalami sakit kepala atau pusing akibat beban pikiran'),
    SymptomModel(id: 's5', code: 'G005', name: 'Kualitas tidur menurun atau sering terbangun di malam hari'),
    SymptomModel(id: 's6', code: 'G006', name: 'Merasa tidak sabar atau mudah tersinggung karena hal sepele'),
    SymptomModel(id: 's7', code: 'G007', name: 'Mengalami kesulitan bernapas atau dada sesak tanpa sebab fisik'),
    SymptomModel(id: 's8', code: 'G008', name: 'Merasa sangat gelisah dan cemas berlebihan sepanjang waktu'),
    SymptomModel(id: 's9', code: 'G009', name: 'Mengalami gangguan pencernaan atau mual akibat tekanan mental'),
    SymptomModel(id: 's10', code: 'G010', name: 'Merasa sedih, hampa, dan putus asa terus-menerus sepanjang hari'),
    SymptomModel(id: 's11', code: 'G011', name: 'Kehilangan minat total terhadap hobi atau aktivitas yang disukai'),
    SymptomModel(id: 's12', code: 'G012', name: 'Merasa diri tidak berharga, bersalah, atau hidup terasa sia-sia'),
  ];

  final List<DiseaseModel> _mockDiseases = [
    DiseaseModel(
      id: 'd1',
      code: 'P001',
      name: 'Stress Ringan',
      description: 'Kondisi di mana Anda mengalami tekanan emosional ringan. Hal ini wajar dan dapat diatasi secara mandiri dengan istirahat serta relaksasi.',
      solutions: [
        'Lakukan latihan relaksasi pernapasan (Box Breathing) 5-10 menit.',
        'Tulis jurnal mood harian untuk meluapkan beban pikiran.',
        'Istirahat tidur yang cukup (7-8 jam) dan minum air putih yang cukup.'
      ],
    ),
    DiseaseModel(
      id: 'd2',
      code: 'P002',
      name: 'Stress Sedang',
      description: 'Anda mengalami tekanan mental sedang yang mulai memengaruhi rutinitas harian Anda. Diperlukan pengelolaan stres yang lebih aktif secara mandiri.',
      solutions: [
        'Lakukan aktivitas hobi atau self-care yang menyenangkan diri.',
        'Atur prioritas tugas agar tidak merasa kewalahan.',
        'Lakukan olahraga ringan secara rutin (jalan kaki 15-20 menit).',
        'Ceritakan beban pikiran Anda kepada teman atau keluarga terdekat.'
      ],
    ),
    DiseaseModel(
      id: 'd3',
      code: 'P003',
      name: 'Stress Berat',
      description: 'Tekanan mental yang Anda rasakan berada pada tingkat berat dan berisiko mengganggu kesehatan fisik serta mental Anda. Kondisi ini disarankan untuk tidak ditangani secara mandiri saja.',
      solutions: [
        'Segera konsultasikan kondisi Anda kepada Psikolog atau Psikiater profesional.',
        'Batasi paparan terhadap pemicu stres utama (pekerjaan/berita berlebih).',
        'Hubungi hotline layanan kesehatan mental darurat jika merasa kewalahan.'
      ],
    ),
    DiseaseModel(
      id: 'd4',
      code: 'P004',
      name: 'Depresi',
      description: 'Anda menunjukkan indikasi gangguan suasana hati yang mendalam (depresi). Kondisi ini memerlukan diagnosis klinis dan penanganan medis oleh tenaga profesional.',
      solutions: [
        'Sangat disarankan segera berkonsultasi dengan Psikolog klinis atau Psikiater.',
        'Jangan mendiagnosis diri sendiri atau mengisolasi diri dari orang terdekat.',
        'Jaga komunikasi aktif dengan keluarga atau orang yang Anda percayai.',
        'Ikuti terapi perilaku kognitif (CBT) di bawah bimbingan pakar.'
      ],
    ),
  ];

  final List<RuleModel> _mockRules = [
    RuleModel(id: 'r1', code: 'R001', gejalaRequired: ['G001', 'G002', 'G003'], hasilGangguan: 'P001'),
    RuleModel(id: 'r2', code: 'R002', gejalaRequired: ['G004', 'G005', 'G006'], hasilGangguan: 'P002'),
    RuleModel(id: 'r3', code: 'R003', gejalaRequired: ['G007', 'G008', 'G009'], hasilGangguan: 'P003'),
    RuleModel(id: 'r4', code: 'R004', gejalaRequired: ['G010', 'G011', 'G012'], hasilGangguan: 'P004'),
  ];

  final List<HistoryModel> _mockHistory = [];
  final List<MoodModel> _mockMoods = [];

  final List<BookModel> _mockBooks = [
    BookModel(
      id: 'b1',
      title: 'Seni Berdamai dengan Diri',
      author: 'Tim Konselor RiseUp',
      duration: '8 Menit Baca',
      coverColors: [0xFF6C63FF, 0xFF8F8AFF],
      icon: 'self_improvement',
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
    BookModel(
      id: 'b2',
      title: 'Keluar dari Lorong Depresi',
      author: 'Dr. Sarah (Pakar Mental)',
      duration: '5 Menit Baca',
      coverColors: [0xFF00C9A7, 0xFF5BE7C4],
      icon: 'wb_sunny',
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
    BookModel(
      id: 'b3',
      title: 'Buku Saku Penenang Cemas',
      author: 'Tim Psikologi RiseUp',
      duration: '6 Menit Baca',
      coverColors: [0xFFFF9F64, 0xFFFFBD96],
      icon: 'menu_book',
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
    BookModel(
      id: 'b4',
      title: 'Hal yang Perlu Dilakukan Saat Stres',
      author: 'World Health Organization (WHO)',
      duration: '12 Menit Baca',
      coverColors: [0xFF0284C7, 0xFF38BDF8],
      icon: 'health_and_safety',
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
    BookModel(
      id: 'b5',
      title: 'Melangkah di Bawah Rintik Hujan',
      author: 'Aria Rinata (Novelis)',
      duration: '10 Menit Baca',
      coverColors: [0xFFEF4444, 0xFFF87171],
      icon: 'self_improvement',
      chapters: [
        BookChapter(
          title: 'Bab 1: Mimpi yang Patah',
          content: 'Rendra menatap lembar penolakan itu dengan mata nanar. Surat kelima belas dari penerbit terkemuka. Ruang kerjanya yang sempit terasa semakin sesak oleh tumpukan kertas draf novelnya yang tak kunjung terbit. Baginya, mimpi menjadi seorang penulis kini terasa seperti fatamorgana di tengah gurun pasir.\n\nIa merasa dunia bergerak maju begitu cepat, meninggalkan dirinya yang terdiam di tempat. Sahabat-sahabatnya telah mapan dengan karier masing-masing, sementara ia masih berkutat dengan kata-kata yang tak menghasilkan apa-apa. Di tengah keputusasaan itu, Rendra lupa bahwa setiap pohon membutuhkan musim gugur sebelum ia bisa bersemi kembali. Ia memutuskan untuk berjalan-jalan keluar, membiarkan pikirannya yang bising ditenangkan oleh udara luar.',
        ),
        BookChapter(
          title: 'Bab 2: Pertemuan di Kedai Teh Kuno',
          content: 'Rintik hujan mulai turun membasahi jalanan kota. Rendra berteduh di sebuah kedai teh kecil berarsitektur kayu kuno yang belum pernah ia lihat sebelumnya. Di sana, ia bertemu dengan seorang nenek pembuat teh bernama Ibu Sekar.\n\nIbu Sekar menyajikan secangkir teh melati hangat. Sembari tersenyum, beliau berkata, \'Teh melati ini butuh waktu seduh yang tepat. Jika terlalu cepat, rasanya akan hambar. Jika terlalu lama, rasanya akan pahit. Begitu juga dengan hidup kita, Nak. Segala hal indah membutuhkan waktu untuk matang.\' Percakapan sederhana itu menghangatkan hati Rendra yang dingin. Ia menyadari bahwa penolakan bukanlah akhir, melainkan waktu seduh yang sedang dialaminya agar ia menjadi versi terbaik dirinya.',
        ),
        BookChapter(
          title: 'Bab 3: Menulis dengan Jiwa',
          content: 'Rendra pulang dengan semangat baru. Ia tidak lagi menulis demi pengakuan dunia atau lembaran rupiah semata, melainkan untuk meluapkan jiwanya. Ia menulis tentang Ibu Sekar, tentang kedai teh hangat, tentang rintik hujan, dan tentang jiwanya yang sempat patah.\n\nSetahun kemudian, novel barunya terbit dengan judul \'Rintik Hujan di Kedai Teh\'. Buku itu tidak hanya sukses besar secara komersial, tetapi juga menjadi penyejuk hati bagi ribuan pembaca yang sedang mengalami kegagalan. Rendra tersenyum menatap hujan di balik jendela. Ia akhirnya paham: rintik hujan tidak turun untuk merusak harimu, melainkan untuk menyuburkan tanah yang gersang.',
        ),
      ],
    ),
    BookModel(
      id: 'b6',
      title: 'Menemukan Bahagia dalam Secangkir Kopi',
      author: 'Dr. Adrian (Praktisi Mindfulness)',
      duration: '9 Menit Baca',
      coverColors: [0xFF1E293B, 0xFF475569],
      icon: 'wb_sunny',
      chapters: [
        BookChapter(
          title: 'Bab 1: Jebakan Rutinitas Bising',
          content: 'Setiap pagi, Maya terbangun dengan perasaan cemas yang sama. Suara alarm ponselnya seperti sirine tanda bahaya. Hari-harinya diisi dengan membalas ratusan surel, rapat tanpa akhir, dan mengejar target kantor yang tidak pernah selesai. Maya terjebak dalam pusaran \'burnout\'.\n\nTubuhnya ada di masa kini, namun pikirannya selalu melompat ke tugas berikutnya. Ia makan siang sembari mengetik, berjalan sembari menelepon, bahkan tidur sembari memikirkan hari esok. Hidupnya terasa hambar, seperti kopi instan murah yang diseduh terburu-buru. Maya lupa kapan terakhir kali ia benar-benar menikmati hembusan angin pagi atau rasa makanan yang dikunyahnya.',
        ),
        BookChapter(
          title: 'Bab 2: Seni Memperlambat Waktu',
          content: 'Suatu sore di hari Sabtu, Maya memutuskan untuk mematikan seluruh notifikasi ponselnya. Ia pergi ke teras rumah, menyeduh secangkir kopi hitam secara manual. Kali ini, ia berjanji pada dirinya sendiri untuk melakukan satu hal saja: meminum kopi.\n\nIa memulainya dengan menghirup aroma kopi yang mengepul hangat. Maya memperhatikan warna cokelat pekatnya, merasakan hangatnya cangkir keramik di telapak tangannya. Saat sesapan pertama menyentuh lidahnya, ia membiarkan rasa pahit dan asam kopi tertinggal sejenak sebelum menelannya. Untuk pertama kalinya setelah sekian bulan, Maya merasa \'hadir secara utuh\'. Waktu seolah memperlambat jalannya, memberikan ruang bagi jiwanya untuk bernapas bebas.',
        ),
        BookChapter(
          title: 'Bab 3: Hidup di Sini dan Saat Ini',
          content: 'Maya menyadari bahwa kebahagiaan sejati tidak terletak pada akhir pekan yang mewah atau pencapaian karier yang megah, melainkan pada kemampuan kita untuk hadir sepenuhnya di setiap momen kecil.\n\nIa mulai mempraktikkan mindfulness dalam kesehariannya: berjalan ke kantor dengan mengamati pohon-pohon di pinggir jalan, mendengarkan rekan kerja tanpa menyela, dan menikmati secangkir kopi pagi dengan penuh kesadaran. Hidupnya tidak lagi bising. Maya telah menemukan jangkar ketenangannya di tengah badai kesibukan dunia.',
        ),
      ],
    ),
    BookModel(
      id: 'b7',
      title: 'Seni Merajut Hati Setelah Berpisah',
      author: 'Tim Konselor RiseUp',
      duration: '15 Menit Baca',
      coverColors: [0xFFEF4444, 0xFFF87171],
      icon: 'self_improvement',
      chapters: [
        BookChapter(
          title: 'Bab 1: Retakan Pertama',
          content: 'Ketika hubungan berakhir, rasanya seperti ada dunia yang runtuh tiba-tiba. Keheningan yang mengikuti ucapan perpisahan itu terasa memekakkan telinga. Sadarilah bahwa shock dan kebingungan ini adalah hal yang wajar; hati Anda sedang menyesuaikan diri dengan guncangan awal.',
        ),
        BookChapter(
          title: 'Bab 2: Membiarkan Air Mata Mengalir',
          content: 'Menangis bukanlah tanda kelemahan, melainkan proses pelepasan emosi yang menumpuk. Jangan menahan air mata atau berpura-pura tegar. Berikan izin pada diri Anda untuk berduka atas kehilangan ini.',
        ),
        BookChapter(
          title: 'Bab 3: Mengakui Rasa Sakit',
          content: 'Rasa sakit pasca-perpisahan nyata adanya, baik secara emosional maupun fisik. Mengakui bahwa Anda sedang terluka adalah langkah awal untuk menyembuhkan luka tersebut. Jangan buru-buru menyangkalnya.',
        ),
        BookChapter(
          title: 'Bab 4: Menghentikan Pencarian Jawaban',
          content: 'Kita sering terjebak memikirkan "bagaimana jika" atau mencari tahu alasan detail perpisahan. Terkadang, penutupan terbaik bukanlah penjelasan dari mantan pasangan, melainkan keputusan Anda sendiri untuk merelakan.',
        ),
        BookChapter(
          title: 'Bab 5: Menjauh dari Bayang Masa Lalu',
          content: 'Jarak sangat diperlukan untuk penyembuhan. Hindari terus memeriksa media sosial mantan atau membaca ulang pesan lama. Berikan ruang bagi diri Anda untuk bernapas tanpa bayang-bayang masa lalu.',
        ),
        BookChapter(
          title: 'Bab 6: Menerima Realitas Baru',
          content: 'Hubungan itu telah usai, dan itu adalah kenyataan saat ini. Menerima kenyataan ini bukan berarti Anda menyukainya, melainkan berhenti berjuang melawan fakta yang tidak bisa diubah.',
        ),
        BookChapter(
          title: 'Bab 7: Berhenti Menyalahkan Diri',
          content: 'Satu hubungan dijalani oleh dua orang, begitu pula saat ia usai. Berhentilah menyalahkan diri sendiri atas kegagalan ini secara sepihak. Jadikan ini pelajaran berharga, bukan beban bersalah.',
        ),
        BookChapter(
          title: 'Bab 8: Menemukan Kembali Suaramu',
          content: 'Terkadang kita kehilangan sebagian identitas kita demi menyenangkan pasangan. Sekarang adalah waktu yang tepat untuk menemukan kembali apa yang Anda sukai, apa impian Anda, dan siapa diri Anda sebenarnya.',
        ),
        BookChapter(
          title: 'Bab 9: Menghargai Ruang Kosong',
          content: 'Kesepian akan datang menghampiri, terutama di malam hari. Namun, ubahlah ruang kosong ini menjadi ruang tumbuh. Kesunyian adalah tempat terbaik untuk mendengarkan kebutuhan terdalam diri Anda.',
        ),
        BookChapter(
          title: 'Bab 10: Mengurai Harapan yang Pupus',
          content: 'Merelakan berarti mengikhlaskan masa depan yang sempat Anda rencanakan bersamanya. Biarkan rencana itu pergi untuk memberi jalan bagi masa depan baru yang sedang menunggu untuk Anda tulis.',
        ),
        BookChapter(
          title: 'Bab 11: Belajar Bernapas Kembali',
          content: 'Jangan lupakan kesehatan fisik Anda. Makanlah makanan bergizi, minumlah air yang cukup, dan berjalan-jalanlah di bawah sinar matahari. Jiwa yang lelah membutuhkan tubuh yang sehat sebagai penyangganya.',
        ),
        BookChapter(
          title: 'Bab 12: Teman di Kala Sepi',
          content: 'Anda tidak harus melalui semua ini sendirian. Hubungi sahabat karib atau keluarga yang mendukung Anda. Berbagi cerita dengan orang yang tulus peduli akan meringankan separuh beban di pundak Anda.',
        ),
        BookChapter(
          title: 'Bab 13: Menulis Surat yang Tak Dikirim',
          content: 'Tuliskan semua kemarahan, kesedihan, dan kerinduan Anda di selembar kertas. Tumpahkan semuanya tanpa saringan, lalu hancurkan kertas tersebut. Ini adalah teknik pelepasan emosi yang sangat terapeutik.',
        ),
        BookChapter(
          title: 'Bab 14: Mengampuni Tanpa Kata Maaf',
          content: 'Memaafkan mantan pasangan (dan diri Anda sendiri) bukan berarti membenarkan kesalahan mereka, melainkan melepaskan racun kebencian dari hati Anda agar Anda bisa melangkah tanpa beban dendam.',
        ),
        BookChapter(
          title: 'Bab 15: Menemukan Makna dari Luka',
          content: 'Setiap luka membawa kebijaksanaan. Tanyakan pada diri Anda: "Pelajaran apa yang bisa saya ambil dari hubungan ini untuk hubungan saya di masa depan?" Kegagalan ini melatih Anda menjadi lebih dewasa.',
        ),
        BookChapter(
          title: 'Bab 16: Seni Mencintai Diri Sendiri',
          content: 'Mulailah memperlakukan diri Anda dengan penuh kasih sayang. Belilah hadiah kecil untuk diri sendiri, lakukan hobi baru, dan bicaralah pada diri Anda dengan kata-kata yang lembut dan menguatkan.',
        ),
        BookChapter(
          title: 'Bab 17: Mimpi Baru di Ujung Jalan',
          content: 'Lembaran baru telah terbuka. Tulislah tujuan hidup baru yang sepenuhnya berfokus pada kebahagiaan dan perkembangan diri Anda. Masa depan Anda masih sangat panjang dan penuh peluang.',
        ),
        BookChapter(
          title: 'Bab 18: Kebaikan Kecil Setiap Hari',
          content: 'Fokuslah pada hari ini. Lakukan satu kebaikan kecil untuk diri Anda atau orang lain setiap hari. Langkah-langkah kecil inilah yang secara perlahan akan membangun kembali hidup Anda yang baru.',
        ),
        BookChapter(
          title: 'Bab 19: Kesiapan untuk Terbuka Lagi',
          content: 'Akan tiba harinya ketika ingatan masa lalu tidak lagi terasa menyakitkan. Jangan menutup hati Anda selamanya. Ketika saatnya tiba, Anda akan siap mencintai dan dicintai lagi dengan lebih bijak.',
        ),
        BookChapter(
          title: 'Bab 20: Jiwa yang Utuh Kembali',
          content: 'Lihatlah ke belakang dan sadarilah seberapa jauh Anda telah melangkah. Anda berhasil melewati badai tersebut dan tumbuh menjadi pribadi yang lebih tangguh, bijaksana, dan utuh. Anda berharga apa adanya.',
        ),
      ],
    ),
  ];

  final StreamController<List<BookModel>> _mockBooksController = StreamController<List<BookModel>>.broadcast();

  void _updateMockBooksStream() {
    _mockBooksController.add(List.from(_mockBooks));
  }

  // StreamControllers untuk real-time update dalam mode Mock
  final StreamController<List<UserModel>> _mockUsersController = StreamController<List<UserModel>>.broadcast();
  final StreamController<List<HistoryModel>> _mockHistoryController = StreamController<List<HistoryModel>>.broadcast();

  void _updateMockUsersStream() {
    if (_mockUsers.isEmpty) {
      _mockUsers.addAll([
        UserModel(uid: 'user-1', email: 'budi@gmail.com', name: 'Budi Santoso', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 5))),
        UserModel(uid: 'user-2', email: 'siti@yahoo.com', name: 'Siti Aminah', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 4))),
        UserModel(uid: 'user-3', email: 'rudi@riseup.com', name: 'Rudi Wijaya', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 3))),
        UserModel(uid: 'user-4', email: 'ani@gmail.com', name: 'Ani Lestari', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 2))),
      ]);
    }
    _mockUsersController.add(List.from(_mockUsers));
  }

  void _updateMockHistoryStream() {
    if (_mockHistory.isEmpty) {
      _mockHistory.addAll([
        HistoryModel(
          id: 'h-1',
          userId: 'user-1',
          tanggal: DateTime.now().subtract(const Duration(hours: 4)),
          gejalaDipilih: ['G001', 'G002', 'G003'],
          hasilDiagnosis: 'Stress Ringan',
          diagnosisCode: 'P001',
          deskripsi: 'Kondisi di mana Anda mengalami tekanan emosional ringan.',
          solusi: ['Lakukan latihan relaksasi pernapasan.', 'Tulis jurnal mood.'],
        ),
        HistoryModel(
          id: 'h-2',
          userId: 'user-2',
          tanggal: DateTime.now().subtract(const Duration(hours: 12)),
          gejalaDipilih: ['G004', 'G005', 'G006'],
          hasilDiagnosis: 'Stress Sedang',
          diagnosisCode: 'P002',
          deskripsi: 'Mengalami tekanan mental sedang.',
          solusi: ['Lakukan hobi.', 'Ceritakan beban pikiran.'],
        ),
        HistoryModel(
          id: 'h-3',
          userId: 'user-3',
          tanggal: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          gejalaDipilih: ['G010', 'G011', 'G012'],
          hasilDiagnosis: 'Depresi',
          diagnosisCode: 'P004',
          deskripsi: 'Menunjukkan indikasi depresi.',
          solusi: ['Konsultasi dengan Psikolog.', 'Ikuti terapi CBT.'],
        ),
      ]);
    }
    _mockHistoryController.add(List.from(_mockHistory)..sort((a, b) => b.tanggal.compareTo(a.tanggal)));
  }

  bool get useMock => _useMock;

  Future<void> initialize() async {
    try {
      _db = FirebaseFirestore.instance;
      _useMock = false;
      debugPrint("Firestore berhasil diinisialisasi.");
    } catch (e) {
      debugPrint("Gagal menginisialisasi Firestore: $e");
      debugPrint("Beralih ke MODE SIMULASI (MOCK MODE).");
      _useMock = true;
    }
  }

  void setUseMock(bool value) {
    _useMock = value;
    if (!value && _db == null) {
      _db = FirebaseFirestore.instance;
    }
  }

  Future<void> seedDefaultData() async {
    if (_useMock || _db == null) return;
    
    // 1. Hapus hanya dokumen duplikat default yang ber-ID acak agar data kustom tidak hilang
    final defaultSymptomCodes = _mockSymptoms.map((e) => e.code).toSet();
    final gejalaSnap = await _db!.collection('gejala').get();
    for (final doc in gejalaSnap.docs) {
      final code = doc.data()['code'] as String?;
      if (code != null && defaultSymptomCodes.contains(code) && doc.id != code) {
        await doc.reference.delete();
      }
    }
    
    final defaultDiseaseCodes = _mockDiseases.map((e) => e.code).toSet();
    final gangguanSnap = await _db!.collection('gangguan').get();
    for (final doc in gangguanSnap.docs) {
      final code = doc.data()['code'] as String?;
      if (code != null && defaultDiseaseCodes.contains(code) && doc.id != code) {
        await doc.reference.delete();
      }
    }
    
    final defaultRuleCodes = _mockRules.map((e) => e.code).toSet();
    final aturanSnap = await _db!.collection('aturan').get();
    for (final doc in aturanSnap.docs) {
      final code = doc.data()['code'] as String?;
      if (code != null && defaultRuleCodes.contains(code) && doc.id != code) {
        await doc.reference.delete();
      }
    }

    final defaultBookTitles = _mockBooks.map((e) => e.title).toSet();
    final bukuSnap = await _db!.collection('buku').get();
    for (final doc in bukuSnap.docs) {
      final title = doc.data()['title'] as String?;
      if (title != null && defaultBookTitles.contains(title)) {
        if (doc.id != 'b1' && doc.id != 'b2' && doc.id != 'b3' && doc.id != 'b4' && doc.id != 'b5' && doc.id != 'b6' && doc.id != 'b7') {
          await doc.reference.delete();
        }
      }
    }
    
    final batch = _db!.batch();
    
    // Seed symptoms
    for (final s in _mockSymptoms) {
      final docRef = _db!.collection('gejala').doc(s.code);
      batch.set(docRef, s.toMap());
    }
    
    // Seed diseases
    for (final d in _mockDiseases) {
      final docRef = _db!.collection('gangguan').doc(d.code);
      batch.set(docRef, d.toMap());
    }
    
    // Seed rules
    for (final r in _mockRules) {
      final docRef = _db!.collection('aturan').doc(r.code);
      batch.set(docRef, r.toMap());
    }

    // Seed books
    for (final b in _mockBooks) {
      final docRef = _db!.collection('buku').doc(b.id);
      batch.set(docRef, b.toMap());
    }
    
    await batch.commit();
    debugPrint("Berhasil melakukan auto-seed data gejala, gangguan, aturan, dan buku ke Firestore.");
  }

  // --- Users CRUD ---
  Future<void> createUserProfile(UserModel user) async {
    if (_useMock) {
      _mockUsers.removeWhere((u) => u.uid == user.uid);
      _mockUsers.add(user);
      _updateMockUsersStream();
    } else {
      await _db!.collection('users').doc(user.uid).set(user.toMap());
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    if (_useMock) {
      try {
        return _mockUsers.firstWhere((u) => u.uid == uid);
      } catch (e) {
        if (uid == 'mock-admin-1') {
          return UserModel(
            uid: 'mock-admin-1',
            email: 'admin@riseup.com',
            name: 'Dr. Sarah (Pakar)',
            role: 'admin',
            createdAt: DateTime.now(),
          );
        }
        return UserModel(
          uid: uid,
          email: 'user@riseup.com',
          name: 'User Demo',
          role: 'user',
          createdAt: DateTime.now(),
        );
      }
    } else {
      final doc = await _db!.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    }
  }

  Future<void> deleteUser(String uid) async {
    if (_useMock) {
      _mockUsers.removeWhere((u) => u.uid == uid);
      _mockHistory.removeWhere((h) => h.userId == uid);
      _mockMoods.removeWhere((m) => m.userId == uid);
      _updateMockUsersStream();
      _updateMockHistoryStream();
    } else {
      // 1. Hapus dokumen profil user
      await _db!.collection('users').doc(uid).delete();
      
      // 2. Hapus seluruh riwayat skrining user
      final historySnap = await _db!.collection('riwayat_tes').where('userId', isEqualTo: uid).get();
      final historyBatch = _db!.batch();
      for (final doc in historySnap.docs) {
        historyBatch.delete(doc.reference);
      }
      await historyBatch.commit();

      // 3. Hapus seluruh catatan mood tracker user
      final moodSnap = await _db!.collection('mood_tracker').where('userId', isEqualTo: uid).get();
      final moodBatch = _db!.batch();
      for (final doc in moodSnap.docs) {
        moodBatch.delete(doc.reference);
      }
      await moodBatch.commit();
    }
  }

  // --- Admin Queries ---
  Future<List<UserModel>> getAllUsers() async {
    if (_useMock) {
      if (_mockUsers.isEmpty) {
        _mockUsers.addAll([
          UserModel(uid: 'user-1', email: 'budi@gmail.com', name: 'Budi Santoso', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 5))),
          UserModel(uid: 'user-2', email: 'siti@yahoo.com', name: 'Siti Aminah', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 4))),
          UserModel(uid: 'user-3', email: 'rudi@riseup.com', name: 'Rudi Wijaya', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 3))),
          UserModel(uid: 'user-4', email: 'ani@gmail.com', name: 'Ani Lestari', role: 'user', createdAt: DateTime.now().subtract(const Duration(days: 2))),
        ]);
      }
      return List.from(_mockUsers);
    } else {
      final snap = await _db!.collection('users').get();
      return snap.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  Future<List<HistoryModel>> getAllHistory() async {
    if (_useMock) {
      if (_mockHistory.isEmpty) {
        _mockHistory.addAll([
          HistoryModel(
            id: 'h-1',
            userId: 'user-1',
            tanggal: DateTime.now().subtract(const Duration(hours: 4)),
            gejalaDipilih: ['G001', 'G002', 'G003'],
            hasilDiagnosis: 'Stress Ringan',
            diagnosisCode: 'P001',
            deskripsi: 'Kondisi di mana Anda mengalami tekanan emosional ringan.',
            solusi: ['Lakukan latihan relaksasi pernapasan.', 'Tulis jurnal mood.'],
          ),
          HistoryModel(
            id: 'h-2',
            userId: 'user-2',
            tanggal: DateTime.now().subtract(const Duration(hours: 12)),
            gejalaDipilih: ['G004', 'G005', 'G006'],
            hasilDiagnosis: 'Stress Sedang',
            diagnosisCode: 'P002',
            deskripsi: 'Mengalami tekanan mental sedang.',
            solusi: ['Lakukan hobi.', 'Ceritakan beban pikiran.'],
          ),
          HistoryModel(
            id: 'h-3',
            userId: 'user-3',
            tanggal: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
            gejalaDipilih: ['G010', 'G011', 'G012'],
            hasilDiagnosis: 'Depresi',
            diagnosisCode: 'P004',
            deskripsi: 'Menunjukkan indikasi depresi.',
            solusi: ['Konsultasi dengan Psikolog.', 'Ikuti terapi CBT.'],
          ),
        ]);
      }
      return List.from(_mockHistory)..sort((a, b) => b.tanggal.compareTo(a.tanggal));
    } else {
      final snap = await _db!.collection('riwayat_tes').orderBy('tanggal', descending: true).get();
      return snap.docs.map((doc) => HistoryModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  // Stream users untuk update real-time
  Stream<List<UserModel>> getUsersStream() {
    if (_useMock) {
      _updateMockUsersStream();
      return _mockUsersController.stream;
    } else {
      return _db!.collection('users').snapshots().map((snap) =>
          snap.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList());
    }
  }

  // Stream riwayat untuk update real-time
  Stream<List<HistoryModel>> getHistoryStream() {
    if (_useMock) {
      _updateMockHistoryStream();
      return _mockHistoryController.stream;
    } else {
      return _db!.collection('riwayat_tes').orderBy('tanggal', descending: true).snapshots().map((snap) =>
          snap.docs.map((doc) => HistoryModel.fromMap(doc.data(), doc.id)).toList());
    }
  }

  // Stream buku/novel untuk update real-time
  Stream<List<BookModel>> getBooksStream() {
    if (_useMock) {
      Timer(Duration.zero, () => _updateMockBooksStream());
      return _mockBooksController.stream;
    } else {
      return _db!.collection('buku').snapshots().map((snap) =>
          snap.docs.map((doc) => BookModel.fromMap(doc.data(), doc.id)).toList());
    }
  }

  // --- Symptoms CRUD ---
  Future<List<SymptomModel>> getSymptoms() async {
    if (_useMock) {
      return List.from(_mockSymptoms);
    } else {
      final snap = await _db!.collection('gejala').orderBy('code').get();
      return snap.docs.map((doc) => SymptomModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  Future<void> addSymptom(SymptomModel symptom) async {
    if (_useMock) {
      final newSymptom = SymptomModel(
        id: 'mock-s-${DateTime.now().millisecondsSinceEpoch}',
        code: symptom.code,
        name: symptom.name,
      );
      _mockSymptoms.add(newSymptom);
      _mockSymptoms.sort((a, b) => a.code.compareTo(b.code));
    } else {
      await _db!.collection('gejala').doc(symptom.code).set(symptom.toMap());
    }
  }

  Future<void> deleteSymptom(String id) async {
    if (_useMock) {
      _mockSymptoms.removeWhere((s) => s.id == id);
    } else {
      await _db!.collection('gejala').doc(id).delete();
    }
  }

  Future<void> updateSymptom(SymptomModel symptom) async {
    if (_useMock) {
      final idx = _mockSymptoms.indexWhere((s) => s.id == symptom.id);
      if (idx != -1) {
        _mockSymptoms[idx] = symptom;
        _mockSymptoms.sort((a, b) => a.code.compareTo(b.code));
      }
    } else {
      await _db!.collection('gejala').doc(symptom.id).update(symptom.toMap());
    }
  }

  // --- Diseases CRUD ---
  Future<List<DiseaseModel>> getDiseases() async {
    if (_useMock) {
      return List.from(_mockDiseases);
    } else {
      final snap = await _db!.collection('gangguan').orderBy('code').get();
      return snap.docs.map((doc) => DiseaseModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  Future<void> addDisease(DiseaseModel disease) async {
    if (_useMock) {
      final newDisease = DiseaseModel(
        id: 'mock-d-${DateTime.now().millisecondsSinceEpoch}',
        code: disease.code,
        name: disease.name,
        description: disease.description,
        solutions: disease.solutions,
      );
      _mockDiseases.add(newDisease);
      _mockDiseases.sort((a, b) => a.code.compareTo(b.code));
    } else {
      await _db!.collection('gangguan').doc(disease.code).set(disease.toMap());
    }
  }

  Future<void> deleteDisease(String id) async {
    if (_useMock) {
      _mockDiseases.removeWhere((d) => d.id == id);
    } else {
      await _db!.collection('gangguan').doc(id).delete();
    }
  }

  Future<void> updateDisease(DiseaseModel disease) async {
    if (_useMock) {
      final idx = _mockDiseases.indexWhere((d) => d.id == disease.id);
      if (idx != -1) {
        _mockDiseases[idx] = disease;
        _mockDiseases.sort((a, b) => a.code.compareTo(b.code));
      }
    } else {
      await _db!.collection('gangguan').doc(disease.id).update(disease.toMap());
    }
  }

  // --- Rules CRUD ---
  Future<List<RuleModel>> getRules() async {
    if (_useMock) {
      return List.from(_mockRules);
    } else {
      final snap = await _db!.collection('aturan').orderBy('code').get();
      return snap.docs.map((doc) => RuleModel.fromMap(doc.data(), doc.id)).toList();
    }
  }

  Future<void> addRule(RuleModel rule) async {
    if (_useMock) {
      final newRule = RuleModel(
        id: 'mock-r-${DateTime.now().millisecondsSinceEpoch}',
        code: rule.code,
        gejalaRequired: rule.gejalaRequired,
        hasilGangguan: rule.hasilGangguan,
      );
      _mockRules.add(newRule);
      _mockRules.sort((a, b) => a.code.compareTo(b.code));
    } else {
      await _db!.collection('aturan').doc(rule.code).set(rule.toMap());
    }
  }

  Future<void> deleteRule(String id) async {
    if (_useMock) {
      _mockRules.removeWhere((r) => r.id == id);
    } else {
      await _db!.collection('aturan').doc(id).delete();
    }
  }

  Future<void> updateRule(RuleModel rule) async {
    if (_useMock) {
      final idx = _mockRules.indexWhere((r) => r.id == rule.id);
      if (idx != -1) {
        _mockRules[idx] = rule;
        _mockRules.sort((a, b) => a.code.compareTo(b.code));
      }
    } else {
      await _db!.collection('aturan').doc(rule.id).update(rule.toMap());
    }
  }

  // --- Diagnostic History CRUD ---
  Future<List<HistoryModel>> getHistory(String userId) async {
    if (_useMock) {
      final list = _mockHistory.where((h) => h.userId == userId).toList();
      if (list.isEmpty) {
        // Pre-populate a default history for this user so they see a sample diagnosis
        final sampleHistory = HistoryModel(
          id: 'mock-h-default-$userId',
          userId: userId,
          tanggal: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          gejalaDipilih: ['G001', 'G002', 'G003'],
          hasilDiagnosis: 'Stress Ringan',
          diagnosisCode: 'P001',
          deskripsi: 'Kondisi di mana Anda mengalami tekanan emosional ringan. Hal ini wajar dan dapat diatasi secara mandiri dengan istirahat serta relaksasi.',
          solusi: [
            'Lakukan latihan relaksasi pernapasan (Box Breathing) 5-10 menit.',
            'Tulis jurnal mood harian untuk meluapkan beban pikiran.',
            'Istirahat tidur yang cukup (7-8 jam) dan minum air putih yang cukup.'
          ],
        );
        _mockHistory.add(sampleHistory);
        return [sampleHistory];
      }
      list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      return list;
    } else {
      final snap = await _db!
          .collection('riwayat_tes')
          .where('userId', isEqualTo: userId)
          .get();
      final list = snap.docs.map((doc) => HistoryModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.tanggal.compareTo(a.tanggal)); // Urutkan terbaru dahulu di memori
      return list;
    }
  }

  Future<void> addHistory(HistoryModel history) async {
    if (_useMock) {
      _mockHistory.add(HistoryModel(
        id: 'mock-h-${DateTime.now().millisecondsSinceEpoch}',
        userId: history.userId,
        tanggal: history.tanggal,
        gejalaDipilih: history.gejalaDipilih,
        hasilDiagnosis: history.hasilDiagnosis,
        diagnosisCode: history.diagnosisCode,
        deskripsi: history.deskripsi,
        solusi: history.solusi,
      ));
      _updateMockHistoryStream();
    } else {
      await _db!.collection('riwayat_tes').add(history.toMap());
    }
  }

  Future<void> addHistoryBatch(List<HistoryModel> histories) async {
    if (_useMock) {
      for (final history in histories) {
        _mockHistory.add(HistoryModel(
          id: 'mock-h-${DateTime.now().millisecondsSinceEpoch}-${history.tanggal.millisecondsSinceEpoch}',
          userId: history.userId,
          tanggal: history.tanggal,
          gejalaDipilih: history.gejalaDipilih,
          hasilDiagnosis: history.hasilDiagnosis,
          diagnosisCode: history.diagnosisCode,
          deskripsi: history.deskripsi,
          solusi: history.solusi,
        ));
      }
      _updateMockHistoryStream();
    } else {
      final batch = _db!.batch();
      for (final history in histories) {
        final docRef = _db!.collection('riwayat_tes').doc();
        batch.set(docRef, history.toMap());
      }
      await batch.commit();
    }
  }

  // --- Mood Tracker CRUD ---
  Future<List<MoodModel>> getMoods(String userId) async {
    if (_useMock) {
      final list = _mockMoods.where((m) => m.userId == userId).toList();
      if (list.isEmpty) {
        // Pre-populate mock moods for the user so the trend immediately works for testing!
        final now = DateTime.now();
        _mockMoods.addAll([
          MoodModel(id: 'm-1', userId: userId, tanggal: now.subtract(const Duration(days: 4)), moodLevel: 3, catatan: 'Hari yang cukup biasa.'),
          MoodModel(id: 'm-2', userId: userId, tanggal: now.subtract(const Duration(days: 3)), moodLevel: 4, catatan: 'Belajar Flutter hari ini, menyenangkan!'),
          MoodModel(id: 'm-3', userId: userId, tanggal: now.subtract(const Duration(days: 2)), moodLevel: 2, catatan: 'Sedikit lelah karena kurang tidur.'),
          MoodModel(id: 'm-4', userId: userId, tanggal: now.subtract(const Duration(days: 1)), moodLevel: 4, catatan: 'Olahraga sore sangat membantu mood.'),
          MoodModel(id: 'm-5', userId: userId, tanggal: now, moodLevel: 5, catatan: 'Sangat senang hari ini karena semua berjalan lancar!'),
        ]);
        final populatedList = _mockMoods.where((m) => m.userId == userId).toList();
        populatedList.sort((a, b) => a.tanggal.compareTo(b.tanggal));
        return populatedList;
      }
      list.sort((a, b) => a.tanggal.compareTo(b.tanggal));
      return list;
    } else {
      final snap = await _db!
          .collection('mood_tracker')
          .where('userId', isEqualTo: userId)
          .get();
      final list = snap.docs.map((doc) => MoodModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => a.tanggal.compareTo(b.tanggal)); // Urutkan terlama ke terbaru di memori
      return list;
    }
  }

  Future<void> addMood(MoodModel mood) async {
    if (_useMock) {
      _mockMoods.add(MoodModel(
        id: 'mock-m-${DateTime.now().millisecondsSinceEpoch}',
        userId: mood.userId,
        tanggal: mood.tanggal,
        moodLevel: mood.moodLevel,
        catatan: mood.catatan,
      ));
    } else {
      await _db!.collection('mood_tracker').add(mood.toMap());
    }
  }

  Future<void> addMoodsBatch(List<MoodModel> moods) async {
    if (_useMock) {
      for (final mood in moods) {
        _mockMoods.add(MoodModel(
          id: 'mock-m-${DateTime.now().millisecondsSinceEpoch}-${mood.tanggal.millisecondsSinceEpoch}',
          userId: mood.userId,
          tanggal: mood.tanggal,
          moodLevel: mood.moodLevel,
          catatan: mood.catatan,
        ));
      }
    } else {
      final batch = _db!.batch();
      for (final mood in moods) {
        final docRef = _db!.collection('mood_tracker').doc();
        batch.set(docRef, mood.toMap());
      }
      await batch.commit();
    }
  }

  Future<void> clearUserTestData(String userId) async {
    if (_useMock) {
      _mockHistory.removeWhere((h) => h.userId == userId);
      _mockMoods.removeWhere((m) => m.userId == userId);
      _updateMockHistoryStream();
    } else {
      // 1. Hapus riwayat tes
      final historySnap = await _db!.collection('riwayat_tes').where('userId', isEqualTo: userId).get();
      final historyBatch = _db!.batch();
      for (final doc in historySnap.docs) {
        historyBatch.delete(doc.reference);
      }
      await historyBatch.commit();

      // 2. Hapus mood tracker
      final moodSnap = await _db!.collection('mood_tracker').where('userId', isEqualTo: userId).get();
      final moodBatch = _db!.batch();
      for (final doc in moodSnap.docs) {
        moodBatch.delete(doc.reference);
      }
      await moodBatch.commit();
    }
  }

  // --- Posters CRUD ---
  final List<String> _mockPosters = [
    'assets/poster/poster1.jpg',
    'assets/poster/poster3.jpg',
    'assets/poster/poster4.jpg',
    'assets/poster/posterr5.jpg',
  ];
  
  final StreamController<List<String>> _mockPostersController = StreamController<List<String>>.broadcast();

  void _updateMockPostersStream() {
    _mockPostersController.add(List.from(_mockPosters));
  }

  Stream<List<String>> getPostersStream() {
    if (_useMock) {
      Timer(Duration.zero, () => _updateMockPostersStream());
      return _mockPostersController.stream;
    } else {
      return _db!.collection('posters').snapshots().map((snap) {
        if (snap.docs.isEmpty) {
          return [
            'assets/poster/poster1.jpg',
            'assets/poster/poster3.jpg',
            'assets/poster/poster4.jpg',
            'assets/poster/posterr5.jpg',
          ];
        }
        return snap.docs.map((doc) => doc.data()['path'] as String).toList();
      });
    }
  }

  Future<List<String>> getPosters() async {
    if (_useMock) {
      return List.from(_mockPosters);
    } else {
      final snap = await _db!.collection('posters').get();
      if (snap.docs.isEmpty) {
        return [
          'assets/poster/poster1.jpg',
          'assets/poster/poster3.jpg',
          'assets/poster/poster4.jpg',
          'assets/poster/posterr5.jpg',
        ];
      }
      return snap.docs.map((doc) => doc.data()['path'] as String).toList();
    }
  }

  Future<void> addPoster(String path) async {
    if (_useMock) {
      if (!_mockPosters.contains(path)) {
        _mockPosters.add(path);
        _updateMockPostersStream();
      }
    } else {
      final existing = await _db!.collection('posters').where('path', isEqualTo: path).get();
      if (existing.docs.isEmpty) {
        await _db!.collection('posters').add({'path': path, 'createdAt': FieldValue.serverTimestamp()});
      }
    }
  }

  Future<void> deletePoster(String path) async {
    if (_useMock) {
      _mockPosters.remove(path);
      _updateMockPostersStream();
    } else {
      final snap = await _db!.collection('posters').where('path', isEqualTo: path).get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    }
  }

  // --- Motivations CRUD ---
  final List<String> _mockMotivations = [
    'Kesehatan mentalmu adalah prioritas. Menyadari gejala lebih awal adalah langkah bijak.',
    'Tidak apa-apa untuk tidak merasa baik-baik saja. Kamu tidak harus berpura-pura kuat sepanjang waktu.',
    'Satu langkah kecil menuju perawatan diri hari ini adalah kemenangan besar bagi mentalmu.',
    'Kesehatan mental bukanlah tujuan akhir, melainkan sebuah perjalanan harian yang patut disyukuri.',
    'Tarik napas dalam-dalam, hembuskan perlahan. Hari ini baru dimulai, dan kamu sanggup menjalaninya.',
    'Mencintai diri sendiri berarti menerima bahwa kamu juga berhak untuk beristirahat dan pulih.',
    'Pikiranmu bisa menjadi tempat yang damai jika kamu memperlakukannya dengan kebaikan dan kesabaran.',
    'Kamu berharga, tidak peduli seberapa berat hari-hari yang sedang kamu lalui saat ini.'
  ];

  final StreamController<List<String>> _mockMotivationsController = StreamController<List<String>>.broadcast();

  void _updateMockMotivationsStream() {
    _mockMotivationsController.add(List.from(_mockMotivations));
  }

  Stream<List<String>> getMotivationsStream() {
    if (_useMock) {
      Timer(Duration.zero, () => _updateMockMotivationsStream());
      return _mockMotivationsController.stream;
    } else {
      return _db!.collection('motivations').snapshots().map((snap) {
        if (snap.docs.isEmpty) {
          return [
            'Kesehatan mentalmu adalah prioritas. Menyadari gejala lebih awal adalah langkah bijak.',
            'Tidak apa-apa untuk tidak merasa baik-baik saja. Kamu tidak harus berpura-pura kuat sepanjang waktu.',
            'Satu langkah kecil menuju perawatan diri hari ini adalah kemenangan besar bagi mentalmu.',
            'Kesehatan mental bukanlah tujuan akhir, melainkan sebuah perjalanan harian yang patut disyukuri.',
            'Tarik napas dalam-dalam, hembuskan perlahan. Hari ini baru dimulai, dan kamu sanggup menjalaninya.',
            'Mencintai diri sendiri berarti menerima bahwa kamu juga berhak untuk beristirahat dan pulih.',
            'Pikiranmu bisa menjadi tempat yang damai jika kamu memperlakukannya dengan kebaikan dan kesabaran.',
            'Kamu berharga, tidak peduli seberapa berat hari-hari yang sedang kamu lalui saat ini.'
          ];
        }
        return snap.docs.map((doc) => doc.data()['text'] as String).toList();
      });
    }
  }

  Future<List<String>> getMotivations() async {
    if (_useMock) {
      return List.from(_mockMotivations);
    } else {
      final snap = await _db!.collection('motivations').get();
      if (snap.docs.isEmpty) {
        return [
          'Kesehatan mentalmu adalah prioritas. Menyadari gejala lebih awal adalah langkah bijak.',
          'Tidak apa-apa untuk tidak merasa baik-baik saja. Kamu tidak harus berpura-pura kuat sepanjang waktu.',
          'Satu langkah kecil menuju perawatan diri hari ini adalah kemenangan besar bagi mentalmu.',
          'Kesehatan mental bukanlah tujuan akhir, melainkan sebuah perjalanan harian yang patut disyukuri.',
          'Tarik napas dalam-dalam, hembuskan perlahan. Hari ini baru dimulai, dan kamu sanggup menjalaninya.',
          'Mencintai diri sendiri berarti menerima bahwa kamu juga berhak untuk beristirahat dan pulih.',
          'Pikiranmu bisa menjadi tempat yang damai jika kamu memperlakukannya dengan kebaikan dan kesabaran.',
          'Kamu berharga, tidak peduli seberapa berat hari-hari yang sedang kamu lalui saat ini.'
        ];
      }
      return snap.docs.map((doc) => doc.data()['text'] as String).toList();
    }
  }

  Future<void> addMotivation(String text) async {
    if (_useMock) {
      if (!_mockMotivations.contains(text)) {
        _mockMotivations.add(text);
        _updateMockMotivationsStream();
      }
    } else {
      final existing = await _db!.collection('motivations').where('text', isEqualTo: text).get();
      if (existing.docs.isEmpty) {
        await _db!.collection('motivations').add({'text': text, 'createdAt': FieldValue.serverTimestamp()});
      }
    }
  }

  Future<void> deleteMotivation(String text) async {
    if (_useMock) {
      _mockMotivations.remove(text);
      _updateMockMotivationsStream();
    } else {
      final snap = await _db!.collection('motivations').where('text', isEqualTo: text).get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    }
  }

  // --- Books CRUD ---
  Future<void> addBook(BookModel book) async {
    if (_useMock) {
      final newBook = BookModel(
        id: 'mock-b-${DateTime.now().millisecondsSinceEpoch}',
        title: book.title,
        author: book.author,
        duration: book.duration,
        coverColors: book.coverColors,
        icon: book.icon,
        chapters: book.chapters,
      );
      _mockBooks.add(newBook);
      _updateMockBooksStream();
    } else {
      final docRef = _db!.collection('buku').doc();
      final newBook = BookModel(
        id: docRef.id,
        title: book.title,
        author: book.author,
        duration: book.duration,
        coverColors: book.coverColors,
        icon: book.icon,
        chapters: book.chapters,
      );
      await docRef.set(newBook.toMap());
    }
  }

  Future<void> updateBook(BookModel book) async {
    if (_useMock) {
      final idx = _mockBooks.indexWhere((b) => b.id == book.id);
      if (idx != -1) {
        _mockBooks[idx] = book;
        _updateMockBooksStream();
      }
    } else {
      await _db!.collection('buku').doc(book.id).set(book.toMap());
    }
  }

  Future<void> deleteBook(String id) async {
    if (_useMock) {
      _mockBooks.removeWhere((b) => b.id == id);
      _updateMockBooksStream();
    } else {
      await _db!.collection('buku').doc(id).delete();
    }
  }
}
