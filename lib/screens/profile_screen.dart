// Same imports...
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global8/screens/settings_screen.dart';
import 'package:global8/utils/colors.dart';
import 'package:global8/utils/utils.dart';
import '../providers/navigation_provider.dart';
import '../widgets/story_card.dart';
import '../widgets/post_card.dart';
import 'package:global8/providers/theme_provider.dart';

import 'follow_list_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic> userData = {};
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  User? currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (currentUser == null) {
      getCurrentUser();
    }
    if (!isLoading) {
      getData();
    }
  }

  void getCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> getData() async {
    setState(() => isLoading = true);
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (mounted) {
        final newUserData = userSnap.data() ?? {};
        final newUsername = newUserData['username'] ?? '';
        final newPhotoUrl = newUserData['photoUrl'] ?? '';

        setState(() {
          userData = newUserData;
          followers = newUserData['followers']?.length ?? 0;
          following = newUserData['following']?.length ?? 0;
          isFollowing = newUserData['followers']
              ?.contains(FirebaseAuth.instance.currentUser?.uid) ??
              false;
          isLoading = false;
        });

        SchedulerBinding.instance.addPostFrameCallback((_) {
          final navState = ref.read(navigationProvider);
          if (mounted &&
              (newUsername != navState.username ||
                  newPhotoUrl != navState.profilePic)) {
            ref.read(navigationProvider.notifier).updateUserData(
              username: newUsername,
              profilePic: newPhotoUrl, uid: '',
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {


    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(

      appBar: AppBar(

        elevation: 0,
        title: Text(
          "Global 8",
          style: TextStyle(

            fontSize: 24,
            fontFamily: 'DancingScript',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.white,
                offset: Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        centerTitle: true,

        actions: [
          IconButton(
            icon: Icon(Icons.settings,),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),

        ],
      ),
      body: _buildProfileBody(),
    );
  }

  Widget _buildProfileBody() {
    return ListView(
      children: [
        Stack(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: mobileBackgroundColorLight,
                image: userData['coverPhotoUrl'] != null
                    ? DecorationImage(
                  image: NetworkImage(userData['coverPhotoUrl']),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple.shade100.withOpacity(0.5),
                    radius: 45,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(userData['photoUrl'] ?? ''),
                      radius: 40,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      userData['username'] ?? 'Unknown User',
                      style: TextStyle(

                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 110,
              left: 220,
              child: Row(
                children: [
                  _countWithLabel(followers.toString(), "Followers"),
                  const SizedBox(width: 16),
                  _countWithLabel(following.toString(),"Following"),
                ],
              ),
            ),

          ],
        ),


        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userData['bio'] != null &&
                  userData['bio'].toString().isNotEmpty)
                Text(
                  userData['bio'],
                  style: TextStyle(

                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),

        // Tab view for posts and stories
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.purpleAccent,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.purpleAccent,
                tabs: [
                  Tab(icon: Icon(Icons.list, )),
                  Tab(icon: Icon(Icons.photo_camera_front, )),
                ],
              ),
              SizedBox(
                height: 500,
                child: TabBarView(
                  children: [
                    _buildStreamBuilder(
                        'story', (data) => StoryCard(snap: data)),
                    _buildStreamBuilder(
                        'posts', (data) => PostCard(snap: data)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildStreamBuilder(
      String collection, Widget Function(Map<String, dynamic>) builder) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .where('uid', isEqualTo: widget.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No posts available.',
              style: TextStyle(color: Colors.purpleAccent),
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final post =
            snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return builder(post);
          },
        );
      },
    );
  }
  Widget _countWithLabel(String count, String label,) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FollowListScreen(
            uid: widget.uid,
            listType: label.toLowerCase(), // "followers" or "following"
          ),
        ));
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.shade100.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.shade100.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }




}





