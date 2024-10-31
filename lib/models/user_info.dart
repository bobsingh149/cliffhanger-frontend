class UserInfoModel {
  final String id;
  final String name;
  final String? profileImage;
  final int? age;
  final String? bio;
  final String? city;
  UserInfoModel({
    required this.id,
    required this.name,
    this.profileImage,
    this.age,
    this.bio = '',
    this.city,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['id'],
      name: json['name'],
      profileImage: json['profileImage'],
      age: json['age'],
      bio: json['bio'] ?? '', // Default to an empty string if bio is null
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'bio': bio,
      'city': city,
    };
  }
}
