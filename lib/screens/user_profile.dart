import 'package:barter_frontend/models/book.dart';
import 'package:barter_frontend/models/book_category.dart';
import 'package:barter_frontend/provider/post_provider.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:barter_frontend/widgets/user_post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  static const String routePath = "/profile";

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  PostProvider? provider;
  bool isInit = true;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      provider = Provider.of<PostProvider>(context, listen: true);
      provider!.setUserPosts("userid").then((_) {
        setState(() {
          isLoading = false;
        });
      });

      isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isLoading ? const SizedBox() : Text("Mansi Great"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? CommonWidget.getLoader()
          : DefaultTabController(
              length: postCategoryList.length,
              child: Column(
                children: <Widget>[
                  // User profile section
                  UserProfileSection(),

                  // TabBar for the three sections
                  TabBar(
                    tabs: postCategoryList
                        .map((title) => Tab(text: title.displayName))
                        .toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: postCategoryList.map((title) {
                        return buildTabContent(title);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTabContent(PostCategory tabTitle) {
    List<UserBook> books = provider!.profilePosts![tabTitle] ?? [];

    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: kIsWeb ? 4 : 3, // 3 items per row
          childAspectRatio:
              4 / 5, // Aspect ratio for each tile (height > width)
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final userBook = books[index];
          return UserPost(
            userBook: userBook,
          );
        });
  }
}

class UserProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0.r),
      child: Column(
        children: [
          // Profile picture and details
          Row(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 60.r,
                backgroundImage: AssetImage(
                    'assets/profile.jpg'), // Add profile image path here
              ),
              SizedBox(width: 16.w),

              // Name and bio
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mansi Great',
                    style:
                        TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Book lover and avid reader!',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
