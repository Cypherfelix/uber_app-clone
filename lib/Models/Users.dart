import 'package:firebase_database/firebase_database.dart';

class Users {
  String id;
  String email;
  String name;
  String phone;
  Users({
    this.id,
    this.email,
    this.name,
    this.phone,
  });
  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    Map<dynamic, dynamic> map = dataSnapshot.value;
    email = map["email"];
    name = map["name"];
    phone = map["phone"];
  }
}
