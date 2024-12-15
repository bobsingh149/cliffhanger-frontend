import 'package:barter_frontend/main.dart';
import 'package:barter_frontend/models/post.dart';
import 'package:barter_frontend/models/post_category.dart';
import 'package:barter_frontend/models/save_request_input.dart';
import 'package:barter_frontend/models/user.dart';
import 'package:barter_frontend/provider/post_provider.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/screens/edit_profile.dart';
import 'package:barter_frontend/screens/home_page.dart';
import 'package:barter_frontend/screens/sign_in_page.dart';
import 'package:barter_frontend/screens/connection_requests_page.dart';
import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:barter_frontend/widgets/user_post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  static const String routePath = "/profile";
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  PostProvider? provider;
  late Future<Map<PostCategory, List<PostModel>>?> _userPostsFuture;
  late Future<UserModel?> _userFuture;
  bool isInit = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      provider = Provider.of<PostProvider>(context, listen: false);
      _userPostsFuture = provider!.getUserPosts(widget.userId);
      _userFuture = Provider.of<UserProvider>(context, listen: false).fetchUser(widget.userId);
      isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          
          backgroundColor: theme.colorScheme.background,
          title: Text(
            widget.userId == AuthService.getInstance.currentUser!.uid 
              ? "My Library"
              : "User's Library",
            
          ),
          actions: [
            if (widget.userId == AuthService.getInstance.currentUser!.uid) ...[
              if (!kIsWeb) IconButton(
                icon: Icon(Icons.person_add),
                onPressed: () {
                  Navigator.pushNamed(context, ConnectionRequestsPage.routePath);
                },
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.settings),
                onSelected: (value) {
                  if (value == 'edit_profile') {
                    Navigator.pushNamed(context, EditProfilePage.routePath);
                  } else if (value == 'logout') {
                    Provider.of<UserProvider>(context, listen: false).clearUserSetup();
                    AuthService.getInstance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      SignInPage.routePath,
                      (route) => false,
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit_profile',
                    child: Text('Edit Profile'),
                  ),
                  PopupMenuItem<String>(
                    
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dark Mode'),
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) => Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (_) {
                              themeProvider.setThemeMode(
                                themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
              ),
            ] else ...[
              IconButton(
                icon: Icon(Icons.person_add),
                onPressed: () async {
                  try {
                    final currentUserId = AuthService.getInstance.currentUser!.uid;
                    final requestInput = SaveRequestInput(
                      id: currentUserId,
                      requestId: widget.userId,
                    );
                    
                    await Provider.of<UserProvider>(context, listen: false)
                        .saveRequest(requestInput);
                    
                    CommonUtils.displaySnackbar(
                      context: context,
                      message: 'Connection request sent successfully!',
                      mode: SnackbarMode.success,
                    );
                  } catch (e) {
                    CommonUtils.displaySnackbar(
                      context: context,
                      message: 'Failed to send connection request: $e',
                      mode: SnackbarMode.error,
                    );
                  }
                },
              ),
            ],
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _userPostsFuture = provider!.getUserPosts(widget.userId);
              _userFuture = Provider.of<UserProvider>(context, listen: false).fetchUser(widget.userId);
            });
          },
          child: FutureBuilder<List<dynamic>>(
            future: Future.wait([_userPostsFuture, _userFuture]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CommonWidget.getLoader();
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error loading data'));
              }

              final posts = snapshot.data![0] as Map<PostCategory, List<PostModel>>?;
              final user = snapshot.data![1] as UserModel?;

              if (user == null) {
                return Center(child: Text('User not found'));
              }

              final postsCount = posts?.values.expand((posts) => posts).length ?? 0;
              final bartersCount = posts?[PostCategory.barter]?.length ?? 0;

              return DefaultTabController(
                length: postCategoryList.length,
                child: NestedScrollView(
                  headerSliverBuilder: (context, _) => [
                    SliverToBoxAdapter(
                      child: UserProfileSection(
                        user: user,
                        postsCount: postsCount,
                        bartersCount: bartersCount,
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          tabs: postCategoryList
                              .map((title) => Tab(text: title.displayName))
                              .toList(),
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor:
                              theme.colorScheme.onSurface.withOpacity(0.6),
                          indicatorColor: theme.colorScheme.primary,
                        ),
                      ),
                      pinned: true,
                    ),
                  ],
                  body: TabBarView(
                    children: postCategoryList
                        .map((title) => buildTabContent(title))
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildTabContent(PostCategory tabTitle) {
    List<PostModel> books = provider!.profilePosts![tabTitle] ?? [];

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: kIsWeb ? 16.w : 3.w,
        vertical: kIsWeb ? 16.h : 6.h
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: kIsWeb ? 4 : 2,
        childAspectRatio: kIsWeb ? (2 / 3) : (2 / 3),
        mainAxisSpacing: kIsWeb ? 16.h : 12.h,
        crossAxisSpacing: kIsWeb ? 16.w : 12.w,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => UserPost(userBook: books[index]),
    );
  }
}

class UserProfileSection extends StatelessWidget {
  final UserModel user;
  final int postsCount;
  final int bartersCount;

  const UserProfileSection({
    required this.user,
    required this.postsCount,
    required this.bartersCount,
  });

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
                    imageUrl: user.profileImage ?? '',
                    placeholder: (context, url) => Container(
                      color: theme.colorScheme.surface,
                    ),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.person, size: 50),
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
                      user.name,
                      style: theme.textTheme.headlineMedium,
                    ),
                    if (user.age != null || user.city?.isNotEmpty == true)
                      Text(
                        [
                          if (user.age != null) '${user.age} years',
                          if (user.city?.isNotEmpty == true) user.city,
                        ].join('  '),
                        style: theme.textTheme.bodySmall,
                      ),
                    SizedBox(height: 4.h),
                    if (user.bio?.isNotEmpty == true)
                      Text(
                        user.bio!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    SizedBox(height: 5.h),
                    TextButton(
                      onPressed: () {
                        // Add navigation or action here
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Browse all posts',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                        ),
                      ),
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
              _buildStatColumn('Posts', postsCount.toString()),
              _buildStatColumn('Book Buddies', user.bookBuddyCount.toString()),
              _buildStatColumn('Barters', bartersCount.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
