import 'package:firebase_auth/firebase_auth.dart';

class Profile {
  final String email;
  String username;
  final String uid;

  Profile({
    required this.email,
    required this.username,
    required this.uid,
  });

  factory Profile.fromUser(User user, name, email) {
    return Profile(
      email: email,
      username: name,
      uid: user.uid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'uid': uid,
    };
  }
}
