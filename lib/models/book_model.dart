class BookChapter {
  final String title;
  final String content;
  final String textAlign;

  BookChapter({
    required this.title,
    required this.content,
    this.textAlign = 'left',
  });

  factory BookChapter.fromMap(Map<String, dynamic> map) {
    return BookChapter(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      textAlign: map['textAlign'] ?? 'left',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'textAlign': textAlign,
    };
  }
}

class BookModel {
  final String id;
  final String title;
  final String author;
  final String duration;
  final List<int> coverColors;
  final String icon;
  final List<BookChapter> chapters;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.duration,
    required this.coverColors,
    required this.icon,
    required this.chapters,
  });

  factory BookModel.fromMap(Map<String, dynamic> map, String id) {
    var rawChapters = map['chapters'] as List<dynamic>? ?? [];
    List<BookChapter> parsedChapters = rawChapters
        .map((c) => BookChapter.fromMap(Map<String, dynamic>.from(c)))
        .toList();

    var rawColors = map['coverColors'] as List<dynamic>? ?? [];
    List<int> parsedColors = rawColors.map((c) => (c as num).toInt()).toList();

    return BookModel(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      duration: map['duration'] ?? '',
      coverColors: parsedColors,
      icon: map['icon'] ?? 'menu_book',
      chapters: parsedChapters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'duration': duration,
      'coverColors': coverColors,
      'icon': icon,
      'chapters': chapters.map((c) => c.toMap()).toList(),
    };
  }
}
