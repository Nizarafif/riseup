class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'user' atau 'admin'
  final DateTime createdAt;
  final int avatarIndex;
  final String photoUrl;
  final int paletteIndex;
  final int emojiThemeIndex;
  final int backgroundThemeIndex;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.avatarIndex = 0,
    this.photoUrl = "",
    this.paletteIndex = 0,
    this.emojiThemeIndex = 0,
    this.backgroundThemeIndex = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      avatarIndex: map['avatarIndex'] ?? 0,
      photoUrl: map['photoUrl'] ?? "",
      paletteIndex: map['paletteIndex'] ?? 0,
      emojiThemeIndex: map['emojiThemeIndex'] ?? 0,
      backgroundThemeIndex: map['backgroundThemeIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt,
      'avatarIndex': avatarIndex,
      'photoUrl': photoUrl,
      'paletteIndex': paletteIndex,
      'emojiThemeIndex': emojiThemeIndex,
      'backgroundThemeIndex': backgroundThemeIndex,
    };
  }
}
