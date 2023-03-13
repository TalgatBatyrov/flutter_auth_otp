class UserModel {
  String name;
  String email;
  String bio;
  String profilePick;
  String createdAt;
  String phoneNumber;
  String uid;

  UserModel({
    required this.name,
    required this.email,
    required this.bio,
    required this.profilePick,
    required this.createdAt,
    required this.phoneNumber,
    required this.uid,
  });

  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      profilePick: json['profilePick'] ?? '',
      createdAt: json['createdAt'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      uid: json['uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'profilePick': profilePick,
      'createdAt': createdAt,
      'phoneNumber': phoneNumber,
      'uid': uid,
    };
  }
}
