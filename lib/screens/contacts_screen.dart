import 'package:barter_frontend/models/contact.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/screens/chat_screen.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:barter_frontend/screens/create_group_screen.dart';
import 'package:barter_frontend/utils/common_decoration.dart';

class ContactsScreen extends StatefulWidget {
  static const String routePath = '/contacts';

  ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
        automaticallyImplyLeading: false,
        title: Text(
          'Contacts',
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'start_group') {
                Navigator.pushNamed(context, CreateGroupScreen.routePath);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'start_group',
                child: Row(
                  children: [
                    Icon(Icons.group_add),
                    SizedBox(width: 8.w),
                    Text('Start a Group'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: kIsWeb ? 800.w : double.infinity,
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                // Force refresh contacts
                // await Provider.of<UserProvider>(context, listen: false).getConnections(forceRefresh: true);
              },
              child: FutureBuilder<List<ContactModel>>(
                future: Provider.of<UserProvider>(context, listen: false)
                    .getAllContacts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CommonWidget.getLoader();
                  }

                  if (snapshot.hasError) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      CommonUtils.displaySnackbar(
                        context: context,
                        message: 'Could not load contacts',
                        mode: SnackbarMode.error,
                      );
                    });
                    return const SizedBox.shrink();
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No contacts found'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final contact = snapshot.data![index];
                      return _buildContactCard(context, contact);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, ContactModel contact) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: kIsWeb ? 16.w : 3.w,
        vertical: 3.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: CommonDecoration.getWebAwareBorderSide(context),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
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
                    fontSize: 20,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(),
              ),
            SizedBox(height: 4.h),
            Icon(
              Icons.chevron_right,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(contact: contact),
            ),
          );
        },
      ),
    );
  }
}
