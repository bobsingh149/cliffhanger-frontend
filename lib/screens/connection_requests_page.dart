import 'package:barter_frontend/models/user_info.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';


class ConnectionRequestsPage extends StatelessWidget {
  static const String routePath = "/connection-requests";
  const ConnectionRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Connection Requests',
        ),
      ),
      body: FutureBuilder<List<UserInfoModel>>(
        future: Provider.of<UserProvider>(context,listen: false).getRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CommonWidget.getLoader();
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final requests = snapshot.data ?? [];

          return ListView(
            padding: EdgeInsets.all(10.r),
            children: [
              // Request Counter
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  'You have ${requests.length} pending requests',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              
              // Request Cards
              ...requests.map((request) => _buildRequestCard(
                    name: request.name,
                    imageUrl: request.profileImage ?? '',
                    isBookBuddy: true, // You might want to add this field to UserInfoModel
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestCard({
    required String name,
    required String imageUrl,
    required bool isBookBuddy,
  }) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: 3.h,horizontal: 12.w),
          child: Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(
                  imageUrl,
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  imageBuilder: (context, imageProvider) => Container(),
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.person),
                ),
              ),
               SizedBox(width: 16.w),
              
              // Request Info
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleLarge,
                          ),
                          if (isBookBuddy) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding:  EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.bookOpen,
                                    size: 14.r,
                                    color: theme.colorScheme.primary,
                                  ),
                                   SizedBox(width: 4.w),
                                  Text(
                                    'Book Buddy',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Action Text Links
                    Row(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Accept',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                         SizedBox(width: 16.w),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Decline',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
} 