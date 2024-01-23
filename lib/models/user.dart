import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String coverPhotoUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;


  const User(
      {required this.username,
        required this.uid,
        required this.photoUrl,
        required this.coverPhotoUrl,
        required this.email,
        required this.bio,
        required this.followers,
        required this.following});

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      photoUrl: snapshot["photoUrl"],
      coverPhotoUrl: snapshot["coverPhotoUrl"],
      bio: snapshot["bio"],
      followers: snapshot["followers"],
      following: snapshot["following"],
    );
  }

  Map<String, dynamic> toJson() => {
    "username": username,
    "uid": uid,
    "email": email,
    "photoUrl": photoUrl,
    "coverPhotoUrl": coverPhotoUrl,
    "bio": bio,
    "followers": followers,
    "following": following,
  };
}