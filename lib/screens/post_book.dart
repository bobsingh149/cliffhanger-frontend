// lib/screens/post_book_page.dart

import 'package:flutter/material.dart';

class PostBookPage extends StatefulWidget {
  @override
  _PostBookPageState createState() => _PostBookPageState();
}

class _PostBookPageState extends State<PostBookPage> {
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();

  // Define the categories
  final List<String> _categories = [
    'Currently Reading',
    'Barter',
    'Favourite Book',
  ];
  
  // Track the selected category
  String _selectedCategory = 'Currently Reading';

  @override
  void dispose() {
    _isbnController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post a Book'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ISBN Field and Search Button Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _isbnController,
                      decoration: InputDecoration(
                        labelText: 'ISBN',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Implement search functionality
                      print('Search ISBN: ${_isbnController.text}');
                    },
                    child: Text('Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown, // Change to your theme color
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Caption Field
              TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  labelText: 'Caption',
                  hintText: 'Add a caption for the book...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // Allow for multi-line captions
              ),
              SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              SizedBox(height: 24),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Implement book posting functionality
                    print('Post Book with ISBN: ${_isbnController.text}');
                    print('Caption: ${_captionController.text}');
                    print('Category: $_selectedCategory');
                  },
                  child: Text('Post Book'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.brown, // Change to your theme color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
