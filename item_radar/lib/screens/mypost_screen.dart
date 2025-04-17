import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'postfounditem_screen.dart';
import 'postlostitem_screen.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  int _currentIndex = 1;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> _userPosts = [];
  String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
    _fetchUserName();
  }

  Future<void> _fetchUserPosts() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('userPosts')
            .orderBy('createdAt', descending: true)
            .get();

        setState(() {
          _userPosts = snapshot.docs;
        });
      } catch (e) {
        print('Error fetching posts: $e');
      }
    }
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final docSnap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (docSnap.exists) {
          final data = docSnap.data();
          setState(() {
            _userName = data?['full_name'] ?? 'No Full Name Found';
          });
        } else {
          setState(() {
            _userName = 'User Document Not Found';
          });
        }
      } catch (e) {
        print('Error fetching fullName: $e');
        setState(() {
          _userName = 'Error fetching name';
        });
      }
    } else {
      setState(() {
        _userName = 'Not Logged In';
      });
    }
  }

  void _navigateToDetailScreen(BuildContext context, DocumentSnapshot post) {
    try {
      Map<String, dynamic> data = post.data() as Map<String, dynamic>;
      if (data == null) {
        throw 'Post data is null';
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(
            title: data['itemName'] ?? 'Unknown',
            category: data['category'] ?? '',
            date: data['date'] ?? '',
            time: data['time'] ?? 'Not specified',
            location: data['location'] ?? '',
            description: data['description'] ?? '',
            imagePath: data['imageUrl'] ?? '',
            phoneNumber: data['phoneNumber'] ?? '',
            buttonColor: Colors.blue,
            buttonText: "Contact Owner",
          ),
        ),
      );
    } catch (e) {
      print('Error navigating to detail screen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load post details. Please try again.')),
      );
    }
  }


  void _showComingSoonMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon!'),
        content: const Text('This feature will be available soon. Stay tuned!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  void _showAddPostModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Create Post", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text("What do you want to post?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PostFoundItemScreen()));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: Size(double.infinity, 50)),
                      child: Text("Post Found Item"),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PostLostItemScreen()));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: Size(double.infinity, 50)),
                      child: Text("Post Lost Item"),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Posts'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: currentUser == null
          ? Center(child: Text("You are not logged in"))
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(currentUser.photoURL ??
                        'https://images.unsplash.com/photo-1525069011944-e7adfe78b280?w=800&h=800'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _userName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text('Total Posts: ${_userPosts.length}', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            SizedBox(height: 20),
            _userPosts.isEmpty
                ? Center(child: Text('No posts available'))
                : GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                final postData = _userPosts[index].data() as Map<String, dynamic>;
                final imageUrl = postData['imageUrl'] ?? '';
                final title = postData['itemName'] ?? 'Untitled';
                final category = postData['category'] ?? 'Unknown';

                return GestureDetector(
                  onTap: () => _navigateToDetailScreen(context, _userPosts[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade200,
                                child: Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black54, Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: category.toLowerCase() == 'lost'
                                    ? Colors.redAccent.withOpacity(0.9)
                                    : Colors.green.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              break;
            case 1:
              break;
            case 2:
              _showAddPostModal(context);
              break;
            case 3:
              _showComingSoonMessage(context);
              break;
            case 4:
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
              break;
          }
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'My Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add Post'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
