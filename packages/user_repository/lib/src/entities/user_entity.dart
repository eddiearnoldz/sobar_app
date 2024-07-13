
class MyUserEntity {
  final String userId;
  final String email;
  final String name;
  final List<String> favourites;

  MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.favourites,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'favourites': favourites,
    };
  }

  static MyUserEntity fromJson(Map<String, dynamic> json) {
    return MyUserEntity(
      userId: json['userId'],
      email: json['email'],
      name: json['name'],
      favourites: json['favourites'] != null ? List<String>.from(json['favourites']) : [],
    );
  }
}
