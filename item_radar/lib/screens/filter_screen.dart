import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> items = [
    Item('Lost', 'Jewelry', 'Gold Ring', DateTime(2023, 5, 10)),
    Item('Lost', 'Electronics', 'iPhone 12', DateTime(2023, 5, 15)),
    Item('Found', 'Books', 'Math Textbook', DateTime(2023, 5, 20)),
    Item('Found', 'Clothes', 'Blue Jacket', DateTime(2023, 5, 25)),
    Item('Lost', 'Jewelry', 'Silver Bracelet', DateTime(2023, 6, 1)),
    Item('Found', 'Electronics', 'AirPods', DateTime(2023, 6, 5)),
  ];

  List<Item> filteredItems = [];
  String selectedCategory = 'All'; // Track selected category

  @override
  void initState() {
    super.initState();
    filteredItems = items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost & Found'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              final filters = await Navigator.push<FilterOptions>(
                context,
                MaterialPageRoute(
                  builder: (context) => FilterScreen(),
                ),
              );

              if (filters != null) {
                applyFilters(filters);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Add category filter chips
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: 8),
                _buildCategoryChip('All'),
                _buildCategoryChip('Jewelry'),
                _buildCategoryChip('Electronics'),
                _buildCategoryChip('Books'),
                _buildCategoryChip('Clothes'),
                SizedBox(width: 8),
              ],
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('${item.category} • ${item.date.toString().split(' ')[0]}'),
                  trailing: Text(item.type),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(category),
        selected: selectedCategory == category,
        onSelected: (selected) {
          setState(() {
            selectedCategory = selected ? category : 'All';
            filterItemsByCategory();
          });
        },
      ),
    );
  }

  void filterItemsByCategory() {
    if (selectedCategory == 'All') {
      setState(() {
        filteredItems = items;
      });
    } else {
      setState(() {
        // Sort items - selected category first, then others
        filteredItems = List.from(items)
          ..sort((a, b) {
            if (a.category == selectedCategory && b.category != selectedCategory) {
              return -1;
            } else if (a.category != selectedCategory && b.category == selectedCategory) {
              return 1;
            } else {
              return 0;
            }
          });
      });
    }
  }

  void applyFilters(FilterOptions filters) {
    setState(() {
      filteredItems = items.where((item) {
        // Filter by type
        if (item.type != filters.selectedType) {
          return false;
        }

        // Filter by categories
        if (filters.selectedCategories.isNotEmpty &&
            !filters.selectedCategories.contains(item.category)) {
          return false;
        }

        // Filter by date range
        if (filters.startDate != null &&
            item.date.isBefore(filters.startDate!)) {
          return false;
        }

        if (filters.endDate != null &&
            item.date.isAfter(filters.endDate!)) {
          return false;
        }

        return true;
      }).toList();
    });
  }
}


class FilterOptions {
  final String selectedType;
  final Set<String> selectedCategories;
  final DateTime? startDate;
  final DateTime? endDate;

  FilterOptions({
    required this.selectedType,
    required this.selectedCategories,
    this.startDate,
    this.endDate,
  });
}

class Item {
  final String type;
  final String category;
  final String name;
  final DateTime date;

  Item(this.type, this.category, this.name, this.date);
}

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String selectedType = 'Lost';
  Set<String> selectedCategories = {};
  DateTime? startDate;
  DateTime? endDate;

  void applyFilters() {
    if (selectedCategories.isEmpty) {
      showMessage('Please select at least one category.');
      return;
    }
    if (startDate == null || endDate == null) {
      showMessage('Please select both start and end dates.');
      return;
    }
    if (endDate!.isBefore(startDate!)) {
      showMessage('End date cannot be before start date.');
      return;
    }

    Navigator.pop(context, FilterOptions(
      selectedType: selectedType,
      selectedCategories: selectedCategories,
      startDate: startDate,
      endDate: endDate,
    ));
  }

  void showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Filters',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FilterSection(
              title: 'Type',
              children: [
                FilterButton(
                  text: 'Lost',
                  isSelected: selectedType == 'Lost',
                  onTap: () => setState(() => selectedType = 'Lost'),
                ),
                FilterButton(
                  text: 'Found',
                  isSelected: selectedType == 'Found',
                  onTap: () => setState(() => selectedType = 'Found'),
                ),
              ],
            ),
            SizedBox(height: 16),
            FilterSection(
              title: 'Categories',
              children: [
                _buildCategoryButton('Jewelry', Icons.diamond),
                _buildCategoryButton('Electronics', Icons.laptop),
                _buildCategoryButton('Books', Icons.book),
                _buildCategoryButton('Clothes', Icons.checkroom),
              ],
            ),
            SizedBox(height: 16),
            FilterSection(
              title: 'Date Range',
              children: [
                _buildDateButton('Start Date', startDate, (date) {
                  setState(() => startDate = date);
                }),
                _buildDateButton('End Date', endDate, (date) {
                  setState(() => endDate = date);
                }),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String text, IconData icon) {
    return FilterButton(
      text: text,
      icon: icon,
      isSelected: selectedCategories.contains(text),
      onTap: () {
        setState(() {
          if (selectedCategories.contains(text)) {
            selectedCategories.remove(text);
          } else {
            selectedCategories.add(text);
          }
        });
      },
    );
  }

  Widget _buildDateButton(String label, DateTime? date, Function(DateTime) onSelect) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) onSelect(pickedDate);
      },
      child: FilterButton(
        text: date != null ? '${date.toLocal()}'.split(' ')[0] : label,
        icon: Icons.calendar_today,
        isSelected: date != null,
      ),
    );
  }
}

class FilterSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  FilterSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  FilterButton({required this.text, this.icon, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}