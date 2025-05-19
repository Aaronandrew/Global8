import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:global8/screens/profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:global8/resources/auth_methods.dart';
import 'package:global8/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../resources/firestore_methods.dart';
import '../resources/storage_methods.dart';
import 'login_screen.dart';


class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({Key? key}) : super(key: key);

  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final AuthMethods _authMethods = AuthMethods();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final PageController _pageController = PageController();
  Uint8List? _profileImage;
  Uint8List? _bannerImage;
  DateTime? _selectedBirthday;
  int _currentPage = 0; // Track the current page without using `page`

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    bool isVerified = await AuthMethods().checkEmailVerification(
        timeoutDuration: Duration(minutes: 5));

    if (!isVerified) {
      if (context.mounted) {
        showSnackBar(context, "Please verify your email before proceeding.");
      }
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  void selectProfImage() async {
    Uint8List? image = await pickImage(ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  void selectBannerImage() async {
    Uint8List? image = await pickImage(ImageSource.gallery);
    if (image != null) {
      setState(() {
        _bannerImage = image;
      });
      String res = await FireStoreMethods().uploadBanner(
          image, FirebaseAuth.instance.currentUser!.uid);
      if (res == "success") {
        String bannerUrl = await StorageMethods().uploadImageToStorage(
            'banners', image, true);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'bannerPhotoUrl': bannerUrl});
      } else {
        showSnackBar(context, res);
      }
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  void submitProfile() async {
    try {
      String uid = _authMethods.getCurrentUserUid();

      if (_usernameController.text.isNotEmpty &&
          _bioController.text.isNotEmpty &&
          _locationController.text.isNotEmpty &&
          _selectedBirthday != null &&
          _profileImage != null) {

        String res = await _authMethods.completeUserProfile(
          uid: uid,
          username: _usernameController.text,
          bio: _bioController.text,
          location: _locationController.text,
          birthday: _selectedBirthday!, // Ensure birthday is saved
          profilePhoto: _profileImage!,
          bannerPhoto: _bannerImage ?? Uint8List(0),
        );

        if (!mounted) return; // Ensure the widget is still in the tree
        if (res == "success") {
          showSnackBar(context, "Profile created successfully!");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
            ),
          );
        } else {
          showSnackBar(context, "Error: $res");
        }
      } else {
        if (mounted) showSnackBar(context, "Please fill in all required fields.");
      }
    } catch (e) {
      if (mounted) showSnackBar(context, "Error: ${e.toString()}");
    }
  }


  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        // Keeps the standard app bar height
        child: AppBar(
          automaticallyImplyLeading: false,
          // Disables the back button (optional)
          backgroundColor: Colors.transparent,
          // Transparent background
          elevation: 0,
          // Removes shadow
          title: const Text(
              "Complete Your Profile", style: TextStyle(color: Colors.white)),
          // White text for contrast
          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/images/image.png"),
                // Your image asset
                fit: BoxFit.none,
                scale: 18,
                alignment: Alignment(
                    -.9, 1), // Adjust the alignment of the image
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withAlpha(60),
                  blurRadius: 6.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0.0, 3.0),
                ),
              ],

            ),
          ),
        ),
      ),

      body: Container(
        color: Colors.purple.shade100.withOpacity(0.2),
        // Light purple background
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page; // Update the page index
            });
          },
          children: [
            // Username Page
            _buildPage(
              context,
              content: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              title: "Enter your Username",
            ),

            // Bio Page
            _buildPage(
              context,
              content: TextField(
                controller: _bioController,
                maxLength: 30, // Optional: Adds a visual character limit in the UI
                decoration: const InputDecoration(
                  labelText: "Bio",
                  hintText: "Enter a bio (max 30 characters)",
                ),
                onChanged: (value) {
                  if (value.length > 30) {
                    final truncated = value.substring(0, 30); // Keep only the first 30 characters
                    _bioController.value = TextEditingValue(
                      text: truncated,
                      selection: TextSelection.collapsed(offset: truncated.length),
                    );
                  }
                },
              ),
              title: "Enter your Bio (max 30 characters)",
            ),

            // Location Page
            _buildPage(
              context,
              content: TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              title: "Enter your Location",
            ),

            // Birthday Page
            _buildPage(
              context,
              content: GestureDetector(
                onTap: () => _selectBirthday(context),
                child: AbsorbPointer( // Prevent keyboard from appearing when tapped
                  child: TextField(
                    controller: TextEditingController(
                      text: _selectedBirthday == null
                          ? ""
                          : DateFormat('dd/MM/yyyy').format(_selectedBirthday!),
                    ),
                    decoration: const InputDecoration(
                      labelText: "Birthday",
                      hintText: "Select your birthday",
                    ),
                    readOnly: true, // Makes the field non-editable
                  ),
                ),
              ),
              title: "Select your Birthday",
            ),


            // Profile Image Page
            _buildPage(
              context,
              content: GestureDetector(
                onTap: selectProfImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null ? MemoryImage(
                      _profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(
                      Icons.camera_alt, size: 30, color: Colors.white)
                      : null,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              title: "Upload your Profile Picture",
            ),

            // Banner Image Page
            _buildPage(
              context,
              content: GestureDetector(
                onTap: selectBannerImage,
                child: _bannerImage == null
                    ? Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(
                      Icons.camera_alt, size: 50, color: Colors.white),
                )
                    : Image.memory(_bannerImage!),
              ),
              title: "Upload a Banner Image",
            ),

            // Submit Page
            _buildPage(
              context,
              content: ElevatedButton(
                onPressed: submitProfile,
                child: const Text("Complete Profile"),
              ),
              title: "Complete Profile",
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPage(BuildContext context,
      {required Widget content, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      // Add horizontal padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          content, // Content of the page (e.g., TextField, button)
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage !=
                  0) // Only show back button if not on the first page
                IconButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              if (_currentPage !=
                  6) // Only show next button if not on the last page
                IconButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                ),
            ],
          ),
        ],
      ),
    );
  }

}
