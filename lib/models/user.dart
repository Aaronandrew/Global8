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
  final String location;
  final DateTime? birthday;

  const User({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.coverPhotoUrl,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
    required this.location,
    required this.birthday,
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot["username"] ?? "Unknown",
      uid: snapshot["uid"] ?? '',
      email: snapshot["email"] ?? '',
      photoUrl: snapshot["photoUrl"] ?? '',
      coverPhotoUrl: snapshot["coverPhotoUrl"] ?? '',
      bio: snapshot["bio"] ?? '',
      followers: snapshot["followers"] ?? [],
      following: snapshot["following"] ?? [],
      location: snapshot["location"] ?? 'Unknown',
      birthday: (snapshot["birthday"] != null)
          ? (snapshot["birthday"] as Timestamp).toDate()
          : null,
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
    "location": location,
    "birthday": birthday != null ? Timestamp.fromDate(birthday!) : null,
  };
}

