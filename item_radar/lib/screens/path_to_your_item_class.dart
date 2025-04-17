class Item {
  String title;
  String category;
  String description;
  String buttonText;
  List<String> images;
  String location;
  String time;
  String date;
  String buttonColor;
  String phoneNumber;

  Item({
    required this.title,
    required this.category,
    required this.description,
    required this.buttonText,
    required this.images,
    required this.location,
    required this.time,
    required this.date,
    required this.buttonColor,
    required this.phoneNumber,
  });

  // Factory constructor to create an Item from a Map
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      title: map['title'],
      category: map['category'],
      description: map['description'],
      buttonText: map['buttonText'],
      images: List<String>.from(map['images']),
      location: map['location'],
      time: map['time'],
      date: map['date'],
      buttonColor: map['buttonColor'],
      phoneNumber: map['phoneNumber'],
    );
  }
}
