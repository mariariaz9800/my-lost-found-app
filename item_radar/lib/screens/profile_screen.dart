import 'package:flutter/material.dart';
import 'package:item_radar/screens/reportproblem_screen.dart';
import 'package:item_radar/screens/welcome_screen.dart';
import 'package:item_radar/screens/home_screen.dart' as home;
import 'package:item_radar/screens/mypost_screen.dart';
import 'editprofile_screen.dart';
import 'package:item_radar/screens/shareapp_screen.dart';
import 'postfounditem_screen.dart';
import 'postlostitem_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool _notificationsEnabled = true;
  int _selectedIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            userData = doc.data();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("🔥 Failed to load user data: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => home.HomeScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyPostsScreen()));
        break;
      case 2:
        _showAddPostModal(context);
        break;
      case 3:
        _showComingSoonMessage(context);
        break;
      case 4:
        break;
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Do you want to logout from Item Radar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This action cannot be undone.\n\nPlease confirm your password to proceed.'),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;

                if (user != null && user.email != null) {
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: _passwordController.text.trim(),
                  );

                  await user.reauthenticateWithCredential(credential);
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                  await user.delete();

                  // Close the dialog before navigating
                  Navigator.of(context).pop();

                  // Navigate after a micro delay to ensure dialog is closed
                  Future.microtask(() {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          (route) => false,
                    );
                  });
                }
              } catch (e) {
                print("🔥 Error deleting account: $e");

                Navigator.of(context).pop(); // Close dialog on error as well

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to delete account: ${e.toString()}"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Create Post", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text("What do you want to post?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PostFoundItemScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Post Found Item"),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PostLostItemScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Post Lost Item"),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        userData?['profilePicture'] ?? 'https://images.unsplash.com/photo-1525069011944-e7adfe78b280?w=800&h=800', // Default image
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Display User Info
                    if (isLoading)
                      const CircularProgressIndicator()
                    else ...[
                      Text(
                        userData?['fullName'] ?? 'Unknown User',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '@${userData?['registrationNumber'] ?? 'username'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Profile options
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1),
                  ],
                ),
                child: Column(
                  children: [
                    // Edit Profile option
                    _buildProfileOption(Icons.edit, 'Edit Profile', () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                      if (result == true) {
                        _loadUserData(); // Reload user data if profile was updated
                      }
                    }),
                    // Notifications toggle
                    SwitchListTile(
                      title: const Text('Notifications'),
                      value: _notificationsEnabled,
                      onChanged: (newValue) => setState(() => _notificationsEnabled = newValue),
                    ),
                    // Delete Account option
                    _buildProfileOption(Icons.delete, 'Delete Account', _showDeleteAccountDialog, Colors.red),
                    // Report a Problem option
                    _buildProfileOption(Icons.report, 'Report a Problem', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportProblemScreen()));
                    }),
                    // Share App option
                    _buildProfileOption(Icons.share, 'Share App', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ShareAppScreen()));
                    }),
                    // Logout option
                    _buildProfileOption(Icons.logout, 'Logout', _showLogoutDialog, Colors.red),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4, // Make sure this index corresponds to the Profile tab
        onTap: _onItemTapped,
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

  Widget _buildProfileOption(IconData icon, String text, VoidCallback? onTap, [Color? color]) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black54),
      title: Text(text, style: TextStyle(color: color ?? Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
      onTap: onTap,
    );
  }
}
