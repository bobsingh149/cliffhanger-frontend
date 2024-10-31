
import 'package:barter_frontend/screens/profile.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:barter_frontend/models/book.dart';
import 'package:flutter/foundation.dart';

import 'package:barter_frontend/widgets/search_bar.dart';
import 'package:barter_frontend/provider/book_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Add this import
import 'package:barter_frontend/widgets/post_card.dart'; // Add this import
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:barter_frontend/provider/post_provider.dart';

class HomePage extends StatefulWidget {
  static const String routePath = "/myfeed";
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _onlyBarter = false;
  bool _showSearchBar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Custom AppBar content
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          'Mansi\'s Feed',
                          style: Theme.of(context).textTheme.titleLarge
                        ),
                        SizedBox(width: 16.w),
                        // Updated search bar / icon widget
                        _showSearchBar
                            ? Container(
                                width: 500.w,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SearchableDropdown(
                                        isHomePage: true,
                                        provider: Provider.of<BookProvider>(context, listen: false),
                                        onItemSelected: (Book selectedBook) {
                                          print('Selected book: ${selectedBook.title}');
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _showSearchBar = false;
                                        });
                                      },
                                      child: Icon(Icons.chevron_left, size: 24.r),
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
                                child: FaIcon(FontAwesomeIcons.search, size: 20.r),
                              ),
                      ],
                    ),
                  ),
                ),
                // Move Barter switch here
                Row(
                  children: [
                    Text('Barter', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
                    Switch(
                      value: _onlyBarter,
                      onChanged: (value) {
                        setState(() {
                          _onlyBarter = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(width: 1.w),
                ElevatedButton.icon(
                  icon: FaIcon(FontAwesomeIcons.userGroup, color: AppTheme.primaryColor, size: 16.r),
                  label: Text('Get Book Buddy', style: TextStyle(color: AppTheme.primaryColor)),
                  onPressed: () {
                    // TODO: Implement Find Book Buddy functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
                SizedBox(width: 17.w),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(ProfilePage.routePath);
                  },
                  child: CircleAvatar(
                    radius: 20.r,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: 'https://res.cloudinary.com/dllr1e6gn/image/upload/v1/profile_images/aemio6hooqxp1eiqzpev',
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.person),
                        fit: BoxFit.cover,
                        width: 40.r,
                        height: 40.r,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          
          // Use ListView for web, CardSwiper for other platforms
          Expanded(
            child: FutureBuilder<List<UserBook>>(
              future: Provider.of<PostProvider>(context, listen: false).getFeedPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CommonWidget.getLoader();
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading posts'));
                }

                final posts = snapshot.data ?? [];
                
                return kIsWeb
                    ? ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return PostCard(post: posts[index]);
                        },
                      )
                    : CardSwiper(
                        cardsCount: posts.length,
                        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                          return PostCard(post: posts[index]);
                        },
                        onSwipe: (previousIndex, currentIndex, direction) => 
                          _onSwipe(previousIndex, currentIndex, direction, posts),
                        backCardOffset: Offset(0.w, 0.h),
                        isLoop: true,
                        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
                        duration: const Duration(milliseconds: 150),
                        threshold: 5,
                        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
                          horizontal: true, 
                          vertical: false
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction, List<UserBook> posts) {
    if (direction == CardSwiperDirection.bottom) {
      print('Liked post: ${posts[previousIndex].title}');
    } else if (direction == CardSwiperDirection.top) {
      print('Disliked post: ${posts[previousIndex].title}');
    }
    return true;
  }
}
