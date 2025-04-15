import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'location_selection_screen.dart';

class PostFoundItemScreen extends StatefulWidget {
  const PostFoundItemScreen({super.key});

  @override
  State<PostFoundItemScreen> createState() => _PostFoundItemScreenState();
}

class _PostFoundItemScreenState extends State<PostFoundItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _itemNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _timeController;
  late final TextEditingController _dateController;
  late final TextEditingController _descriptionController;

  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _pickedImage;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController();
    _locationController = TextEditingController();
    _timeController = TextEditingController();
    _dateController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectionScreen(
          onLocationSelected: (location) {
            Navigator.pop(context, location);
          },
        ),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _selectedLocation = result;
        _locationController.text = '${result.latitude}, ${result.longitude}';
      });
    }
  }

  Future<void> _postItem() async {
    if (_selectedCategory == null ||
        _pickedImage == null ||
        _selectedLocation == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('post_images').child(fileName);
      await ref.putFile(_pickedImage!);
      final imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('posts').add({
        'uid': user?.uid,
        'itemName': _itemNameController.text.trim(),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'location': '${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
        'date': _dateController.text,
        'time': _timeController.text,
        'imageUrl': imageUrl,
        'postType': 'Found',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post submitted successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error posting item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Found Item'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category*',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: ['Electronics', 'Clothing', 'Documents', 'Accessories', 'Other']
                      .map((category) => ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ))
                      .toList(),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _itemNameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter the item name' : null,
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: _selectLocation,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location*',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Please select a location' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        onTap: () => _selectTime(context),
                        decoration: const InputDecoration(
                          labelText: 'Time*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please select a time' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: const InputDecoration(
                          labelText: 'Date*',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please select a date' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Select Image*'),
                    onPressed: _pickImage,
                  ),
                ),
                const SizedBox(height: 8),
                if (_pickedImage != null)
                  Center(
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.file(
                        _pickedImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.error)),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _postItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
