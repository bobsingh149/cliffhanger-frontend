import 'package:barter_frontend/models/book.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:expandable/expandable.dart';

class BookDetailsDialog extends StatelessWidget {
  final UserBook userBook;

  const BookDetailsDialog({Key? key, required this.userBook}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cover Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: userBook.coverImages?.isNotEmpty == true ? userBook.coverImages![0] : '',
                  height: 350.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              SizedBox(height: 16.h),
              // Title
              Text(
                userBook.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8.h),
              // Author
              Text(
                'by ${userBook.authors?.join(', ') ?? 'Unknown'}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.h),
              // Description
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8.h),
              ExpandablePanel(
                header: Container(),
                collapsed: ExpandableText(
                  userBook.description ?? 'No description available',
                  expandText: 'Show more',
                  maxLines: 3,
                  linkColor: Theme.of(context).primaryColor,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                expanded: Text(
                  userBook.description ?? 'No description available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToExpand: true,
                  tapBodyToCollapse: true,
                ),
              ),
              SizedBox(height: 16.h),
              // Close button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final String expandText;
  final Color linkColor;
  final TextStyle? style;

  const ExpandableText(
    this.text, {
    Key? key,
    this.maxLines = 3,
    this.expandText = 'Show more',
    required this.linkColor,
    this.style,
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
          style: widget.style ?? Theme.of(context).textTheme.bodyMedium,
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
                style: widget.style ?? Theme.of(context).textTheme.bodyMedium,
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
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: widget.linkColor,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Text(widget.text, style: widget.style ?? Theme.of(context).textTheme.bodyMedium);
        }
      },
    );
  }
}
