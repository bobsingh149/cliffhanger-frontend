import 'package:barter_frontend/models/post.dart';
import 'package:barter_frontend/provider/post_provider.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:barter_frontend/widgets/post_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:barter_frontend/widgets/book_details_dialog.dart';
import 'package:provider/provider.dart';

class UserPost extends StatefulWidget {
  final PostModel userBook;
  const UserPost({super.key, required this.userBook});

  @override
  State<UserPost> createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => PostDetailsDialog(userBook: widget.userBook),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 10.w : 0.w, vertical: kIsWeb ? 12.h : 0.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(kIsWeb ? 12 : 8)),
                child: CachedNetworkImage(
                  imageUrl: widget.userBook.postImage ??
                      (widget.userBook.coverImages?.isNotEmpty == true
                          ? widget.userBook.coverImages![2]
                          : ''),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.surface,
                  ),
                  errorWidget: (context, url, error) {
                    AppLogger.instance
                        .e('Error loading image: $url', error: error);
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
                                builder: (context) => BookDetailsDialog(
                                    userBook: widget.userBook),
                              );
                            },
                            child: Text(
                              widget.userBook.title,
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
                                builder: (context) => BookDetailsDialog(
                                    userBook: widget.userBook),
                              );
                            },
                            child: FaIcon(
                              FontAwesomeIcons.bookOpen,
                              color:
                                  theme.colorScheme.secondary.withOpacity(0.7),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.userBook.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    SizedBox(height: kIsWeb ? 21.h : 10.h),
                    Row(
                      children: [
                        _buildInteractionButton(
                          icon: FontAwesomeIcons.heart,
                          label: '${widget.userBook.likesCount}',
                          theme: theme,
                        ),
                        SizedBox(width: 16.w),
                        _buildInteractionButton(
                          icon: FontAwesomeIcons.comment,
                          label: '${widget.userBook.commentCount}',
                          onTap: () {
                            PostDetailsDialog(userBook: widget.userBook)
                                ._showCommentsDialogForUser(
                                    context, widget.userBook);
                          },
                          theme: theme,
                        ),
                      ],
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

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class PostDetailsDialog extends StatelessWidget {
  final PostModel userBook;
  final TextEditingController _commentController = TextEditingController();

  PostDetailsDialog({super.key, required this.userBook});

  void _showCommentsDialogForUser(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: kIsWeb ? 0.9 : 0.7,
          minChildSize: kIsWeb ? 0.7 : 0.5,
          maxChildSize: kIsWeb ? 0.95 : 0.7,
          expand: false,
          builder: (_, controller) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                children: [
                  AppBar(
                    title: Text('Comments'),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          _commentController.clear();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: post.commentCount == 0
                        ? Center(child: Text('No comments yet'))
                        : FutureBuilder<List<Comment>>(
                            future: Provider.of<PostProvider>(context,
                                    listen: false)
                                .getPostComments(post.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error loading comments'));
                              }
                              final comments = snapshot.data ?? [];
                              return ListView.builder(
                                controller: controller,
                                itemCount: comments.length,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.r, vertical: 8.r),
                                itemBuilder: (context, index) {
                                  final comment = comments[index];
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.r),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 16.r,
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: comment.userBasicInfo
                                                      .profileImage ??
                                                  'https://picsum.photos/seed/picsum/200/300',
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Icon(Icons.person, size: 20),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    comment.userBasicInfo.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                      CommonUtils
                                                          .formatDateTime(
                                                              comment
                                                                  .timestamp),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall),
                                                ],
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(comment.text,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall),
                                              SizedBox(height: 8.h),
                                              Row(
                                                children: [
                                                  LikeButton(
                                                    item: comment,
                                                    postId: post.id,
                                                    commentId: comment.id,
                                                    onLikeChanged:
                                                        (newLikeCount) {
                                                      // TODO: Implement comment like functionality
                                                    },
                                                    isComment: true,
                                                  ),
                                                  SizedBox(width: 16.w),
                                                  Text(
                                                    'Reply',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.r).copyWith(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 8.r,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          onPressed: () async {
                            if (_commentController.text.trim().isEmpty) return;

                            try {
                              await Provider.of<PostProvider>(context,
                                      listen: false)
                                  .addComment(
                                      post.id, _commentController.text.trim());

                              // Increment comment count
                              post.commentCount++;

                              // Clear the input field
                              _commentController.clear();

                              // Close keyboard
                              FocusScope.of(context).unfocus();
                            } catch (e) {
                              if (context.mounted) {
                                CommonUtils.displaySnackbar(
                                  context: context,
                                  message: 'Failed to add comment',
                                  mode: SnackbarMode.error,
                                );
                              }
                            }
                          },
                          child: Text('Post'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _commentController.clear();
    });
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
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                        child: CachedNetworkImage(
                          imageUrl: userBook.postImage ??
                              (userBook.coverImages?.isNotEmpty == true
                                  ? userBook.coverImages![2]
                                  : ''),
                          width: double.infinity,
                          height: 0.45.sh,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.surfaceVariant,
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(Icons.error,
                                size: 50.r, color: theme.colorScheme.error),
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
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        // Caption
                        Text(
                          userBook.caption,
                          style: theme.textTheme.bodyMedium?.copyWith(
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
                              label: '${userBook.commentCount}',
                              onTap: () =>
                                  _showCommentsDialogForUser(context, userBook),
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
