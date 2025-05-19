import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global8/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_provider.dart';
import '../utils/utils.dart';
import '../resources/storage_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global8/providers/theme_provider.dart'; // Import your theme provider
import 'package:global8/models/user.dart' as model;
import '../providers/navigation_provider.dart'; // Import your navigation provider

class EditProfileScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  Uint8List? _profileImage;
  Uint8List? _bannerImage;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _birthday;
  bool _isLoading = false;

  Map<String, dynamic>? userData;

  Future<void> loadUserData() async {
    try {
      // Get the currently logged-in user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Fetch user data directly from Firestore
      DocumentSnapshot userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userSnap.exists) {
        setState(() {
          userData = userSnap.data() as Map<String, dynamic>;

          // Populate fields with fetched user data
          _usernameController.text = userData?['username'] ?? '';
          _bioController.text = userData?['bio'] ?? '';
          _locationController.text = userData?['location'] ?? '';
          _birthday = userData?['birthday'] != null
              ? (userData?['birthday'] as Timestamp).toDate()
              : null;
        });
      } else {
        throw Exception("User data not found.");
      }
    } catch (e) {
      showSnackBar(context, "Failed to load user data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> updateUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Unauthorized user.");
      }

      String? profileUrl = userData?['photoUrl'];
      String? bannerUrl = userData?['coverPhotoUrl'];

      if (_profileImage != null) {
        profileUrl = await StorageMethods().uploadImageToStorage(
          'profilePics/${user.uid}',
          _profileImage!,
          false,
        );
      }

      if (_bannerImage != null) {
        bannerUrl = await StorageMethods().uploadImageToStorage(
          'bannerPhotos/${user.uid}',
          _bannerImage!,
          false,
        );
      }

      // Update user profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'location': _locationController.text.trim(),
        'birthday': _birthday,
        'photoUrl': profileUrl,
        'coverPhotoUrl': bannerUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      // Navigate back to the previous screen using NavigationProvider
      final navigationNotifier = ref.read(navigationProvider.notifier);
      navigationNotifier.updatePage(0, context); // Update to the appropriate page (e.g., 0 for HomeScreen)

      Navigator.pop(context); // Optionally, pop the screen
    } catch (e) {
      showSnackBar(context, "Failed to update profile: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
       // Use dynamic background color
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight), // Keeps the standard app bar height
        child: AppBar(
           // Use dynamic app bar color
          elevation: 0, // Removes shadow
          title: Text('Edit Profile', style: TextStyle()), // Dynamically set text color
          actions: [
            IconButton(
              icon: Icon(Icons.save,), // Icon color remains white
              onPressed: _isLoading ? null : updateUserData,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Title section with dynamic text color
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Text(
                    "Update your profile picture, banner, and information. Then click the save icon in the top right corner.",
                    style: TextStyle(
                      fontSize: 15,
                      // Dynamic text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Banner Image Picker
            Stack(
              children: [
                _bannerImage != null
                    ? Image.memory(
                  _bannerImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : (userData?['coverPhotoUrl'] != null
                    ? Image.network(
                  userData!['coverPhotoUrl'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                )),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.grey),
                    onPressed: () async {
                      Uint8List? image = await pickImage(ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          _bannerImage = image;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Profile Image Picker
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? MemoryImage(_profileImage!)
                        : (userData?['photoUrl'] != null
                        ? NetworkImage(userData!['photoUrl'])
                        : const NetworkImage('https://via.placeholder.com/150'))
                    as ImageProvider,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.grey, size: 30),
                      onPressed: () async {
                        Uint8List? image = await pickImage(ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _profileImage = image;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Username
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username', labelStyle: TextStyle()),
              style: TextStyle(),
            ),
            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Bio', labelStyle: TextStyle()),
              style: TextStyle(),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Birthday Picker
            Row(
              children: [
                Text('Birthday: ', style: TextStyle()),
                TextButton(
                  child: Text(
                    _birthday != null
                        ? "${_birthday!.year}-${_birthday!.month}-${_birthday!.day}"
                        : 'Select Date',
                    style: TextStyle(fontSize: 16, ),
                  ),
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _birthday ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _birthday = selectedDate;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location', labelStyle: TextStyle()),
              style: TextStyle(),
            ),
          ],
        ),
      ),
    );
  }
}


