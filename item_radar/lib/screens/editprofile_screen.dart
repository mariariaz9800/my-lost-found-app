import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  String? imageUrl;
  File? _pickedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        nameController.text = data['fullName'] ?? '';
        regNoController.text = data['registrationNumber'] ?? '';
        emailController.text = data['email'] ?? '';
        bioController.text = data['bio'] ?? '';
        if (data['profilePicture'] != null) {
          imageUrl = data['profilePicture'];
        }
        if (mounted) setState(() {});
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _pickedImage = File(picked.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  Future<String?> _uploadProfilePicture(String uid) async {
    if (_pickedImage == null) return null;

    setState(() {
      _isUploading = true;
    });

    try {
      final ref = _storage.ref()
          .child('profile_pictures')
          .child('$uid.jpg');

      // Upload the file
      await ref.putFile(_pickedImage!);

      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("Error uploading profile picture: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      setState(() {
        _isUploading = true;
      });

      // Upload new profile picture if one was selected
      final newImageUrl = await _uploadProfilePicture(uid);

      // Prepare update data
      final updateData = {
        'fullName': nameController.text.trim(),
        'registrationNumber': regNoController.text.trim(),
        'email': emailController.text.trim(),
        'bio': bioController.text.trim(),
        if (newImageUrl != null) 'profilePicture': newImageUrl,
      };

      // Update Firestore document
      await _firestore.collection('users').doc(uid).update(updateData);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }

      // Return true to indicate successful update
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      print("Error updating profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _getProfileImage(),
                        child: _pickedImage == null && imageUrl == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      if (_isUploading)
                        const Positioned.fill(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: regNoController,
                  decoration: const InputDecoration(labelText: 'Registration Number'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isUploading ? null : _saveChanges,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
          if (_isUploading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage() {
    if (_pickedImage != null) {
      return FileImage(_pickedImage!);
    } else if (imageUrl != null) {
      return NetworkImage(imageUrl!);
    }
    return const AssetImage('assets/default_profile.png');
  }
}