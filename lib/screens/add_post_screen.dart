import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import 'package:global8/models/user.dart';
import 'package:global8/resources/firestore_methods.dart';
import 'package:global8/utils/utils.dart';
import 'package:global8/resources/auth_methods.dart';

class AddPostScreen extends StatefulWidget {
  final String userId;
  const AddPostScreen({super.key, required this.userId});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  XFile? _mediaFile;
  bool isVideo = false;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  User? _user;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User updatedUser = await AuthMethods().getUserDetails();
      setState(() {
        _user = updatedUser;
      });
    } catch (e) {
      showSnackBar(context, "Error fetching user data: $e");
    }
  }

  Future<void> _selectMedia(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Pick an Image'),
              onPressed: () async {
                Navigator.pop(context);
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  _disposeVideoController();
                  setState(() {
                    _mediaFile = picked;
                    isVideo = false;
                  });
                }
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Pick a Video'),
              onPressed: () async {
                Navigator.pop(context);
                final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
                if (picked != null) {
                  _disposeVideoController();
                  _videoController = VideoPlayerController.file(File(picked.path));
                  await _videoController!.initialize();
                  _videoController!.setLooping(true);
                  _videoController!.play();
                  setState(() {
                    _mediaFile = picked;
                    isVideo = true;
                  });
                }
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _disposeVideoController() {
    if (_videoController != null) {
      _videoController!.pause();
      _videoController!.dispose();
      _videoController = null;
    }
  }

  void postImage() async {
    if (_user == null || _mediaFile == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      await fetchUserData();

      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        _mediaFile!,
        _user!.uid,
        _user!.username,
        _user!.photoUrl,
        mediaType: isVideo ? 'video' : 'image', // make sure Firestore method accepts this
      );

      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          showSnackBar(context, 'Posted!');
        }
        clearImage();
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, err.toString());
    }
  }

  void clearImage() {
    _disposeVideoController();
    setState(() {
      _mediaFile = null;
      isVideo = false;
    });
  }

  @override
  void dispose() {
    _disposeVideoController();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _mediaFile == null
        ? Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Upload Post'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.upload, size: 50),
              onPressed: () => _selectMedia(context),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _selectMedia(context),
              child: const Text(
                "Upload a Post",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    )
        : Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: const Text('Post to'),
        centerTitle: false,
        actions: <Widget>[
          TextButton(
            onPressed: postImage,
            child: const Text(
              "Post",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            isLoading
                ? const LinearProgressIndicator()
                : const SizedBox(height: 4),
            const Divider(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(_user!.photoUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: "Write a caption...",
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              width: MediaQuery.of(context).size.width,
              child: isVideo && _videoController != null && _videoController!.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
                  : Image.file(
                File(_mediaFile!.path),
                height: 300,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}







