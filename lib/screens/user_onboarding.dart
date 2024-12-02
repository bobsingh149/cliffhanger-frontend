import 'dart:typed_data';
import 'package:animate_do/animate_do.dart';
import 'package:barter_frontend/models/user.dart';
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
import 'package:image_picker_web/image_picker_web.dart'
    if (dart.library.io) 'package:barter_frontend/utils/mock_image_picker_web.dart';
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
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      userProvider = Provider.of<UserProvider>(context, listen: true);
      authProvider = Provider.of<AuthenticateProvider>(context, listen: false);
      isInit = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNodes[0]);
        }
      });
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
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 70,
        );
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
      setState(() {
        _isLoading = true;
      });

      // Save user info
      await userProvider!.saveUser(
        UserModel(
          id: AuthService.getInstance.currentUser!.uid,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 24.w : 16.w),
            child: Text(
              'Create Your Profile',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          SizedBox(height: 30.h),
          SizedBox(height: 10.h),
          Center(
            child: BounceInDown(
              duration: const Duration(milliseconds: 1000),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: kIsWeb ? 60 : 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        _imageData != null ? MemoryImage(_imageData!) : null,
                    child: _imageData == null
                        ? Icon(Icons.person, size: 40, color: Colors.grey[400])
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
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          isScrollControlled: true,
                          builder: (context) => FadeInUp(
                            duration: Duration(milliseconds: 500),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 24.h),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 4.h,
                                    margin: EdgeInsets.only(bottom: 20.h),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  if (!kIsWeb)
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 8.h),
                                      leading: Icon(Icons.camera_alt,
                                          size: 28,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      title: Text('Take a photo',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImage(ImageSource.camera);
                                      },
                                    ),
                                  ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 8.h),
                                    leading: Icon(Icons.photo_library,
                                        size: 28,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    title: Text('Choose from gallery',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                  if (_imageData != null)
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 8.h),
                                      leading: Icon(Icons.delete,
                                          size: 28, color: Colors.red),
                                      title: Text('Remove photo',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(color: Colors.red)),
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
                      child: Icon(Icons.add_a_photo, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 35.h),
          FadeInLeft(
            duration: Duration(milliseconds: 700),
            child: TextFormField(
              controller: _nameController,
              focusNode: _focusNodes[0],
              decoration: _buildInputDecoration('Name', isRequired: true),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              onFieldSubmitted: (_) => _fieldFocusChange(context, 0),
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
              maxLines: 1,
              onFieldSubmitted: (_) => _fieldFocusChange(context, 2),
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
          SizedBox(height: 35.h),
          FadeInUp(
            duration: Duration(milliseconds: 700),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(
                  'Complete Profile',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = kIsWeb ? 350.w : 0.w;
    final double verticalPadding = kIsWeb ? 10.h : 5.h;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? CommonWidget.getLoader()
            : FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: kIsWeb ? 0.15.sw : 0.w,
                    vertical: kIsWeb ? 30.h : 5.h,
                  ),
                  child: kIsWeb
                      ? Center(
                          child: CommonWidget.getCustomCard(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 0.5.sw,
                                minHeight: 0.85.sh,
                              ),
                              padding: EdgeInsets.all(20.r),
                              child: _buildFormContent(),
                            ),
                            isDark:
                                Theme.of(context).brightness == Brightness.dark,
                          ),
                        )
                      : Container(
                          constraints: BoxConstraints(
                            minHeight: 0.85.sh,
                          ),
                          padding: EdgeInsets.all(10.w),
                          child: _buildFormContent(),
                        ),
                ),
              ),
      ),
    );
  }
}
