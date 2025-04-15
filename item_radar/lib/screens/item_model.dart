// item_model.dart
import 'dart:ui';

class Item {
  final String title;
  final String category;
  final String date;
  final String time;
  final String location;
  final String description;
  final String imagePath;
  final String buttonText;
  final Color buttonColor;
  final String contactNumber;

  Item({
    required this.title,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    required this.imagePath,
    required this.buttonText,
    required this.buttonColor,
    required this.contactNumber,
  });
}