class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isOnline;
  final DateTime? lastSeen;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'isOnline': isOnline,
    'lastSeen': lastSeen?.toIso8601String(),
  };
}
