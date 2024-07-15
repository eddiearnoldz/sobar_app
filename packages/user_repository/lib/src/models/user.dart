import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/src/entities/entities.dart';

class MyUser {
  String userId;
  String email;
  String name;
  bool admin;
  List<String> favourites;

  MyUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.favourites,
    required this.admin,
  });

  static final empty = MyUser(userId: '', email: '', name: '', favourites: [], admin: false);

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      name: name,
      admin: admin,
      favourites: favourites,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
      favourites: entity.favourites,
      admin: entity.admin,
    );
  }

  MyUser copyWith({
    String? userId,
    String? email,
    String? name,
    bool? admin,
    List<String>? favourites,
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      admin: admin ?? this.admin,
      favourites: favourites ?? this.favourites,
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $email, $name, $admin, ${favourites.length} favourites';
  }
}
