import 'package:barter_frontend/models/book.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:barter_frontend/widgets/book_details_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class UserPost extends StatelessWidget {
  final UserBook userBook;
  const UserPost({super.key, required this.userBook});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: CachedNetworkImage(
              imageUrl: userBook.postImage ?? (userBook.coverImages?.isNotEmpty == true ? userBook.coverImages![0] : ''),
              height: 250.h,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) {
                AppLogger.instance.e('Error loading image: $url', error: error);
                return Icon(Icons.error);
              },
            ),
          ),
          Padding(
            
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Title and Book Icon (now tappable)
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => BookDetailsDialog(userBook: userBook),
                    );
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          userBook.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      FaIcon(
                        FontAwesomeIcons.bookOpen,
                        color: theme.colorScheme.secondary.withOpacity(0.7),
                        size: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                // Post Caption
                Text(
                  userBook.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
