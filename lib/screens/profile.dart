import 'package:barter_frontend/models/book.dart';
import 'package:barter_frontend/models/book_category.dart';
import 'package:barter_frontend/provider/post_provider.dart';
import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:barter_frontend/widgets/user_post.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  late Future<Map<PostCategory, List<UserBook>>?> _userPostsFuture;
  bool isInit = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(isInit){
      provider = Provider.of<PostProvider>(context, listen: false);
      String userId = AuthService.getInstance.currentUser!.uid;
      _userPostsFuture = provider!.getUserPosts(userId);    
      isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Mansi Great"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit_profile') {
                // Add edit profile functionality
              } else if (value == 'logout') {
                // Add logout functionality
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit_profile',
                child: Text('Edit Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Map<PostCategory, List<UserBook>>?>(
        future: _userPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CommonWidget.getLoader();
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error loading posts'));
          }

          return DefaultTabController(
            length: postCategoryList.length,
            child: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(child: UserProfileSection()),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      tabs: postCategoryList
                          .map((title) => Tab(text: title.displayName))
                          .toList(),
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                      indicatorColor: theme.colorScheme.primary,
                    ),
                  ),
                  pinned: true,
                ),
              ],
              body: TabBarView(
                children: postCategoryList.map((title) => buildTabContent(title)).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTabContent(PostCategory tabTitle) {
    List<UserBook> books = provider!.profilePosts![tabTitle] ?? [];

    return GridView.builder(
      padding: EdgeInsets.all(16.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: kIsWeb ? 4 : 3,
        childAspectRatio: 2 / 3,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => UserPost(userBook: books[index]),
    );
  }
}

class UserProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'https://res.cloudinary.com/dllr1e6gn/image/upload/v1/profile_images/aemio6hooqxp1eiqzpev', // Replace with actual URL
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.person, size: 50.r),
                    fit: BoxFit.cover,
                    width: 100.r,
                    height: 100.r,
                  ),
                ),
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mansi Great',
                      style: theme.textTheme.headlineMedium,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Book lover and avid reader!',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Posts', '120'),
              _buildStatColumn('Book Buddies', '1.2k'),
              _buildStatColumn('Barters', '350'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
