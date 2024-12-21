import 'package:barter_frontend/models/user_setup.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:image_picker_web/image_picker_web.dart'
    if (dart.library.io) 'package:barter_frontend/utils/mock_image_picker_web.dart';

class CreateGroupScreen extends StatefulWidget {
  static const String routePath = "/createGroup";
  CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class ContactListItem extends StatefulWidget {
  final ConversationModel contact;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const ContactListItem({
    Key? key,
    required this.contact,
    required this.isSelected,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<ContactListItem> createState() => _ContactListItemState();
}

class _ContactListItemState extends State<ContactListItem> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: widget.isSelected,
      onChanged: widget.onChanged,
      title: Text(widget.contact.userResponse!.name),
      secondary: CircleAvatar(
        backgroundImage: widget.contact.userResponse!.profileImage != null
            ? NetworkImage(widget.contact.userResponse!.profileImage!)
            : null,
        child: widget.contact.userResponse!.profileImage == null
            ? Text(widget.contact.userResponse!.name[0])
            : null,
      ),
    );
  }
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Set<String> _selectedContacts = {};
  late UserProvider userProvider;
  bool isInit = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      userProvider = Provider.of<UserProvider>(context, listen: true);
      isInit = false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (kIsWeb) {
        final pickedFile = await ImagePickerWeb.getImageAsBytes();
        if (pickedFile != null) {
          await userProvider.setGroupImage(pickedFile);
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 70,
        );
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          await userProvider.setGroupImage(bytes);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _removeImage() {
    userProvider.removeGroupImage();
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      builder: (context) => FadeInUp(
        duration: Duration(milliseconds: 500),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (!kIsWeb)
                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  leading: Icon(Icons.camera_alt,
                      size: 28, color: Theme.of(context).colorScheme.primary),
                  title: Text('Take a photo',
                      style: Theme.of(context).textTheme.titleMedium),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                leading: Icon(Icons.photo_library,
                    size: 28, color: Theme.of(context).colorScheme.primary),
                title: Text('Choose from gallery',
                    style: Theme.of(context).textTheme.titleMedium),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (userProvider.groupImageData != null)
                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  leading: Icon(Icons.delete, size: 28, color: Colors.red),
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
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      CommonUtils.displaySnackbar(
        context: context,
        message: 'Please enter a group name',
        mode: SnackbarMode.error,
      );
      return;
    }

    if (_selectedContacts.isEmpty) {
      CommonUtils.displaySnackbar(
        context: context,
        message: 'Please select at least one contact',
        mode: SnackbarMode.error,
      );
      return;
    }

    try {
      await userProvider.createGroup(
        name: _groupNameController.text.trim(),
        memberIds: _selectedContacts.toList(),
        description: _descriptionController.text.trim(),
      );
      CommonUtils.displaySnackbar(
        context: context,
        message: 'Group created successfully!',
        mode: SnackbarMode.success,
      );
      Navigator.pop(context);
    } catch (e) {
      CommonUtils.displaySnackbar(
        context: context,
        message: 'Failed to create group: ${e.toString()}',
        mode: SnackbarMode.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: FloatingActionButton.small(
              onPressed: _createGroup,
              child:  Icon(Icons.check),
              backgroundColor: AppTheme.primaryColor.withOpacity(
                Theme.of(context).brightness == Brightness.light ? 1.0 : 0.7,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: userProvider.isLoading
            ? CommonWidget.getLoader()
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: kIsWeb ? 0.25.sw : 16.w,
                    vertical: kIsWeb ? 30.h : 16.h,
                  ),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: kIsWeb
                        ? CommonWidget.getCustomCard(
                            isDark:
                                Theme.of(context).brightness == Brightness.dark,
                            child: _buildContent(),
                          )
                        : _buildContent(),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      constraints: BoxConstraints(maxWidth: kIsWeb ? 600 : double.infinity),
      padding: EdgeInsets.all(kIsWeb ? 32.r : 16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Group Image Section
          FadeInUp(
            child: Center(
              child: Stack(
                children: [
                  InkWell(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 120, // Reduced from 150.w
                      height: 120, // Reduced from 150.w
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: userProvider.groupImageData != null
                          ? ClipOval(
                              child: Image.memory(
                                userProvider.groupImageData!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: AppTheme.primaryColor.withOpacity(0.7),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.7),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Group Name Field
          FadeInLeft(
            child: TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
                prefixIcon: Icon(Icons.group, color: AppTheme.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),

          // Description Field
          FadeInRight(
            child: TextField(
              controller: _descriptionController,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter group description',
                prefixIcon:
                    Icon(Icons.description, color: AppTheme.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Participants Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInLeft(
                    child: Row(
                      children: [
                        Icon(Icons.people, color: AppTheme.primaryColor),
                        SizedBox(width: 8.w),
                        Text('Select Participants',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FutureBuilder<List<ConversationModel>>(
                    future: userProvider.getNonGroupContacts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No contacts found'));
                      }

                      final List<ConversationModel> contacts = snapshot.data!;
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: contacts.length,
                        separatorBuilder: (_, __) => Divider(),
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          return ContactListItem(
                            contact: contact,
                            isSelected: _selectedContacts
                                .contains(contact.userResponse!.id),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedContacts
                                      .add(contact.userResponse!.id);
                                } else {
                                  _selectedContacts
                                      .remove(contact.userResponse!.id);
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 5.h),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Create Button
          FadeInUp(
            child: ElevatedButton(
              onPressed: _createGroup,
              child: Text('Create Group'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
