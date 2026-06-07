class HistoryModel {
  final String id;
  final String userId;
  final DateTime tanggal;
  final List<String> gejalaDipilih; // List kode gejala, misal: ['G001', 'G003']
  final String hasilDiagnosis; // Nama gangguan, misal: 'Depresi Ringan' atau 'Tidak Terdeteksi'
  final String diagnosisCode; // Kode gangguan, misal: 'P001'
  final String deskripsi;
  final List<String> solusi;

  HistoryModel({
    required this.id,
    required this.userId,
    required this.tanggal,
    required this.gejalaDipilih,
    required this.hasilDiagnosis,
    required this.diagnosisCode,
    required this.deskripsi,
    required this.solusi,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return HistoryModel(
      id: id,
      userId: map['userId'] ?? '',
      tanggal: map['tanggal'] != null
          ? (map['tanggal'] as dynamic).toDate()
          : DateTime.now(),
      gejalaDipilih: List<String>.from(map['gejalaDipilih'] ?? []),
      hasilDiagnosis: map['hasilDiagnosis'] ?? 'Tidak Terdeteksi',
      diagnosisCode: map['diagnosisCode'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      solusi: List<String>.from(map['solusi'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tanggal': tanggal,
      'gejalaDipilih': gejalaDipilih,
      'hasilDiagnosis': hasilDiagnosis,
      'diagnosisCode': diagnosisCode,
      'deskripsi': deskripsi,
      'solusi': solusi,
    };
  }
}
