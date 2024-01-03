class ChatUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String profilePictureUrl;
  final bool isOnline;

  ChatUser(
      {required this.id,
      required this.name,
      required this.email,
      required this.phoneNumber,
      required this.role,
      required this.profilePictureUrl,
      this.isOnline = false});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: json['role'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String,
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'profilePictureUrl': profilePictureUrl,
      'isOnline': isOnline
    };
  }
}
