import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class OnboardingPage extends StatefulWidget {
  static const String routePath = "/onboarding";

  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String? _age; // Change to String? for Dropdown
  String _bio = '';

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Handle the submission of the data
      print('Name: $_name');
      print('Age: $_age');
      print('Bio: $_bio');
      // You can also navigate to the next page or save the data here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Picture Section
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Wrap(
                          children: [
                            ListTile(
                              leading: Icon(Icons.camera),
                              title: Text('Camera'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo),
                              title: Text('Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : null,
                    child: _imageFile == null
                        ? Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey[700],
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 20),

                // Name Input
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name *'),
                  onChanged: (value) => _name = value,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10.h),

                // Age Dropdown
                DropdownButtonFormField<String>(
                  menuMaxHeight: 0.3.sh,
                  decoration: InputDecoration(labelText: 'Age'),
                  value: _age,
                  items: List.generate(100, (index) {
                    return DropdownMenuItem<String>(
                      value: (index + 1).toString(),
                      child: Text((index + 1).toString()),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _age = value;
                    });
                  },
                  // Optional: Add a validator if required
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your age';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Bio Input
                TextFormField(
                  decoration: InputDecoration(labelText: 'Bio'),
                  maxLines: 3,
                  onChanged: (value) => _bio = value,
                ),
                SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Onboarding Page',
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
    ),
    home: OnboardingPage(),
  ));
}
