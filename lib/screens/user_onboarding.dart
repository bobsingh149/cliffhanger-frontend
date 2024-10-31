import 'dart:typed_data';
import 'package:animate_do/animate_do.dart';
import 'package:barter_frontend/models/user_info.dart';
import 'package:barter_frontend/provider/auth_provider.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/screens/home_page.dart';
import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:barter_frontend/widgets/static_search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatefulWidget {
  static const String routePath = "/onboarding";

  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  UserProvider? userProvider;
  AuthenticateProvider? authProvider;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageData;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedCity;
  String? _age;

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      userProvider = Provider.of<UserProvider>(context,listen: true);
      authProvider = Provider.of<AuthenticateProvider>(context,listen: false);
     FocusScope.of(context).requestFocus(_focusNodes[0]);
      isInit = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (kIsWeb) {
        final pickedFile = await ImagePickerWeb.getImageAsBytes();
        if (pickedFile != null) {
          setState(() {
            _imageData = pickedFile;
          });
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageData = bytes;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _imageData = null;
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Sign up the user with email and password
      User? user = await AuthService.getInstance.signUpWithEmail(
        authProvider!.email!, // Assuming email is stored in the provider
        authProvider!.password!, // Assuming password is stored in the provider
      );
      if (user == null) {
        throw Exception('Failed to create user account');
      }

      // Save user info
      await userProvider!.saveUser(
        UserInfoModel(
          id: user.uid,
          name: _nameController.text,
          bio: _bioController.text,
          age: int.parse(_age!),
          city: _selectedCity,
        ),
        _imageData,
      );

      if (mounted) {
        Navigator.of(context).popAndPushNamed(HomePage.routePath);
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _fieldFocusChange(BuildContext context, int currentIndex) {
    if (currentIndex < _focusNodes.length - 1) {
      _focusNodes[currentIndex].unfocus();
      FocusScope.of(context).requestFocus(_focusNodes[currentIndex + 1]);
    } else {
      _focusNodes[currentIndex].unfocus();
    }
  }

   InputDecoration _buildInputDecoration(String label,
        {bool isRequired = false}) {
      return InputDecoration(
        labelText: isRequired ? '$label *' : label,
      );
    }


  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      body: SafeArea(
        child: userProvider!.isLoading
            ? CommonWidget.getLoader()
            : FadeInUp(
                duration: Duration(milliseconds: 700),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Your Profile',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor),
                          ),
                          SizedBox(height: 24.h),
                          Center(
                            child: BounceInDown(
                              duration: Duration(milliseconds: 1000),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 60.w,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: _imageData != null
                                        ? MemoryImage(_imageData!)
                                        : null,
                                    child: _imageData == null
                                        ? Icon(Icons.person,
                                            size: 60, color: Colors.grey[400])
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: FloatingActionButton.small(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20)),
                                          ),
                                          builder: (context) => FadeInUp(
                                            duration:
                                                Duration(milliseconds: 500),
                                            child: Container(
                                              padding: EdgeInsets.all(16),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (!kIsWeb)
                                                    ListTile(
                                                      leading: Icon(
                                                          Icons.camera_alt),
                                                      title:
                                                          Text('Take a photo'),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        _pickImage(
                                                            ImageSource.camera);
                                                      },
                                                    ),
                                                  ListTile(
                                                    leading: Icon(
                                                        Icons.photo_library),
                                                    title: Text(
                                                        'Choose from gallery'),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _pickImage(
                                                          ImageSource.gallery);
                                                    },
                                                  ),
                                                  if (_imageData != null)
                                                    ListTile(
                                                      leading: Icon(
                                                          Icons.delete,
                                                          color: Colors.red),
                                                      title: Text(
                                                          'Remove photo',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        _removeImage();
                                                      },
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.add_a_photo),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 32.h),
                          FadeInLeft(
                            duration: Duration(milliseconds: 700),
                            child: TextFormField(
                              controller: _nameController,
                              focusNode: _focusNodes[0],
                              decoration: _buildInputDecoration('Name',
                                  isRequired: true),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) =>
                                  _fieldFocusChange(context, 0),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          FadeInRight(
                            duration: Duration(milliseconds: 700),
                            child: DropdownButtonFormField<String>(
                              focusNode: _focusNodes[1],
                              menuMaxHeight: 0.3.sh,
                              decoration: _buildInputDecoration('Age'),
                              value: _age,
                              items: List.generate(86, (index) {
                                return DropdownMenuItem<String>(
                                  value: (index + 15).toString(),
                                  child: Text((index + 15).toString()),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  _age = value;
                                });
                                _fieldFocusChange(context, 1);
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),
                          FadeInLeft(
                            duration: Duration(milliseconds: 700),
                            child: TextFormField(
                              controller: _bioController,
                              focusNode: _focusNodes[2],
                              decoration: _buildInputDecoration('Bio'),
                              maxLines: 2,
                              onFieldSubmitted: (_) =>
                                  _fieldFocusChange(context, 2),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          FadeInRight(
                            duration: Duration(milliseconds: 700),
                            child: StaticSearchbar(
                              focusNode: _focusNodes[3],
                              onItemSelected: (selectedCity) {
                                _selectedCity = selectedCity;
                                _fieldFocusChange(context, 3);
                              },
                            ),
                          ),
                          SizedBox(height: 32.h),
                          FadeInUp(
                            duration: Duration(milliseconds: 700),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submit,
                                child: Text('Complete Profile',
                                    style: TextStyle(fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
