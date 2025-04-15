import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date picker

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: SortScreen(),
    );
  }
}

class SortScreen extends StatefulWidget {
  @override
  _SortScreenState createState() => _SortScreenState();
}

class _SortScreenState extends State<SortScreen> {
  String selectedDate = "Select Date";
  bool showSortOptions = false; // Controls A-Z / Z-A visibility

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sort", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Sort Options",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 15),

            // Sort by Date
            SortOption(
              icon: Icons.calendar_today,
              text: selectedDate, // Updates when a date is picked
              onTap: () => _selectDate(context),
            ),

            // Sort A to Z
            SortOption(
              icon: Icons.sort_by_alpha,
              text: "Sort A to Z",
              onTap: () {
                setState(() {
                  showSortOptions = true;
                });
              },
            ),

            // Sort Z to A
            SortOption(
              icon: Icons.sort_by_alpha,
              text: "Sort Z to A",
              onTap: () {
                setState(() {
                  showSortOptions = true;
                });
              },
            ),

            SizedBox(height: 20),

            // Sorting Applied Message
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: showSortOptions ? 1 : 0,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, blurRadius: 4, spreadRadius: 2)
                  ],
                ),
                child: Text(
                  "Sorting Applied Successfully!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Sort Button (Navigates back)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'selectedDate': selectedDate != "Select Date" ? selectedDate : null,
                  'sortOrder': showSortOptions ? "A-Z" : null,
                });
              },
              child: Text("Sort & Go Back", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                elevation: 5,
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// Custom widget for sorting options
class SortOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const SortOption({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.grey[300],
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
