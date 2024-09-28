

class UserInfo {
  final String id;
  final String email;
  final String name;
  final String? profileImage;
  final int? age;
  final String? bio;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.age,
    this.bio = '',
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      age: json['age'],
      bio: json['bio'] ?? '', // Default to an empty string if bio is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'age': age,
      'bio': bio, 
    };
  }
}
