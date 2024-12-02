import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:barter_frontend/models/contact.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';

class CreateGroupScreen extends StatefulWidget {
  static const String routePath = "/createGroup";
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class ContactListItem extends StatefulWidget {
  final ContactModel contact;
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
      title: Text(widget.contact.users.first.name),
      secondary: CircleAvatar(
        backgroundImage: widget.contact.users.first.profileImage != null
            ? NetworkImage(widget.contact.users.first.profileImage!)
            : null,
        child: widget.contact.users.first.profileImage == null
            ? Text(widget.contact.users.first.name[0])
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
      await userProvider.pickGroupImage(kIsWeb ? ImageSource.gallery : source);
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
            if (userProvider.groupImageData != null)
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

  Future<void> _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (_selectedContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one contact')),
      );
      return;
    }

    try {
      await userProvider.createGroup(
        name: _groupNameController.text.trim(),
        memberIds: _selectedContacts.toList(),
        description: _descriptionController.text.trim(),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group')),
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
              child: Icon(Icons.check),
              backgroundColor: AppTheme.primaryColor,
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
                    horizontal: kIsWeb ? 0.15.sw : 16.w,
                    vertical: kIsWeb ? 30.h : 16.h,
                  ),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: kIsWeb
                        ? CommonWidget.getCustomCard(
                            isDark: Theme.of(context).brightness == Brightness.dark,
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
          // Remove or comment out the existing header since we now have an AppBar
          // FadeInDown(
          //   child: Text('Create Group' ...),
          // ),
          // SizedBox(height: 32.h),

          // Update the group image size
          FadeInUp(
            child: Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 120.w,  // Reduced from 150.w
                      height: 120.w,  // Reduced from 150.w
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
                                  size: 40.r,
                                  color: AppTheme.primaryColor.withOpacity(0.7),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor.withOpacity(0.7),
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
          SizedBox(height: 10.h),

          // Form Fields with enhanced styling
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
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          FadeInRight(
            child: TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter group description',
                prefixIcon: Icon(Icons.description, color: AppTheme.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Participants section with card wrapper
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
                        Text(
                          'Select Participants',
                          style: Theme.of(context).textTheme.titleLarge
                    
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  FutureBuilder<List<ContactModel>>(
                    future: userProvider.getMockConnections(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No contacts found'));
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (_, __) => Divider(),
                        itemBuilder: (context, index) {
                          final contact = snapshot.data![index];
                          return ContactListItem(
                            contact: contact,
                            isSelected: _selectedContacts.contains(contact.conversationId),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedContacts.add(contact.conversationId);
                                } else {
                                  _selectedContacts.remove(contact.conversationId);
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
        SizedBox(height: 10.h),
          // Create Button with enhanced styling
          FadeInUp(
            child: ElevatedButton(
              onPressed: _createGroup,
             
              child: Text(
                'Create Group',
             
              ),
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