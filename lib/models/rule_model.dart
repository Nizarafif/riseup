class RuleModel {
  final String id;
  final String code; // Contoh: 'R001'
  final List<String> gejalaRequired; // Contoh: ['G001', 'G002', 'G005']
  final String hasilGangguan; // Contoh: 'P001'

  RuleModel({
    required this.id,
    required this.code,
    required this.gejalaRequired,
    required this.hasilGangguan,
  });

  factory RuleModel.fromMap(Map<String, dynamic> map, String id) {
    return RuleModel(
      id: id,
      code: map['code'] ?? '',
      gejalaRequired: List<String>.from(map['gejalaRequired'] ?? []),
      hasilGangguan: map['hasilGangguan'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'gejalaRequired': gejalaRequired,
      'hasilGangguan': hasilGangguan,
    };
  }
}
