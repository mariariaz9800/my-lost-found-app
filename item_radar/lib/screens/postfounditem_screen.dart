import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:item_radar/screens/location_selection_screen.dart';

class PostFoundItemScreen extends StatefulWidget {
  const PostFoundItemScreen({super.key});

  @override
  State<PostFoundItemScreen> createState() => _PostFoundItemScreenState();
}

class _PostFoundItemScreenState extends State<PostFoundItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _itemName = '';
  String _category = '';
  String _location = '';
  String _description = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Books',
    'Accessories',
    'Others'
  ];

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationSelectionScreen(
          onLocationSelected: (LatLng selectedLocation) {
            Navigator.pop(context, selectedLocation);
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _location = '${result.latitude}, ${result.longitude}';
      });
    }
  }

  Future<void> _postItem() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    if (_selectedDate == null || _selectedTime == null || _category.isEmpty || _location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    _formKey.currentState!.save();

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final timestamp = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final postData = {
        'type': 'Found',
        'itemName': _itemName,
        'category': _category,
        'location': _location,
        'description': _description,
        'timestamp': timestamp,
        'imageUrl': '', // You can add image URL if needed
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
      };

      print('📤 Posting item to Firestore...');

      // Save to global foundItems collection
      await FirebaseFirestore.instance.collection('foundItems').add(postData);

      // Also save to user's userPosts subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('userPosts')
          .add(postData);

      print('✅ Post successfully added to Firestore!');
      if (mounted) Navigator.of(context).pop();
    } catch (e, stackTrace) {
      print('❌ Exception while posting item: $e');
      print('🪵 Stack trace:\n$stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post item. Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Found Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator: (value) => value!.isEmpty ? 'Enter item name' : null,
                  onSaved: (value) => _itemName = value!,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) => setState(() => _category = val!),
                  validator: (value) => value == null || value.isEmpty ? 'Select category' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.date_range),
                        label: Text(_selectedDate == null
                            ? 'Select Date'
                            : DateFormat.yMMMd().format(_selectedDate!)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectTime,
                        icon: const Icon(Icons.access_time),
                        label: Text(_selectedTime == null
                            ? 'Select Time'
                            : _selectedTime!.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _selectLocation,
                  icon: const Icon(Icons.location_on),
                  label: Text(_location.isEmpty ? 'Select Location' : _location),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Enter description' : null,
                  onSaved: (value) => _description = value!,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _postItem,
                  child: const Text('Post Item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
