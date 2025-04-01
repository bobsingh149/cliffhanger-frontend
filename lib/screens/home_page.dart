import 'package:barter_frontend/exceptions/user_exceptions.dart';
import 'package:barter_frontend/models/save_request_input.dart';
import 'package:barter_frontend/models/user.dart';
import 'package:barter_frontend/models/user_setup.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/screens/user_onboarding.dart';
import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:barter_frontend/models/post.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_swipe_tutorial/flutter_swipe_tutorial.dart';
import 'dart:math' as math;

import 'package:barter_frontend/provider/book_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Add this import
import 'package:barter_frontend/widgets/post_card.dart'; // Add this import
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:barter_frontend/provider/post_provider.dart';
import 'package:barter_frontend/screens/connection_requests_page.dart';

// Add this new widget at the top of the file, outside the HomePage class
class WebSearchBar extends StatefulWidget {
  final BookProvider provider;
  final Function(String) onSearch;
  final TextEditingController? searchController;

  const WebSearchBar({
    required this.provider,
    required this.onSearch,
    this.searchController,
    super.key,
  });

  @override
  State<WebSearchBar> createState() => _WebSearchBarState();
}

class _WebSearchBarState extends State<WebSearchBar> {
  bool _showSearchBar = false;

  @override
  Widget build(BuildContext context) {
    return _showSearchBar
        ? SizedBox(
            width: 500.w,
            child: Row(
              children: [
                Expanded(
                  child: SearchTextField(
                    onSearch: widget.onSearch,
                    controller: widget.searchController,
                  ),
                ),
                SizedBox(width: 8.w),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showSearchBar = false;
                    });
                  },
                  child: const Icon(Icons.chevron_left, size: 24),
                ),
              ],
            ),
          )
        : InkWell(
            onTap: () {
              setState(() {
                _showSearchBar = true;
              });
            },
            child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 20),
          );
  }
}

// WebAppBarContent widget
class WebAppBarContent extends StatefulWidget {
  final bool onlyBarter;
  final Function(bool) onBarterChanged;
  final Future<void> Function(BuildContext, UserProvider) onBookBuddyPressed;
  final UserProvider userProvider;
  final Function(String) onSearch;
  final FilterType filterType;
  final String? userName;
  final TextEditingController? searchController;

  const WebAppBarContent({
    required this.onlyBarter,
    required this.onBarterChanged,
    required this.onBookBuddyPressed,
    required this.userProvider,
    required this.onSearch,
    required this.filterType,
    this.userName,
    this.searchController,
    super.key,
  });

  @override
  State<WebAppBarContent> createState() => _WebAppBarContentState();
}

class _WebAppBarContentState extends State<WebAppBarContent> {
  @override
  Widget build(BuildContext context) {
    if (widget.filterType == FilterType.userPosts) {
      return Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text(
              "${widget.userName}'s Posts",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    'My Feed',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(width: 16.w),
                  WebSearchBar(
                      provider:
                          Provider.of<BookProvider>(context, listen: false),
                      onSearch: widget.onSearch,
                      searchController: widget.searchController),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Text('Barter',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
              Switch(
                value: widget.onlyBarter,
                onChanged: widget.onBarterChanged,
              ),
            ],
          ),
          SizedBox(width: 6.w),
          BookBuddyButton(
            onBookBuddyPressed: widget.onBookBuddyPressed,
            userProvider: widget.userProvider,
          ),
        ],
      ),
    );
  }
}

// MobileAppBarContent widget
class MobileAppBarContent extends StatefulWidget {
  final bool onlyBarter;
  final Function(bool) onBarterChanged;
  final Future<void> Function(BuildContext, UserProvider) onBookBuddyPressed;
  final UserProvider userProvider;
  final Function(String) onSearch;
  final FilterType filterType;
  final String? userName;
  final TextEditingController? searchController;

  const MobileAppBarContent({
    required this.onlyBarter,
    required this.onBarterChanged,
    required this.onBookBuddyPressed,
    required this.userProvider,
    required this.onSearch,
    required this.filterType,
    this.userName,
    this.searchController,
    super.key,
  });

  @override
  State<MobileAppBarContent> createState() => _MobileAppBarContentState();
}

class _MobileAppBarContentState extends State<MobileAppBarContent> {
  bool _showMobileSearchBar = false;

  @override
  Widget build(BuildContext context) {
    if (widget.filterType == FilterType.userPosts) {
      return Padding(
        padding: EdgeInsets.only(top: 25.h),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text(
              "${widget.userName}'s Posts",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text('My Feed',
                        style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(width: 16.w),
                    if (!_showMobileSearchBar)
                      InkWell(
                        onTap: () =>
                            setState(() => _showMobileSearchBar = true),
                        child:
                            FaIcon(FontAwesomeIcons.magnifyingGlass, size: 20),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.bell,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.textColorDark
                    : AppTheme.textColorLight,
                size: 25,
              ),
              onPressed: () {
                Navigator.pushNamed(context, ConnectionRequestsPage.routePath);
              },
            ),
            BookBuddyButton(
              onBookBuddyPressed: widget.onBookBuddyPressed,
              userProvider: widget.userProvider,
            ),
          ],
        ),
        if (_showMobileSearchBar)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 5.h),
            child: Row(
              children: [
                Expanded(
                  child: SearchTextField(
                    onSearch: widget.onSearch,
                    controller: widget.searchController,
                  ),
                ),
                Row(
                  children: [
                    SizedBox(width: 5.w),
                    Text('Barter',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontSize: 15)),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: widget.onlyBarter,
                        onChanged: widget.onBarterChanged,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => setState(() => _showMobileSearchBar = false),
                  child: Icon(Icons.keyboard_arrow_up, size: 24),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Add this new widget at the top of the file
class BookBuddyDialog extends StatelessWidget {
  final GetBookBuddy bookBuddy;

  const BookBuddyDialog({required this.bookBuddy, super.key});

  Color _getScoreColor(BuildContext context, int score) {
    if (score >= 30) return Colors.green;
    if (score >= 15) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      content: Container(
        width: 400.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: bookBuddy.profileImage ?? '',
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.person),
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              bookBuddy.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _getScoreColor(context, bookBuddy.commonSubjectCount)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color:
                        _getScoreColor(context, bookBuddy.commonSubjectCount),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${bookBuddy.commonSubjectCount}% Book Match',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          _getScoreColor(context, bookBuddy.commonSubjectCount),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              bookBuddy.bio ?? 'No bio available',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () async {
                try {
                  final currentUserId =
                      AuthService.getInstance.currentUser!.uid;
                  final requestInput = SaveRequestInput(
                    id: currentUserId,
                    requestId: bookBuddy.id,
                  );

                  await Provider.of<UserProvider>(context, listen: false)
                      .saveRequest(requestInput);

                  Navigator.pop(context);

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
              child: Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchTextField extends StatefulWidget {
  final Function(String) onSearch;
  final TextEditingController? controller;

  const SearchTextField({
    required this.onSearch,
    this.controller,
    super.key,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleSearch() {
    if (_controller.text.isNotEmpty) {
      // Dismiss keyboard
      FocusScope.of(context).unfocus();
      widget.onSearch(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search feed',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VerticalDivider(
                color: Colors.grey[400],
                thickness: 1,
                indent: 8,
                endIndent: 8,
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: _handleSearch,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.primaryColor),
          ),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _handleSearch();
          }
        },
      ),
    );
  }
}

class BookBuddyButton extends StatefulWidget {
  final Future<void> Function(BuildContext, UserProvider) onBookBuddyPressed;
  final UserProvider userProvider;

  const BookBuddyButton({
    required this.onBookBuddyPressed,
    required this.userProvider,
    super.key,
  });

  @override
  State<BookBuddyButton> createState() => _BookBuddyButtonState();
}

class _BookBuddyButtonState extends State<BookBuddyButton> {
  bool _isLoadingBuddy = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: _isLoadingBuddy
            ? null
            : () async {
                setState(() => _isLoadingBuddy = true);
                await widget.onBookBuddyPressed(context, widget.userProvider);
                setState(() => _isLoadingBuddy = false);
              },
        style: TextButton.styleFrom(
          padding: kIsWeb
              ? EdgeInsets.symmetric(horizontal: 12)
              : EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: AppTheme.primaryColor,
              width: 1.5,
            ),
          ),
          foregroundColor: AppTheme.primaryColor,
          textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
        ),
        child: _isLoadingBuddy
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Getting...'),
                ],
              )
            : Text(
                'Book Buddy',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                    ),
              ));
  }
}

class HomePage extends StatefulWidget {
  static const String routePath = "/myfeed";
  final FilterType filterType;
  final String? userIdPosts;
  final String? userName;

  HomePage(
      {super.key,
      this.filterType = FilterType.all,
      this.userIdPosts,
      this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PostModel> posts = [];
  bool _onlyBarter = false;
  FilterType? _filterType;

  late Future<List<PostModel>> _postsFuture;

  final ScrollController _scrollController =
      ScrollController(keepScrollOffset: true);
  bool _isLoadingMore = false;

  final int _pageSize = 10;

  int _pageKey = 0;

  bool _hasMoreItems = true;

  String _searchQuery = '';

  int cardIndex = 0;

  final TextEditingController _searchController = TextEditingController();

  final CardSwiperController _cardSwiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _filterType = widget.filterType;

    _postsFuture =
        Provider.of<PostProvider>(context, listen: false).getFeedPosts(
      filterType: _filterType!,
      userId: AuthService.getInstance.currentUser!.uid,
      page: _pageKey,
      size: _pageSize,
      userIdPosts: widget.userIdPosts,
    );

    // Add scroll controller listener
    _scrollController.addListener(() {
      if (kIsWeb &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 1 &&
          !_isLoadingMore) {
        _loadMorePosts();
      }
    });
  }

  var _isLoading = false;

  Future<bool> _getFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();

    bool _firstTimeUser = !prefs.containsKey('first_time_user');

    if (_firstTimeUser) {
      await prefs.setBool('first_time_user', true);
    }

    return _firstTimeUser;
  }

  void onBarterChanged(bool value) {
    setState(() {
      _onlyBarter = value;
      resetPagination();

      _filterType = value ? FilterType.barter : FilterType.all;
      final city = Provider.of<UserProvider>(context, listen: false).user?.city;
      _postsFuture = Provider.of<PostProvider>(context, listen: false)
          .getFeedPosts(
              filterType: _filterType!,
              userId: AuthService.getInstance.currentUser!.uid,
              city: city,
              page: _pageKey,
              size: _pageSize);
    });
  }

  void _handleSearch(String query) {
    query = query.trim();
    if (query.isEmpty) return;

    setState(() {
      _searchQuery = query;
      resetPagination();
      _filterType = FilterType.search;
      _postsFuture = Provider.of<PostProvider>(context, listen: false)
          .getFeedPosts(
              filterType: _filterType!,
              userId: AuthService.getInstance.currentUser!.uid,
              searchQuery: query,
              page: _pageKey,
              size: _pageSize);
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      resetPagination();
      _filterType = FilterType.all;
      _postsFuture = Provider.of<PostProvider>(context, listen: false)
          .getFeedPosts(
              filterType: _filterType!,
              userId: AuthService.getInstance.currentUser!.uid,
              page: _pageKey,
              size: _pageSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider _userProvider =
        Provider.of<UserProvider>(context, listen: false);

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Custom AppBar content
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            child: kIsWeb
                ? WebAppBarContent(
                    onlyBarter: _onlyBarter,
                    onBarterChanged: onBarterChanged,
                    onBookBuddyPressed: showBookBuddyDialog,
                    userProvider: _userProvider,
                    onSearch: _handleSearch,
                    filterType: _filterType!,
                    userName: widget.userName,
                    searchController: _searchController,
                  )
                : MobileAppBarContent(
                    onlyBarter: _onlyBarter,
                    onBarterChanged: onBarterChanged,
                    onBookBuddyPressed: showBookBuddyDialog,
                    userProvider: _userProvider,
                    onSearch: _handleSearch,
                    filterType: _filterType!,
                    userName: widget.userName,
                    searchController: _searchController,
                  ),
          ),

          if (_searchQuery.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 300.w : 10.w),
              child: Row(
                children: [
                  Text(
                    'Search results for: $_searchQuery',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Search'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),

          Divider(
            color: theme.colorScheme.onSurface.withOpacity(0.2),
            height: 1.0,
          ),

          SizedBox(height: 5.h),

          // Use ListView for web, CardSwiper for other platforms
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  resetPagination();

                  _filterType = FilterType.all;
                  _postsFuture =
                      Provider.of<PostProvider>(context, listen: false)
                          .getFeedPosts(
                              filterType: _filterType!,
                              userId: AuthService.getInstance.currentUser!.uid,
                              page: _pageKey,
                              size: _pageSize);
                });
              },
              child: FutureBuilder<dynamic>(
                future: Future.wait([_postsFuture, _getFirstTimeUser()]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CommonWidget.getLoader();
                  }

                  if (snapshot.hasError) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      CommonUtils.displaySnackbar(
                        context: context,
                        message: 'Could not connect to server',
                        mode: SnackbarMode.error,
                      );
                    });
                    return const Center(child: Text('Could not load posts'));
                  }

                  posts = snapshot.data?[0] ?? [];

                  if (posts.length < _pageSize) {
                    _hasMoreItems = false;
                  }

                  final firstTimeUser = snapshot.data?[1] ?? false;

                  if (posts.isEmpty) {
                    return const Center(child: Text('No posts available'));
                  }

                  return kIsWeb
                      ? ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            scrollbars: false,
                          ),
                          child: ListView.separated(
                            key: const PageStorageKey('feed-list'),
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    widget.userIdPosts != null ? 430.w : 300.w,
                                vertical: 5.h),
                            itemCount: posts.length + 1,
                            controller: _scrollController,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 7.h),
                            itemBuilder: (context, index) {
                              if (index == posts.length) {
                                return _isLoading
                                    ? const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      )
                                    : SizedBox.shrink();
                              }
                              return PostCard(
                                  key: ValueKey(posts[index].id),
                                  post: posts[index]);
                            },
                          ),
                        )
                      : posts.isEmpty
                          ? Center(child: Text('No posts available'))
                          : CardSwiper(
                              cardsCount: posts.length,
                              onEnd: () {
                                setState(() {
                                  cardIndex = 0;
                                });
                              },
                              cardBuilder: (context, index, percentThresholdX,
                                  percentThresholdY) {

                                if (index == posts.length - 1) {
                                  _loadMorePosts();
                                }

                                final post = posts[index];
                                return SwipeTutorial(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                  showTutorial: index == 0 && firstTimeUser,
                                  swipeDirection: SwipeDirection.rightToLeft,
                                  text: 'Swipe left to see next post',
                                  child: PostCard(
                                      key: ValueKey(post.id), post: post),
                                );
                              },
                              initialIndex: cardIndex,
                              onSwipe:
                                  (previousIndex, currentIndex, direction) =>
                                      _onSwipe(previousIndex, currentIndex,
                                          direction, posts),
                              numberOfCardsDisplayed: posts.length > 1 ? 2 : 1,
                              backCardOffset: const Offset(0, 0),
                              isLoop: false,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0.w, vertical: 0.h),
                              duration: const Duration(milliseconds: 200),
                              threshold: 30,
                              controller: _cardSwiperController,
                              allowedSwipeDirection:
                                  const AllowedSwipeDirection.symmetric(
                                      horizontal: true, vertical: false),
                            );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _onSwipe(int previousIndex, int? currentIndex,
      CardSwiperDirection direction, List<PostModel> posts) {
  
    if (direction == CardSwiperDirection.left) {
      return true;
    }

    if(direction == CardSwiperDirection.right){
      _cardSwiperController.moveTo(math.max(0, previousIndex-1));
    }

    return false;
  }

  Future<void> showBookBuddyDialog(
      BuildContext context, UserProvider userProvider) async {
    final GetBookBuddy? bookBuddy = await userProvider.getBookBuddy();

    AppLogger.instance.i('bookBuddy: ${bookBuddy?.name}');

    if (bookBuddy == null) {
      if (context.mounted) {
        showGeneralDialog(
          context: context,
          pageBuilder: (_, __, ___) => Container(),
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
              ),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                content: Container(
                  width: kIsWeb ? 400.w : double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: kIsWeb ? 400.w : 300.w,
                    maxHeight: kIsWeb ? 200.h : 150.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sentiment_dissatisfied,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Sorry! No Book Buddy Found',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Please try again tomorrow!',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      }
      return;
    }

    if (context.mounted) {
      showGeneralDialog(
        context: context,
        pageBuilder: (_, __, ___) => Container(),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            ),
            child: BookBuddyDialog(bookBuddy: bookBuddy),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
    }
    return null;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMoreItems || _filterType == FilterType.userPosts)
      return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        cardIndex = math.max(0, posts.length - 2);
        _isLoading = true;
      });
    });

    try {
      _pageKey++;
      final city = Provider.of<UserProvider>(context, listen: false).user?.city;
      final newPosts =
          await Provider.of<PostProvider>(context, listen: false).getFeedPosts(
        filterType: _filterType!,
        userId: AuthService.getInstance.currentUser!.uid,
        page: _pageKey,
        size: _pageSize,
        city: city,
        searchQuery: _searchQuery,
        userIdPosts: widget.userIdPosts,
      );

      AppLogger.instance.i('newPosts: ${newPosts.length}');

      if (newPosts.length < _pageSize) {
        _hasMoreItems = false;
      }

      if (newPosts.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _isLoading = false;
          });
        });
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          posts.addAll(newPosts);
          _isLoading = false;
        });
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isLoading = false;
        });
      });
      if (context.mounted) {
        CommonUtils.displaySnackbar(
          context: context,
          message: 'Error loading more posts',
          mode: SnackbarMode.error,
        );
      }
    }
  }

  void resetPagination() {
    _pageKey = 0;
    _hasMoreItems = true;
    cardIndex = 0;
    posts.clear();
  }
}


/**
 * User Posts
 * User Info
 * set both of them on init
 */