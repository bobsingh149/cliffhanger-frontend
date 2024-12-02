import 'package:barter_frontend/models/post.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:barter_frontend/widgets/book_details_dialog.dart';

class UserPost extends StatelessWidget {
  final PostModel userBook;
  const UserPost({super.key, required this.userBook});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => PostDetailsDialog(userBook: userBook),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 10.w : 0.w,
          vertical: kIsWeb ? 12.h : 0.h
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(kIsWeb ? 12 : 8)),
                child: CachedNetworkImage(
                  imageUrl: userBook.postImage ??
                      (userBook.coverImages?.isNotEmpty == true
                          ? userBook.coverImages![0]
                          : ''),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.surface,
                  ),
                  errorWidget: (context, url, error) {
                    AppLogger.instance.e('Error loading image: $url', error: error);
                    return Icon(Icons.error);
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(kIsWeb ? 16.r : 8.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => BookDetailsDialog(userBook: userBook),
                              );
                            },
                            child: Text(
                              userBook.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Tooltip(
                          message: 'View Book Details',
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => BookDetailsDialog(userBook: userBook),
                              );
                            },
                            child: FaIcon(
                              FontAwesomeIcons.bookOpen,
                              color: theme.colorScheme.secondary.withOpacity(0.7),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      userBook.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostDetailsDialog extends StatelessWidget {
  final PostModel userBook;

  const PostDetailsDialog({Key? key, required this.userBook}) : super(key: key);

  void _showCommentsDialog(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.7,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                AppBar(
                  title: Text('Comments'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: post.comments.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(post.comments[index].username),
                        subtitle: Text(post.comments[index].text),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.r),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implement add comment functionality
                        },
                        child: Text('Post'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: kIsWeb ? 300.w : double.infinity,
          maxHeight: 0.85.sh,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image section with gradient overlay
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        child: CachedNetworkImage(
                          imageUrl: userBook.postImage ?? 
                              (userBook.coverImages?.isNotEmpty == true ? userBook.coverImages![0] : ''),
                          width: double.infinity,
                          height: 0.45.sh,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.surfaceVariant,
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(Icons.error, size: 50.r, color: theme.colorScheme.error),
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black54,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Content section
                  Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userBook.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              CommonUtils.formatDateTime(userBook.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        // Caption
                        Text(
                          userBook.caption,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // Interaction buttons
                        Row(
                          children: [
                            _buildInteractionButton(
                              icon: FontAwesomeIcons.heart,
                              label: '${userBook.likesCount}',
                              theme: theme,
                            ),
                            SizedBox(width: 20.w),
                            _buildInteractionButton(
                              icon: FontAwesomeIcons.comment,
                              label: '${userBook.comments.length}',
                              onTap: () => _showCommentsDialog(context, userBook),
                              theme: theme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26,
                ),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
