
class MyUserEntity {
  String userId;
  String email;
  String name;
  String location;

  MyUserEntity({required this.userId, required this.email, required this.name, required this.location});

  Map<String, Object?> toJson() {
    return {'userId': userId, 'email': email, 'name': name, 'location': location};
  }

 static MyUserEntity fromJson(Map<String, dynamic> doc) {
   return MyUserEntity(
    userId: doc['userId'],
    email: doc['email'],
    name: doc['name'],
    location: doc['location']
   );
 }
}
