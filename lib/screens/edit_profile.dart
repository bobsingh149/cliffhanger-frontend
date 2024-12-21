import 'dart:typed_data';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barter_frontend/widgets/static_search_bar.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker_web/image_picker_web.dart' if (dart.library.io) 'package:barter_frontend/utils/mock_image_picker_web.dart';
import 'package:provider/provider.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/models/user.dart';
import 'package:barter_frontend/utils/common_utils.dart';

class EditProfilePage extends StatefulWidget {
  static const String routePath = "/edit-profile";

   EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageData;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedCity;
  String? _age;
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id ?? '';
      final userSetup = await userProvider.getUserSetup(userId);
      
      setState(() {
        _nameController.text = userSetup.name ?? '';
        _bioController.text = userSetup.bio ?? '';
        _selectedCity = userSetup.city;
        _age = userSetup.age?.toString();
        _imageUrl = userSetup.profileImage;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
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

  void _fieldFocusChange(BuildContext context, int currentIndex) {
    if (currentIndex < _focusNodes.length - 1) {
      _focusNodes[currentIndex].unfocus();
      FocusScope.of(context).requestFocus(_focusNodes[currentIndex + 1]);
    } else {
      _focusNodes[currentIndex].unfocus();
    }
  }

  InputDecoration _buildInputDecoration(String label, {bool isRequired = false}) {
    return InputDecoration(
      labelText: isRequired ? '$label *' : label,
    );
  }

  void _removeImage() {
    setState(() {
      _imageData = null;
      _imageUrl = null;
    });
  }

  Future<void> _pickImage([ImageSource? source]) async {
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
          source: source ?? ImageSource.gallery,
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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        
        final updatedUser = UserModel(
          id: userProvider.user?.id ?? '',
          name: _nameController.text,
          bio: _bioController.text,
          age: _age != null ? int.parse(_age!) : null,
          city: _selectedCity,
        );

        await userProvider.updateUser(updatedUser, _imageData);
        
        if (mounted) {
          CommonUtils.displaySnackbar(
            context: context,
            message: 'Profile updated successfully',
            mode: SnackbarMode.success,
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          CommonUtils.displaySnackbar(
            context: context,
            message: 'Error updating profile: $e',
            mode: SnackbarMode.error,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kIsWeb ? 30.h : null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: !kIsWeb ?  Text('Edit Profile') : null,
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeInUp(
          duration: const Duration(milliseconds: 700),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: kIsWeb ? 0.15.sw : 0.w,
              vertical: kIsWeb ? 0.h : 0.h,
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
                      isDark: Theme.of(context).brightness == Brightness.dark,
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

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kIsWeb) Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Edit Profile',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Center(
            child: BounceInDown(
              duration: const Duration(milliseconds: 1000),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: kIsWeb ? 60 : 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _imageData != null 
                        ? MemoryImage(_imageData!)
                        : _imageUrl != null 
                            ? NetworkImage(_imageUrl!) as ImageProvider
                            : null,
                    child: _imageData == null && _imageUrl == null
                        ? Icon(Icons.person, size: 40, color: Colors.grey[400])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton.small(
                      onPressed: () => _showImagePickerModal(context),
                      child: Icon(Icons.add_a_photo, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 35.h),
          _buildTextField(
            controller: _nameController,
            label: 'Name',
            icon: Icons.person_outline,
            focusNode: _focusNodes[0],
            onFocusChange: (hasFocus) => _fieldFocusChange(context, 0),
          ),
          SizedBox(height: 20.h),
          _buildDropdownField(
            value: _age,
            label: 'Age',
            icon: Icons.cake_outlined,
            items: List.generate(86, (index) => (index + 15).toString()),
            onChanged: (value) => setState(() => _age = value),
            focusNode: _focusNodes[1],
            onFocusChange: (hasFocus) => _fieldFocusChange(context, 1),
          ),
            SizedBox(height: 20.h),
          StaticSearchbar(
            onItemSelected: (selectedCity) {
              setState(() => _selectedCity = selectedCity);
            },
            focusNode: _focusNodes[3],
            initialValue: _selectedCity,
          ),
          SizedBox(height: 20.h),
          _buildTextField(
            controller: _bioController,
            label: 'Bio',
            icon: Icons.description_outlined,
            maxLines: 2,
            focusNode: _focusNodes[2],
            onFocusChange: (hasFocus) => _fieldFocusChange(context, 2),
          ),
        
          SizedBox(height: 40.h),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40.h),
              ),
              child: _isLoading 
                  ? CommonWidget.getButtonLoader(color: Colors.white)
                  : Text('Save Changes'),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    FocusNode? focusNode,
    Function(bool)? onFocusChange,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
       
      ),
      validator: (value) {
        if (value!.isEmpty && label == 'Name') {
          return 'Please enter your name';
        }
        return null;
      },
      focusNode: focusNode,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    FocusNode? focusNode,
    Function(bool)? onFocusChange,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
       
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      focusNode: focusNode,
    );
  }

  void _showImagePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!kIsWeb)
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imageData != null)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }
}
