import 'package:barter_frontend/models/post.dart';
import 'package:barter_frontend/models/post_category.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/screens/profile.dart';
import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:barter_frontend/widgets/book_details_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:barter_frontend/provider/post_provider.dart';
import 'package:barter_frontend/models/save_request_input.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: kIsWeb ? EdgeInsets.zero : EdgeInsets.only(left: 5.w,right: 5.w,bottom: 5.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w,vertical: kIsWeb ? 5.h : 1.h),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15.r,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.post.userInfo.profileImage ??
                            'https://picsum.photos/seed/picsum/200/300',
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.person, size: 20),
                        fit: BoxFit.cover,
                        width: 41.w,
                        height: 41.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            userId: widget.post.userInfo.id,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      widget.post.userInfo.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 6.w, bottom: 3.w),
                    child: IconButton(
                      icon: FaIcon(FontAwesomeIcons.userPlus,
                          color: AppTheme.primaryColor, size: 17),
                      onPressed: () async {
                        try {
                          final currentUserId =
                              AuthService.getInstance.currentUser!.uid;
                          final requestInput = SaveRequestInput(
                            id: currentUserId,
                            requestId: widget.post.userInfo.id,
                          );

                          await Provider.of<UserProvider>(context,
                                  listen: false)
                              .saveRequest(requestInput);

                          if (context.mounted) {
                            CommonUtils.displaySnackbar(
                              context: context,
                              message: 'Connection request sent successfully!',
                              mode: SnackbarMode.success,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            CommonUtils.displaySnackbar(
                              context: context,
                              message: 'Failed to send connection request: $e',
                              mode: SnackbarMode.error,
                            );
                          }
                        }
                      },
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 7/8,
              child: CachedNetworkImage(
                imageUrl: widget.post.postImage ?? widget.post.coverImages![2],
                // post.postImage ??
                //     (post.coverImages != null ? post.coverImages![2] : ''),
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Center(
                  child: Icon(Icons.error, size: 50.r, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12.w,right: 12.w,top: 7.h,bottom: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => BookDetailsDialog(
                                        userBook: widget.post),
                                  );
                                },
                                child: Text(
                                  widget.post.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge,
        
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Tooltip(
                              message: 'View Book Details',
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => BookDetailsDialog(
                                        userBook: widget.post),
                                  );
                                },
                                child: Icon(FontAwesomeIcons.bookOpen,
                                    size: 17.r, color: AppTheme.secondaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _buildCategoryTag(context, widget.post.category),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _buildExpandableText(widget.post.caption),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          LikeButton(
                            item: widget.post,
                            postId: widget.post.id,
                            onLikeChanged: (newLikeCount) {
                              // TODO: Implement like functionality
                            },
                          ),
                          SizedBox(width: 17.w),
                          TextButton(
                            onPressed: () =>
                                showCommentsDialog(context, widget.post),
                            child: Text(
                                'View ${widget.post.commentCount} ${widget.post.commentCount == 1 ? 'comment' : 'comments'}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: kIsWeb ? 5.h : 0.h),
                  Text(
                    CommonUtils.formatDateTime(widget.post.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableText(String text) {
    return ExpandablePanel(
      key: UniqueKey(),
      collapsed: ExpandableText(
        text,
        expandText: 'Show more',
        maxLines: 1,
        linkColor: AppTheme.primaryColor,
      ),
      expanded: Text(text),
      theme: const ExpandableThemeData(
        headerAlignment: ExpandablePanelHeaderAlignment.center,
        tapBodyToExpand: false,
        tapBodyToCollapse: false,
      ),
    );
  }

  void showCommentsDialog(BuildContext context, PostModel post) {
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
                                                        .bodySmall
                                                        
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
                                                      .bodyMedium),
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
                              setState(() {
                                post.commentCount++;
                              });

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

  Widget _buildCategoryTag(BuildContext context, PostCategory category) {
    Color tagColor;
    switch (category) {
      case PostCategory.currentlyReading:
        tagColor = AppTheme.secondaryColor;
        break;
      case PostCategory.barter:
        tagColor = Colors.pink;
        break;
      case PostCategory.favourite:
        tagColor = Colors.orange;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category.displayName,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final String expandText;
  final Color linkColor;

  const ExpandableText(
    this.text, {
    Key? key,
    this.maxLines = 2,
    this.expandText = 'Show more',
    required this.linkColor,
  }) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextSpan textSpan = TextSpan(
          text: widget.text,
          style: Theme.of(context).textTheme.bodyMedium,
        );

        final TextPainter textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        if (textPainter.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                maxLines: _expanded ? null : widget.maxLines,
                overflow:
                    _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: Text(
                    _expanded ? 'Show less' : widget.expandText,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: 10),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Text(widget.text);
        }
      },
    );
  }
}

class LikeButton extends StatefulWidget {
  final dynamic item; // Can be either PostModel or Comment
  final Function(int) onLikeChanged;
  final bool isComment;
  final String postId;
  final String commentId;

  const LikeButton({
    Key? key,
    required this.item,
    required this.onLikeChanged,
    required this.postId,
    this.commentId = '',
    this.isComment = false,
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(_controller);

    if (widget.isComment) {
      _likesCount = widget.item.likesCount;
      _isLiked = false;
    } else {
      _likesCount = widget.item.likesCount;
      final currentUserId = AuthService.getInstance.currentUser?.uid;
      _isLiked = currentUserId != null &&
          widget.item.likes != null &&
          widget.item.likes.contains(currentUserId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    try {
      if (widget.isComment) {
        // Handle comment like
        await postProvider.likeComment(widget.postId, widget.commentId);
      } else {
        // Handle post like
        await postProvider.likePost(widget.postId);
      }

      setState(() {
        _isLiked = !_isLiked;
        if (_isLiked) {
          _controller.forward().then((_) => _controller.reverse());
          _likesCount++;
        } else {
          _likesCount--;
        }
        widget.onLikeChanged(_likesCount);
      });
    } catch (error) {
      CommonUtils.displaySnackbar(
        context: context,
        message:
            'Failed to like ${widget.isComment ? 'comment' : 'post'}. Please try again.',
        mode: SnackbarMode.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleLike,
      child: Padding(
        padding: EdgeInsets.all(4.r),
        child: Row(
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.red : Colors.grey,
                size: widget.isComment ? 16 : 20,
              ),
            ),
            SizedBox(width: 4.w),
            Text('$_likesCount', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
