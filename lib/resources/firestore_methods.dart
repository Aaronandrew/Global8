import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:global8/models/post.dart';
import 'package:global8/resources/storage_methods.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/comment.dart';
import '../models/story.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
      String description,
      XFile file,
      String uid,
      String username,
      String profImage, {required String mediaType}
      ) async {
    String res = "Some error occurred";
    try {
      String mediaUrl;

      // Check file type by extension or mimeType
      final isVideo = file.path.toLowerCase().endsWith('.mp4') || file.mimeType?.startsWith('video/') == true;

      if (isVideo) {
        mediaUrl = await StorageMethods().uploadVideoToStorage('posts', file, true);
      } else {
        Uint8List fileBytes = await file.readAsBytes();
        mediaUrl = await StorageMethods().uploadImageToStorage('posts', fileBytes, true);
      }

      String postId = const Uuid().v1(); // unique id based on time
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: mediaUrl,
        profImage: profImage,
        mediaType: isVideo ? 'video' : 'image', // add this field in your Post model!
      );

      await _firestore.collection('posts').doc(postId).set(post.toJson());

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  Future<QuerySnapshot<Map<String, dynamic>>> getPosts({int limit = 10, DocumentSnapshot? startAfter}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('posts')
        .orderBy('datePublished', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.get();
  }

  Future<String> uploadStory(String description, Uint8List file, String uid, String username, String profImage) async {
    String res = "Some error occurred";
    try {
     // String uid = FirebaseAuth.instance.currentUser!.uid;
      String storyId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create story object
      Story story = Story(
        storyId: storyId,
        uid: uid, // Save uid here
        description: description,
        profImage: profImage, // Use the actual URL
        username: username, // Use the actual username
        likes: [], datePublished: DateTime.now(),
        //datePublished: DateTime.now(), // Initialize with an empty list
      );

      // Save story in Firestore
      await FirebaseFirestore.instance.collection('story').doc(storyId).set(story.toJson());

      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> likeStory(String storyId, String uid) async {
    try {
      DocumentReference storyRef = _firestore.collection('story').doc(storyId);

      await storyRef.update({
        'likes': FieldValue.arrayUnion([uid]) // Adds the user ID to the likes array
      });
    } catch (e) {
      print("Error liking story: $e");
    }
  }

  // Method to unlike a story
  Future<void> unlikeStory(String storyId, String uid) async {
    try {
      DocumentReference storyRef = _firestore.collection('story').doc(storyId);

      await storyRef.update({
        'likes': FieldValue.arrayRemove([uid]) // Removes the user ID from the likes array
      });
    } catch (e) {
      print("Error unliking story: $e");
    }
  }

  Stream<QuerySnapshot> getUserStoriesStream(String uid) {
    return _firestore
        .collection('story')
        .where('uid', isEqualTo: uid)
        .orderBy('datePublished', descending: true) // Make sure datePublished is indexed.
        .snapshots();
  }

  Stream<QuerySnapshot> getStoriesStream() {
    return _firestore
        .collection('story')
        .orderBy('datePublished', descending: true) // Ensure datePublished is indexed
        .snapshots();
  }

  Stream<List<Comment>> getCommentsStream(String storyId) {
    return _firestore
        .collection('story')
        .doc(storyId)
        .collection('comments')
        .orderBy('datePublished', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Comment.fromJson(doc.data())).toList());
  }
// Story comments
  Future<String> addComment(String storyId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('story')
            .doc(storyId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadBanner(Uint8List file, String uid) async {
    String res = "Some error occurred";
    try {
      String bannerUrl = await StorageMethods().uploadImageToStorage('banners', file, true);
      String bannerId = const Uuid().v1();

      Map<String, dynamic> bannerData = {
        'bannerUrl': bannerUrl,
        'uid': uid,
        'bannerId': bannerId,
        'dateUploaded': DateTime.now(),
      };

      await _firestore.collection('banners').doc(bannerId).set(bannerData);
      res = "success";
    } catch (err) {
      if (kDebugMode) {
        print("Error in uploadBanner: $err");
      }
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadProfImage(Uint8List file, String uid) async {
    String res = "Some error occurred";
    try {
      // Upload the image to Firebase Storage under 'profImage' folder
      String profImage = await StorageMethods().uploadImageToStorage('profImage', file, true);

      // Create a unique ID for the profile image using Uuid
      String profId = const Uuid().v1();

      // Prepare the data to be saved in Firestore
      Map<String, dynamic> profData = {
        'photoUrl': profImage,
        'uid': uid,
        'profId': profId,
        'dateUploaded': DateTime.now(),
      };

      // Upload the profile data to Firestore under 'profImage' collection
      await _firestore.collection('profImage').doc(profId).set(profData);

      res = "success";  // If everything works, return success
    } catch (err) {
      // Handle and log any errors that may occur during the process
      if (kDebugMode) {
        print("Error in uploadProfImage: $err");
      }
      res = err.toString();  // Return the error as a string for debugging
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
      await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  Future<String> deleteUserAccount(String uid) async {
    String res = "Some error occurred";
    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Optionally delete subcollections like posts, comments, etc.
      // For example, delete user's posts:
      final userPosts = await _firestore.collection('posts').where('uid', isEqualTo: uid).get();
      for (var doc in userPosts.docs) {
        await _firestore.collection('posts').doc(doc.id).delete();
      }

      // Delete user from Firebase Auth
      await FirebaseAuth.instance.currentUser!.delete();

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

}