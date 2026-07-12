class AppUser {
  final String uid;
  final String email;
  final String name;
  final String role; // "student" or "startup"
  final String? bio;
  final bool isVerified;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.bio,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'bio': bio,
      'isVerified': isVerified,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
      bio: map['bio'],
      isVerified: map['isVerified'] ?? false,
    );
  }
}