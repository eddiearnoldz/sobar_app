import 'package:user_repository/src/entities/entities.dart';

class MyUser {
  String userId;
  String email;
  String name;
  String location;

  MyUser({required this.userId, required this.email, required this.name, required this.location});

  static final empty = MyUser(userId: '', email: '', name: '', location: '');

  MyUserEntity toEntity() {
    return MyUserEntity(userId: userId, email: email, name: name, location: location);
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(userId: entity.userId, email: entity.email, name: entity.name, location: entity.location);
  }

  @override
  String toString() {
    return 'MyUser: $userId, $email, $name, $location';
  }
}
