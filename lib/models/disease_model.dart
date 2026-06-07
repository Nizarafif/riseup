class DiseaseModel {
  final String id;
  final String code; // Contoh: 'P001'
  final String name; // Contoh: 'Gangguan Depresi Sedang'
  final String description;
  final List<String> solutions;

  DiseaseModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.solutions,
  });

  factory DiseaseModel.fromMap(Map<String, dynamic> map, String id) {
    return DiseaseModel(
      id: id,
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      solutions: List<String>.from(map['solutions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'solutions': solutions,
    };
  }
}
