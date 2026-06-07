class SymptomModel {
  final String id;
  final String code; // Contoh: 'G001'
  final String name; // Contoh: 'Merasa cemas berlebihan tanpa alasan jelas'

  SymptomModel({
    required this.id,
    required this.code,
    required this.name,
  });

  factory SymptomModel.fromMap(Map<String, dynamic> map, String id) {
    return SymptomModel(
      id: id,
      code: map['code'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
    };
  }

  // Helper untuk membandingkan gejala berdasarkan kode
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
