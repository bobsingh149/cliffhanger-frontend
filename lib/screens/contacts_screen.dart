import 'package:barter_frontend/models/contact.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/screens/chat_screen.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:barter_frontend/utils/common_utils.dart';

class ContactsScreen extends StatelessWidget {
  static const String routePath = '/contacts';

  const ContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contacts',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ContactModel>>(
        future: Provider.of<UserProvider>(context, listen: false).getConnections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CommonWidget.getLoader();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No contacts found'));
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 6.h),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final contact = snapshot.data![index];
              return _buildContactCard(context, contact);
            },
          );
        },
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, ContactModel contact) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 6.h),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      shadowColor: AppTheme.primaryColor.withOpacity(0.2),
      child: ListTile(
        contentPadding: EdgeInsets.all(6.r),
        leading: CircleAvatar(
          radius: 25.r,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          backgroundImage: contact.getDisplayImage() != null
              ? CachedNetworkImageProvider(contact.getDisplayImage()!)
              : null,
          child: contact.getDisplayImage() == null
              ? Text(
                  contact.getDisplayName()[0].toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                )
              : null,
        ),
        title: Text(
          contact.getDisplayName(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(
          contact.lastMessage ?? 'No messages yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (contact.lastMessageTime != null)
              Text(
                CommonUtils.formatDateTime(contact.lastMessageTime!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor.withOpacity(0.6),
                    ),
              ),
            SizedBox(height: 4.h),
            Icon(
              Icons.chevron_right,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            ChatScreen.routePath,
            arguments: contact,
          );
        },
      ),
    );
  }
}