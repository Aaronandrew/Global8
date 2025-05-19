import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';  // For XFile

class StorageMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image from raw bytes (Uint8List)
  Future<String> uploadImageToStorage(String childPath, Uint8List file, bool isPost) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: "not-authenticated",
          message: "User is not logged in",
        );
      }

      Reference ref = _storage.ref().child(childPath).child(user.uid);
      if (isPost) {
        String id = const Uuid().v1();
        ref = ref.child(id);
      }

      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint("Error in uploadImageToStorage: $e");
      return Future.error(e.toString());
    }
  }

  // Upload video from XFile (picked video file)
  Future<String> uploadVideoToStorage(String childPath, XFile file, bool isPost) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: "not-authenticated",
          message: "User is not logged in",
        );
      }

      Reference ref = _storage.ref().child(childPath).child(user.uid);
      if (isPost) {
        String id = const Uuid().v1();
        ref = ref.child(id);
      }

      // Upload file from path (XFile provides path to the local file)
      UploadTask uploadTask = ref.putFile(
        File(file.path),
        SettableMetadata(contentType: 'video/mp4'), // Set MIME type accordingly
      );

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint("Error in uploadVideoToStorage: $e");
      return Future.error(e.toString());
    }
  }
}
