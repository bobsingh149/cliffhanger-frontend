import 'package:barter_frontend/models/user.dart';
import 'package:barter_frontend/models/user_setup.dart';
import 'package:barter_frontend/screens/connection_requests_page.dart';
import 'package:barter_frontend/screens/contacts_screen.dart';
import 'package:barter_frontend/screens/post_book.dart';
import 'package:barter_frontend/screens/profile.dart';
import 'package:barter_frontend/screens/book_buddies_screen.dart';
import 'package:barter_frontend/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:barter_frontend/main.dart'; // For ThemeProvider
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:barter_frontend/screens/link_screen.dart';

class MainScreen extends StatefulWidget {
  static const routePath = 'home';
  MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<bool> _loadedPages = List.generate(7, (index) => index == 0);

  // Modify the web widget options to include LinksPage
  List<Widget> get _webWidgetOptions => [
    _loadedPages[0] ?  KeepAlivePage(child: HomePage()) : Container(),
    _loadedPages[1] ?  const KeepAlivePage(child: PostBookPage()) : Container(),
    _loadedPages[2] ?  ContactsScreen() : Container(),
    _loadedPages[3] ?  BookBuddiesScreen() : Container(),
    _loadedPages[4] ?  ConnectionRequestsPage() : Container(),
    _loadedPages[5] ? ProfilePage(userId: AuthService.getInstance.currentUser!.uid) : Container(),
    _loadedPages[6] ? const LinksPage() : Container(),
  ];

  // Update _mobileWidgetOptions to be a getter with lazy loading
  List<Widget> get _mobileWidgetOptions => [
    _loadedPages[0] ?  KeepAlivePage(child: HomePage()) : Container(),
    _loadedPages[1] ?  const KeepAlivePage(child: PostBookPage()) : Container(),
    _loadedPages[2] ?  ContactsScreen() : Container(),
    _loadedPages[3] ?  BookBuddiesScreen() : Container(),
    _loadedPages[4] ? ProfilePage(userId: AuthService.getInstance.currentUser!.uid) : Container(),
  ];

  // Update web navigation items to include Get App
  final List<NavigationItem> _webNavigationItems = [
    NavigationItem(
      icon: FontAwesomeIcons.house,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.add_box_sharp,
      label: 'Post Book',
    ),
    NavigationItem(
      icon: FontAwesomeIcons.comments,
      label: 'Contacts',
    ),
    NavigationItem(
      icon: FontAwesomeIcons.userGroup,
      label: 'Book Buddies',
    ),
    NavigationItem(
      icon: FontAwesomeIcons.userPlus,
      label: 'Connection Requests',
    ),
    NavigationItem(
      icon: FontAwesomeIcons.download,
      label: 'Get App',
    ),
  ];

  // Mobile navigation items (reordered for mobile UX)
  final List<NavigationItem> _mobileNavigationItems = [
    NavigationItem(
      icon: FontAwesomeIcons.house,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.add_box_sharp,
      label: 'Post Book',
    ),
    NavigationItem(
      icon: FontAwesomeIcons.comments,
      label: 'Messages',
    ),
    NavigationItem(
      icon: FontAwesomeIcons.userGroup,
      label: 'Book Buddies',
    ),
    NavigationItem(
      icon: Icons.person,
      label: 'Profile',
      isProfile: true,
      profileImageUrl:
          'https://res.cloudinary.com/dllr1e6gn/image/upload/v1/profile_images/aemio6hooqxp1eiqzpev',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _loadedPages[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context,listen: true);

    if (kIsWeb) {
      return Scaffold(
        body: Row(
          children: [
            WebSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
              navigationItems: _webNavigationItems,
              userProvider: userProvider,
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
            Expanded(
              child: SafeArea(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _webWidgetOptions,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout remains the same
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _mobileWidgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _mobileNavigationItems
            .map((item) => BottomNavigationBarItem(
                  icon: item.isProfile
                      ? CircleAvatar(
                          radius: 12,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: item.profileImageUrl!,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(item.icon, size: 17),
                              fit: BoxFit.cover,
                              width: 24,
                              height: 24,
                            ),
                          ),
                        )
                      : FaIcon(item.icon, size: 20),
                  label: '',
                ))
            .toList(),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}

// Add these new classes
class NavigationItem {
  final IconData icon;
  final String label;
  final bool isProfile;
  final String? profileImageUrl;

  const NavigationItem({
    required this.icon,
    required this.label,
    this.isProfile = false,
    this.profileImageUrl,
  });
}

class WebSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<NavigationItem> navigationItems;
  final UserProvider userProvider;

  const WebSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.navigationItems,
    required this.userProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 230.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black12
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 25.h),
          // Profile Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FutureBuilder<UserSetupModel>(
              future: userProvider.getUserSetup(AuthService.getInstance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      CommonWidget.getLoader(),
                      const SizedBox(height: 20),
                      Text('Loading...', style: theme.textTheme.bodyMedium),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return Column(
                    children: [
                      Icon(Icons.error, color: theme.colorScheme.error),
                      const SizedBox(height: 8),
                      Text('Error loading profile',
                          style: theme.textTheme.bodyMedium),
                    ],
                  );
                }

                final user = snapshot.data;
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => onItemSelected(5),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.1),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user?.profileImage ?? '',
                              placeholder: (context, url) =>
                                  CommonWidget.getLoader(),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 45,
                                color: theme.colorScheme.primary,
                              ),
                              fit: BoxFit.cover,
                              width: 90,
                              height: 90,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome back,',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.name ?? 'User',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 25.h),
          // Navigation Items
          Expanded(
            child: ListView.builder(
              itemCount: navigationItems.length,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemBuilder: (context, index) {
                final item = navigationItems[index];
                final isSelected = selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: item.isProfile
                        ? Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 14,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: item.profileImageUrl!,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(item.icon, size: 20),
                                  fit: BoxFit.cover,
                                  width: 28,
                                  height: 28,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.05),
                            ),
                            child: FaIcon(
                              item.icon,
                              size: 20,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                            ),
                          ),
                    title: Text(
                      item.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.8),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    onTap: () => onItemSelected(index),
                  ),
                );
              },
            ),
          ),
          // Dark Mode Switch moved to bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Center(
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.onSurface.withOpacity(0.05),
                  ),
                  child: PopupMenuButton<ThemeMode>(
                    padding: EdgeInsets.zero,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        themeProvider.themeMode == ThemeMode.light
                            ? Icons.light_mode
                            : themeProvider.themeMode == ThemeMode.dark
                                ? Icons.dark_mode
                                : Icons.settings_brightness,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    onSelected: (ThemeMode mode) {
                      themeProvider.setThemeMode(mode);
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<ThemeMode>>[
                      PopupMenuItem<ThemeMode>(
                        value: ThemeMode.light,
                        child: Row(
                          children: [
                            Icon(Icons.light_mode,
                                color:
                                    themeProvider.themeMode == ThemeMode.light
                                        ? theme.colorScheme.primary
                                        : null),
                            const SizedBox(width: 8),
                            Text('Light'),
                          ],
                        ),
                      ),
                      PopupMenuItem<ThemeMode>(
                        value: ThemeMode.dark,
                        child: Row(
                          children: [
                            Icon(Icons.dark_mode,
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? theme.colorScheme.primary
                                    : null),
                            const SizedBox(width: 8),
                            Text('Dark'),
                          ],
                        ),
                      ),
                      PopupMenuItem<ThemeMode>(
                        value: ThemeMode.system,
                        child: Row(
                          children: [
                            Icon(Icons.settings_brightness,
                                color:
                                    themeProvider.themeMode == ThemeMode.system
                                        ? theme.colorScheme.primary
                                        : null),
                            const SizedBox(width: 8),
                            Text('System'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add this new widget to handle keep alive functionality
class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
