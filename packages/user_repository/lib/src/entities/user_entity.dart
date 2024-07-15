class MyUserEntity {
  final String userId;
  final String email;
  final String name;
  final bool admin;
  final List<String> favourites;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.admin,
    required this.favourites,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'admin': admin,
      'favourites': favourites,
    };
  }

  static MyUserEntity fromJson(Map<String, dynamic> json) {
    return MyUserEntity(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      admin: json['admin'] ?? false,
      favourites: json['favourites'] != null ? List<String>.from(json['favourites']) : [],
    );
  }
}
