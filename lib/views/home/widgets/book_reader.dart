import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/book_model.dart';
import '../../../services/firestore_service.dart';

IconData getBookIcon(String iconName) {
  switch (iconName) {
    case 'self_improvement':
      return Icons.self_improvement_rounded;
    case 'wb_sunny':
      return Icons.wb_sunny_rounded;
    case 'menu_book':
      return Icons.menu_book_rounded;
    case 'health_and_safety':
      return Icons.health_and_safety_rounded;
    default:
      return Icons.menu_book_rounded;
  }
}

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
            StreamBuilder<List<BookModel>>(
              stream: FirestoreService().getBooksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                      ),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Gagal memuat buku: ${snapshot.error}',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  );
                }
                
                final books = snapshot.data ?? [];
                if (books.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Tidak ada buku tersedia saat ini.',
                        style: TextStyle(color: subtitleColor),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: books.length,
                  itemBuilder: (context, idx) {
                    final book = books[idx];
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
                                    colors: book.coverColors.map((c) => Color(c)).toList(),
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
                                    getBookIcon(book.icon),
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

  TextAlign _getTextAlign(String alignName) {
    switch (alignName) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      case 'left':
      default:
        return TextAlign.left;
    }
  }

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
                    textAlign: _getTextAlign(chapter.textAlign),
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
