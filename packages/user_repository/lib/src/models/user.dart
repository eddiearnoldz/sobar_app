import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/src/entities/entities.dart';

class MyUser {
  String userId;
  String email;
  String name;
  List<String> favourites;

  MyUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.favourites,
  });

  static final empty = MyUser(userId: '', email: '', name: '', favourites: []);

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      name: name,
      favourites: favourites,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
      favourites: entity.favourites,
    );
  }

  MyUser copyWith({
    String? userId,
    String? email,
    String? name,
    List<String>? favourites,
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      favourites: favourites ?? this.favourites,
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $email, $name, ${favourites.length} favourites';
  }
}
