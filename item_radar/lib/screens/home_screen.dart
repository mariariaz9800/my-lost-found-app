import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'profile_screen.dart';
import 'sort_screen.dart';
import 'filter_screen.dart';
import 'package:item_radar/screens/mypost_screen.dart';
import 'postfounditem_screen.dart';
import 'postlostitem_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> allItems = [
  ];
  // All items
  int _selectedIndex = 0;
  List<Map<String, dynamic>> displayedItems = []; // Filtered items
  bool isLoading = true;
  String selectedCategory = 'All';
  String searchQuery = '';
  Map<String, dynamic> filters = {}; // Filters for Firestore queries


  @override
  void initState() {
    super.initState();
    fetchInitialPosts();
  }

  Future<void> fetchInitialPosts() async {
    setState(() => isLoading = true);
    try {
      final postsSnapshot = await FirebaseFirestore.instance.collection('posts').get();

      List<Map<String, dynamic>> items = [];

      for (var doc in postsSnapshot.docs) {
        final data = doc.data();

        if (data.isEmpty) continue;

        final uid = data['uid'] ?? '';

        String userNameOrEmail = 'Unknown User';
        try {
          if (uid.isNotEmpty) {
            DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
            if (userDoc.exists) {
              userNameOrEmail = userDoc.get('name') ?? userDoc.get('email') ?? 'Unknown User';
            }
          }
        } catch (e) {
          print('Error fetching user for post ${doc.id}: $e');
        }

        final Timestamp? dateTimestamp = data['date'];
        final Timestamp? timeTimestamp = data['time'];

        final formattedDate = dateTimestamp != null
            ? dateTimestamp.toDate().toString().split(' ')[0]
            : 'No Date';
        final formattedTime = timeTimestamp != null
            ? TimeOfDay.fromDateTime(timeTimestamp.toDate()).format(context)
            : 'No Time';

        final buttonText = data['buttonText'] ?? '';
        final buttonColor = buttonText == 'Found'
            ? Colors.green
            : (buttonText == 'Lost' ? Colors.red : Colors.grey);

        items.add({
          'title': data['title'] ?? 'No Title',
          'category': data['category'] ?? 'Unknown',
          'date': formattedDate,
          'time': formattedTime,
          'location': data['location'] ?? '0.0, 0.0',
          'description': data['description'] ?? '',
          'images': List<String>.from(data['images'] ?? []),
          'buttonColor': buttonColor,
          'buttonText': buttonText.isNotEmpty ? buttonText : 'Unknown',
          'phoneNumber': data['phoneNumber'] ?? '',
          'uid': uid,
          'userName': userNameOrEmail,
        });
      }

      setState(() {
        allItems = items;
        displayedItems = getFilteredItems(); // Apply filters right away
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() => isLoading = false);
    }
  }
  Stream<QuerySnapshot> getPostsStream() {
    if (selectedCategory == 'All') {
      return FirebaseFirestore.instance.collection('posts').snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('posts')
          .where('postType', isEqualTo: selectedCategory)
          .snapshots();
    }
  }




  List<Map<String, dynamic>> getFilteredItems() {
    List<Map<String, dynamic>> filteredItems = allItems;

    // Debugging: Print the list before applying filters
    print('Before filtering, items count: ${filteredItems.length}');

    if (selectedCategory != 'All') {
      filteredItems = filteredItems
          .where((item) => item['buttonText'] == selectedCategory)
          .toList();
      print('After category filter, items count: ${filteredItems.length}');
    }

    if (searchQuery.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        final title = item['title'].toString().toLowerCase();
        final category = item['category'].toString().toLowerCase();
        final query = searchQuery.toLowerCase();

        // Debugging: Check how the query matches the data
        print('Searching for query: "$query" in title: "$title" or category: "$category"');

        return title.contains(query) || category.contains(query);
      }).toList();
      print('After search query filter, items count: ${filteredItems.length}');
    }

    // Debugging: Check final filtered result
    print('Final filtered items count: ${filteredItems.length}');

    return filteredItems;
  }



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;  // Now _selectedIndex is defined and updated
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyPostsScreen()),
      );
    } else if (index == 2) {
      _showAddPostModal(context);
    } else if (index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Chat feature will be available in future updates!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Create Post",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "What do you want to post?",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PostFoundItemScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Post Found Item"),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PostLostItemScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: Size(double.infinity, 50),
                      ),
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
    List<Map<String, dynamic>> filteredItems = getFilteredItems();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search items or categories...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FilterScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.sort, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SortScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryButton('All'),
                _buildCategoryButton('Found'),
                _buildCategoryButton('Lost'),
              ],
            ),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
              child: Text(
                'No items found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final data = filteredItems[index];
                final postType = data['postType'] ?? 'Unknown';

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data['imageUrl'] != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.network(
                            data['imageUrl'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['itemName'] ?? 'Item Name',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['description'] ??
                                  'No description provided',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Chip(
                                  label: Text(postType),
                                  backgroundColor: postType == 'Lost'
                                      ? Colors.redAccent
                                      : Colors.green,
                                  labelStyle:
                                  const TextStyle(color: Colors.white),
                                ),
                                const Spacer(),
                                Text(
                                  '📍 ${data['location'] ?? "Unknown"}',
                                  style: TextStyle(
                                      color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'My Posts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: 'Add Post'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }



  Widget _buildCategoryButton(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Text(
        category,
        style: TextStyle(
          color: selectedCategory == category ? Colors.blue : Colors.black,
          fontWeight: selectedCategory == category
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final String title;
  final String category;
  final String location;
  final String time;
  final String date;
  final String description;
  final String imagePath;
  final Color buttonColor;
  final String phoneNumber;
  final String buttonText;

  const DetailScreen({
    Key? key,
    required this.title,
    required this.category,
    required this.location,
    required this.time,
    required this.date,
    required this.description,
    required this.imagePath,
    required this.buttonColor,
    required this.phoneNumber,
    required this.buttonText,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late GoogleMapController mapController;
  late LatLng _center;

  @override
  void initState() {
    super.initState();
    // Initialize the location, parsing the latitude and longitude from the string
    final locationParts = widget.location.split(', ');
    if (locationParts.length == 2) {
      double lat = double.tryParse(locationParts[0]) ?? 0.0;
      double lng = double.tryParse(locationParts[1]) ?? 0.0;
      _center = LatLng(lat, lng);
    } else {
      _center = LatLng(0.0, 0.0); // Fallback in case the location format is incorrect
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.buttonColor,
      ),
      body: ListView(
        children: [
          // Image Section
          Image.network(
            widget.imagePath,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.image_not_supported, size: 50),
              );
            },
          ),
          // Post Details Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.category, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text('Date: ${widget.date} | Time: ${widget.time}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Text(widget.description),
                const SizedBox(height: 16),
                // Google Map
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 15.0,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId(widget.title),
                        position: _center,
                        infoWindow: InfoWindow(title: widget.title),
                      ),
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: widget.buttonColor),
                  onPressed: () {
                    // Implement contact action (e.g., calling the phone number)
                    _launchCall(widget.phoneNumber);
                  },
                  child: Text(widget.buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to launch the phone dialer
  void _launchCall(String phoneNumber) {
    // Use url_launcher or any other method to initiate the phone call
    print("Dialing $phoneNumber");
  }
}