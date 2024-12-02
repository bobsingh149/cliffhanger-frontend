import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/models/user.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barter_frontend/utils/common_utils.dart';

enum SortOption {
    time,
    match,
  }
  
class BookBuddiesScreen extends StatefulWidget {
  static const String routePath = '/book-buddies';

  const BookBuddiesScreen({super.key});

  @override
  State<BookBuddiesScreen> createState() => _BookBuddiesScreenState();
}

class _BookBuddiesScreenState extends State<BookBuddiesScreen> {
  static const String _sortPreferenceKey = 'book_buddies_sort_option';
  SortOption _currentSort = SortOption.time;

  @override
  void initState() {
    super.initState();
    _loadSortPreference();
  }

  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSort = prefs.getString(_sortPreferenceKey);
    if (savedSort != null) {
      setState(() {
        _currentSort = SortOption.values.firstWhere(
          (e) => e.toString() == savedSort,
          orElse: () => SortOption.time,
        );
      });
    }
  }

  Future<void> _saveSortPreference(SortOption option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortPreferenceKey, option.toString());
  }

  Color _getScoreColor(BuildContext context, int score) {
    final theme = Theme.of(context);
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd\'th\' MMM, yyyy').format(date);
  }

  Widget _buildSortedByMatchList(List<BookBuddy> buddies, ThemeData theme) {
    Widget buddiesList = RefreshIndicator(
      onRefresh: () async {
        await Provider.of<UserProvider>(context, listen: false)
            .getBookBuddies(forceRefresh: true);
      },
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: 12.h,
          left: kIsWeb ? 16.w : 0.w,
          right: kIsWeb ? 16.w : 0.w,
        ),
        itemCount: buddies.length,
        itemBuilder: (context, index) {
          final buddy = buddies[index];

          return Card(
            margin: EdgeInsets.symmetric(
              vertical: 3.h,
              horizontal: 0.w,
            ),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                      child: ClipOval(
                        child: buddy.userInfo.profileImage != null
                            ? CachedNetworkImage(
                                imageUrl: buddy.userInfo.profileImage!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(
                                        strokeWidth: 2),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person, size: 25),
                              )
                            : const Icon(Icons.person, size: 25),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buddy.userInfo.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          buddy.userInfo.bio ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getScoreColor(context, buddy.commonSubjectCount)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: _getScoreColor(context, buddy.commonSubjectCount),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${buddy.commonSubjectCount}% Book Match',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _getScoreColor(context, buddy.commonSubjectCount),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                            Icons.person_add_rounded,
                            size: 24),
                        color: theme.colorScheme.primary.withOpacity(0.8),
                        tooltip: 'Connect',
                        onPressed: () {
                          // TODO: Implement connect functionality
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                            Icons.person_remove_rounded,
                            size: 24),
                        color: theme.colorScheme.error.withOpacity(0.8),
                        tooltip: 'Remove',
                        onPressed: () {
                          // TODO: Implement remove functionality
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (kIsWeb) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 800.w),
          child: buddiesList,
        ),
      );
    }

    return buddiesList;
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider _userProvider =
        Provider.of<UserProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
        automaticallyImplyLeading: false,
        title: Text(
          'Your Book Buddies',
        ),
        actions: [
          PopupMenuButton<SortOption>(
            icon: Icon(Icons.sort),
            onSelected: (SortOption option) {
              setState(() {
                _currentSort = option;
              });
              _saveSortPreference(option);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: SortOption.time,
                child: Row(
                  children: [
                    Icon(Icons.access_time,
                        color: _currentSort == SortOption.time
                            ? theme.colorScheme.primary
                            : null),
                    SizedBox(width: 8.w),
                    Text('Sort by Time'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.match,
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: _currentSort == SortOption.match
                            ? theme.colorScheme.primary
                            : null),
                    SizedBox(width: 8.w),
                    Text('Sort by Match'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<BookBuddy>>(
          future: _userProvider.getBookBuddies(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CommonWidget.getLoader());
            }

            if (snapshot.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                CommonUtils.displaySnackbar(
                  context: context,
                  message: 'Could not load book buddies',
                  mode: SnackbarMode.error,
                );
              });
              return const SizedBox.shrink();
            }

            final bookBuddies = snapshot.data ?? [];

            if (bookBuddies.isEmpty) {
              return Center(
                child: Text(
                  'You have no book buddies yet',
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            if (_currentSort == SortOption.match) {
              bookBuddies.sort((a, b) => b.commonSubjectCount.compareTo(a.commonSubjectCount));
              
              return _buildSortedByMatchList(bookBuddies, theme);
            }

            final groupedBuddies = <DateTime, List<BookBuddy>>{};
            for (var buddy in bookBuddies) {
              final date = DateTime(
                buddy.requestTime.year,
                buddy.requestTime.month,
                buddy.requestTime.day,
              );
              groupedBuddies.putIfAbsent(date, () => []).add(buddy);
            }

            final sortedDates = groupedBuddies.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            Widget buddiesList = RefreshIndicator(
              onRefresh: () async {
                await _userProvider.getBookBuddies(forceRefresh: true);
              },
              child: ListView.builder(
                padding: EdgeInsets.only(
                  top: 12.h,
                  left: kIsWeb ? 16.w : 0.w,
                  right: kIsWeb ? 16.w : 0.w,
                ),
                itemCount: sortedDates.length,
                itemBuilder: (context, dateIndex) {
                  final date = sortedDates[dateIndex];
                  final buddiesForDate = groupedBuddies[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Text(
                          _formatDate(date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                      ...buddiesForDate
                          .map((buddy) => Card(
                                margin: EdgeInsets.symmetric(
                                  vertical: 3.h,
                                  horizontal: 0.w,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: theme.colorScheme.outline
                                        .withOpacity(0.1),
                                    width: theme.brightness == Brightness.dark ? 1.0 : 0.5,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  child: Row(
                                    children: [
                                      // Profile Image
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: theme
                                              .colorScheme.secondary
                                              .withOpacity(0.2),
                                          child: ClipOval(
                                            child: buddy.userInfo.profileImage !=
                                                    null
                                                ? CachedNetworkImage(
                                                    imageUrl: buddy
                                                        .userInfo.profileImage!,
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) =>
                                                        const CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.person,
                                                            size: 25),
                                                  )
                                                : const Icon(Icons.person,
                                                    size: 25),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16.w),

                                      // User Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              buddy.userInfo.name,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              buddy.userInfo.bio ?? '',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4.h),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8.w,
                                                vertical: 2.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getScoreColor(context, buddy.commonSubjectCount)
                                                    .withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.auto_awesome,
                                                    size: 14,
                                                    color: _getScoreColor(context, buddy.commonSubjectCount),
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    '${buddy.commonSubjectCount}% Book Match',
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: _getScoreColor(context, buddy.commonSubjectCount),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Action Buttons
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.person_add_rounded,
                                                size: 24),
                                            color: theme.colorScheme.primary
                                                .withOpacity(0.8),
                                            tooltip: 'Connect',
                                            onPressed: () {
                                              // TODO: Implement connect functionality
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.person_remove_rounded,
                                                size: 24),
                                            color: theme.colorScheme.error
                                                .withOpacity(0.8),
                                            tooltip: 'Remove',
                                            onPressed: () {
                                              // TODO: Implement remove functionality
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ],
                  );
                },
              ),
            );

            if (kIsWeb) {
              return Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 800.w),
                  child: buddiesList,
                ),
              );
            }

            return buddiesList;
          },
        ),
      ),
    );
  }
}
