import 'package:barter_frontend/models/book.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';


class Post extends StatefulWidget {
  final UserBook userBook;
  const Post({super.key, required this.userBook});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      
      children: [
                    
        Container(
          margin: EdgeInsets.only(left: 10.w, right: 10.w, top: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10.0,
                spreadRadius: 5.0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            
            children: [
              // Post Image
              Padding(
                padding:  EdgeInsets.only(top: 5.h),
                child: 
                          
                    Image.network(
                      widget.userBook.postImage ?? widget.userBook.coverImages![1],
                      height: 250.h,
                      width: double.infinity,
                      
                      fit: BoxFit.contain,
                    ),
                
                         
                  
              
              ),
              SizedBox(
                height: 10.h,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Title
                  Text(
                    widget.userBook.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.black),
                  ),
                  SizedBox(height: 7.h),
                  // Post Caption
                  Text(
                    widget.userBook.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
         Positioned(
          
                  left: 5.w,
                  top: 5.h,
                  child: TextButton(onPressed: (){}, child: Text("Masni Great",style: Theme.of(context).textTheme.bodyLarge!,)),
                  )
,
         Positioned(
          
                  right: 5.w,
                  top: 5.h,
                  child: 	IconButton(onPressed: (){}, icon: Icon(Icons.more_vert,size: 30.r,)))
,
      ],
    );
  }
}
