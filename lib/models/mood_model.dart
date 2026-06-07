class MoodModel {
  final String id;
  final String userId;
  final DateTime tanggal;
  final int moodLevel; // 1 (Sangat Buruk) s.d 5 (Sangat Baik)
  final String catatan;

  MoodModel({
    required this.id,
    required this.userId,
    required this.tanggal,
    required this.moodLevel,
    required this.catatan,
  });

  factory MoodModel.fromMap(Map<String, dynamic> map, String id) {
    return MoodModel(
      id: id,
      userId: map['userId'] ?? '',
      tanggal: map['tanggal'] != null
          ? (map['tanggal'] as dynamic).toDate()
          : DateTime.now(),
      moodLevel: map['moodLevel'] ?? 3,
      catatan: map['catatan'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tanggal': tanggal,
      'moodLevel': moodLevel,
      'catatan': catatan,
    };
  }
}
