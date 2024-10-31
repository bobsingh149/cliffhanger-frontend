import 'package:barter_frontend/models/book.dart';
import 'package:barter_frontend/models/book_category.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PostCard extends StatelessWidget {
  final UserBook post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 3,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: 'https://picsum.photos/seed/picsum/200/300',
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.person, size: 20.r),
                        fit: BoxFit.cover,
                        width: 41.r,
                        height: 41.r,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    post.username,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.w),
                    child: IconButton(
                      icon: FaIcon(FontAwesomeIcons.userPlus, color: AppTheme.primaryColor, size: 17.r),
                      onPressed: () {
                        // TODO: Implement connect functionality
                      },
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            CachedNetworkImage(
              imageUrl: post.postImage ?? (post.coverImages !=null ? post.coverImages![2] : ''),
              width: double.infinity,
              height: 0.47.sh,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Center(
                child: Icon(Icons.error, size: 50.r, color: Colors.grey),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.title,
                                style: Theme.of(context).textTheme.bodyLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Icon(FontAwesomeIcons.bookOpen, size: 17.r, color: const Color.fromARGB(100, 139, 69, 19)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 7.h),
                  _buildExpandableText(post.caption),
                  SizedBox(height: 17.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          LikeButton(
                            post: post,
                            onLikeChanged: (newLikeCount) {
                              // TODO: Implement like functionality
                            },
                          ),
                          SizedBox(width: 17.w),
                          TextButton(
                            onPressed: () => _showCommentsDialog(context, post),
                            child: Text('View ${post.comments.length} ${post.comments.length == 1 ? 'comment' : 'comments'}'),
                          ),
                        ],
                      ),
                      _buildCategoryTag(context, post.category),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    CommonUtils.formatDateTime(post.createdAt),
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

  void _showCommentsDialog(BuildContext context, UserBook post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
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
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        category.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
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
                overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
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
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10),
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
  final UserBook post;
  final Function(int) onLikeChanged;

  const LikeButton({Key? key, required this.post, required this.onLikeChanged}) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _controller.forward().then((_) => _controller.reverse());
        widget.onLikeChanged(widget.post.likesCount + 1);
      } else {
        widget.onLikeChanged(widget.post.likesCount - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.grey,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 4.w),
          Text('${widget.post.likesCount}', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
