import 'package:barter_frontend/screens/book_buddies_screen.dart';
import 'package:barter_frontend/screens/connection_requests_page.dart';
import 'package:barter_frontend/provider/auth_provider.dart';
import 'package:barter_frontend/provider/book_provider.dart';
import 'package:barter_frontend/provider/chat_provider.dart';
import 'package:barter_frontend/provider/post_provider.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/screens/edit_profile.dart';
import 'package:barter_frontend/screens/home_page.dart';
import 'package:barter_frontend/screens/main_screen.dart';
import 'package:barter_frontend/screens/post_book.dart';
import 'package:barter_frontend/screens/sign_in_page.dart';
import 'package:barter_frontend/screens/user_onboarding.dart';
import 'package:barter_frontend/screens/profile.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:barter_frontend/screens/contacts_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:barter_frontend/screens/create_group_screen.dart';
import 'package:barter_frontend/screens/link_screen.dart';
import 'package:barter_frontend/screens/introduction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> initializeTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeProvider = ThemeProvider();
  await themeProvider.initializeTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticateProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const BarterApp(),
    ),
  );
}

class BarterApp extends StatelessWidget {
  const BarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: kIsWeb ? const Size(1217, 674) : const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Cliffhanger',
                theme: AppTheme.getAppropriateLightTheme(),
                darkTheme: AppTheme.getAppropriateDarkTheme(),
                themeMode: themeProvider.themeMode,
                initialRoute: '/',
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (context) => AuthCheck(
                      targetRoute: settings.name ?? '/',
                      arguments: settings.arguments,
                    ),
                  );
                },
              );
            },
          );
        });
  }
}

class AuthCheck extends StatefulWidget {
  static const String routePath = "/";
  final String targetRoute;
  final Object? arguments;

  const AuthCheck({
    super.key,
    this.targetRoute = '/',
    this.arguments,
  });

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {

  bool init=true;
  @override
  void initState() {
    super.initState();
    // Remove theme initialization from here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize theme here instead

    if(init){
      Provider.of<ThemeProvider>(context, listen: false).initializeTheme();
      init=false;
    }
  }

  Future<bool> _checkNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    bool isNewUser = !prefs.containsKey("introduction_done");
    if (isNewUser) {
      await prefs.setBool('introduction_done', true);
    }
    return isNewUser;
  }

  Widget _getTargetRoute() {
    // First, check if the route is public
    if (widget.targetRoute == LinksPage.routePath) {
      return const LinksPage();
    }

    // Then handle authenticated routes
    switch (widget.targetRoute) {
      case AppIntroductionScreen.routePath:
        return const AppIntroductionScreen();
      case MainScreen.routePath:
        return MainScreen(fromPage: NavigationPage.mainScreen);
      case HomePage.routePath:
        return HomePage();
      case BookBuddiesScreen.routePath:
        return BookBuddiesScreen();
      case OnboardingPage.routePath:
        return OnboardingPage();
      case SignInPage.routePath:
        return SignInPage();
      case PostBookPage.routePath:
        return PostBookPage();
      case ConnectionRequestsPage.routePath:
        return ConnectionRequestsPage();
      case ContactsScreen.routePath:
        return ContactsScreen();
      case EditProfilePage.routePath:
        return EditProfilePage();
      case CreateGroupScreen.routePath:
        return CreateGroupScreen();
      default:
        return MainScreen(fromPage: NavigationPage.mainScreen); // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    // Allow public routes without authentication
    if (widget.targetRoute == LinksPage.routePath) {
      return _getTargetRoute();
    }

    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return CommonWidget.getLoader();
        }

        // If user is not signed in
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return FutureBuilder<bool>(
            future: _checkNewUser(),
            builder: (context, newUserSnapshot) {
              if (newUserSnapshot.connectionState == ConnectionState.waiting) {
                return CommonWidget.getLoader();
              }
              AppLogger.instance
                  .i("newUserSnapshot.data: ${newUserSnapshot.data}");
              // If new user, show introduction screen
              if (newUserSnapshot.data == true) {
                return const AppIntroductionScreen();
              }

              // Otherwise show sign in page
              return const SignInPage();
            },
          );
        }

        // If user is signed in, navigate to the requested route
        return _getTargetRoute();
      },
    );
  }
}

/* todo


1. read together with anyone not just connections similar to how barter works reading reuest have to be accepted and will be integrated with chat or seperate section
2. add post to your lib will be a section in your porfile and used in recomednations
3. also work on the FIRE tracker
4. card controller do everything with it
5. barter select your product u want to barter with then send request user accept barter request and chat will open witht hat info if already connected then in existing vhat in rpfile have barter request and in web side bar
6. when u get a book buddy and u send a connect request it should be shown specially 
7. Push notification for message
8. in home page add the request icon button before book buddy
9. there will be 3 tabs connection request with special tag for book buddy request and filter show only book buddy request,  reading request and barter request


Core Features
Chapter-by-Chapter Progress Sync

Users can log their progress chapter-by-chapter or by percentage.
A visual progress bar displays each buddy's current chapter or page.
Discussion Threads for Chapters

Create private discussion threads for each chapter.
Include tools for marking spoilers to avoid ruining the experience for buddies who are behind.
Reading Goals

Set shared reading goals (e.g., “Finish Chapter 10 by Friday”).
Provide reminders or nudges to stay on track.
Book Annotations and Highlights

Allow buddies to share highlighted passages, quotes, or notes directly within the app.
Use tags (e.g., "funny," "thought-provoking") to categorize annotations.
Real-Time Notifications

Notify buddies when a user logs progress or completes a milestone, like finishing a chapter or the book.
Gamification
Reading Streaks

Track streaks for consistent reading.
Reward buddies for hitting milestones together (e.g., finishing a book, completing weekly goals).
Achievements and Badges

Grant badges for reading accomplishments, like "Weekend Warrior" for completing a big chunk over a weekend.
Friendly Competition

Add leaderboards for things like fastest progress or most notes shared.
Ensure it's collaborative and fun, not overly competitive.
Social and Interactive Features
Buddy Invites

Easily invite a friend to a buddy read using app links or QR codes.
Display mutual book interests to suggest books for reading together.
Group Reads

Expand to include small groups for book clubs or friend circles.
Display group progress with visual cues (e.g., bar charts or pie charts).
Virtual Reading Sessions

Provide options for timed reading sessions where buddies can read "together" virtually.
Add timers or focus music to simulate a co-reading experience.
Customization
Personalized Reading Schedules

Adjust reading schedules based on each buddy’s availability.
Include "catch-up" days for those who fall behind.
Progress Privacy Settings

Let users decide what progress to share (e.g., only completed chapters, detailed notes, or just general milestones).
Themed Buddy Spaces

Allow customization of discussion threads with themes (e.g., fantasy, mystery, sci-fi) or emojis that match the book.
Advanced Features
AI-Generated Discussion Prompts

Provide AI-generated questions or prompts for each chapter to spark meaningful discussions.
Tailor prompts based on the book’s genre or themes.
Integrated Media Sharing

Allow buddies to share related media (e.g., book trailers, fan art, or relevant articles) in the discussion thread.
Cross-Platform Sync

Sync progress across devices and platforms (web, mobile app, e-reader integrations).
Analytics and Insights
Reading Insights Dashboard

Show progress analytics like average pages per session or total hours spent reading.
Compare individual and buddy progress trends.
Shared Timeline

Display a timeline of the buddy read, showing milestones achieved and upcoming goals.
Most Loved Sections

Highlight chapters or sections with the most notes, annotations, or engagement between buddies.

  
*/
