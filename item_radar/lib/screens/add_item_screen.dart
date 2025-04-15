import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  String type = 'lost';
  String title = '';
  String description = '';
  String location = '';

  void handleSubmit() {
    if (title.isEmpty || description.isEmpty || location.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill all fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    Fluttertoast.showToast(
      msg: "Item posted successfully!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    // Navigate to Home screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Item'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => type = 'lost'),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: type == 'lost' ? Colors.white : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Lost',
                        style: TextStyle(
                          fontSize: 16,
                          color: type == 'lost' ? Colors.blue : Colors.grey,
                          fontWeight: type == 'lost' ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => type = 'found'),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: type == 'found' ? Colors.white : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Found',
                        style: TextStyle(
                          fontSize: 16,
                          color: type == 'found' ? Colors.blue : Colors.grey,
                          fontWeight: type == 'found' ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              'Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextField(
              onChanged: (value) => title = value,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: EdgeInsets.all(12.0),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextField(
              onChanged: (value) => description = value,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: EdgeInsets.all(12.0),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            InkWell(
              onTap: () {
                // Navigate to MapPicker screen
                Navigator.pushNamed(context, '/mapPicker').then((value) {
                  if (value is String) {
                    setState(() {
                      location = value;
                    });
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue, size: 20),
                    SizedBox(width: 8.0),
                    Text(
                      location.isEmpty ? 'Pick location on map' : location,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Use backgroundColor instead of primary
                padding: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Post Item',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}