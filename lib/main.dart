import 'package:barter_frontend/screens/book_buddies_screen.dart';
import 'package:barter_frontend/screens/chat_screen.dart';
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
import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:barter_frontend/screens/contacts_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:barter_frontend/models/user.dart';
import 'package:barter_frontend/models/contact.dart';
import 'package:barter_frontend/screens/create_group_screen.dart';
import 'package:barter_frontend/screens/link_screen.dart';
import 'package:barter_frontend/screens/introduction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticateProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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

  @override
  void initState() {
    super.initState();
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
        return MainScreen();
      case HomePage.routePath:
        return HomePage();
      case OnboardingPage.routePath:
        return OnboardingPage();
      case ProfilePage.routePath:
        return ProfilePage(userId: "user10");
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
        return MainScreen(); // Default fallback
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
              AppLogger.instance.i("newUserSnapshot.data: ${newUserSnapshot.data}");
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
swipable cards for the mobile
find book buddy button on the app bar 
everyday new book buddy u can find

shecdule post through the temporal

send periodic mails to remind users to use the app

have searchbar on top of the page that will search based on title,author and subjects no need for subjects dropdown

top bar chat and profile

bottom bar home,add book,settings

1. Make a check if onboaring is done , make a bool api on backend select 1 where
2. update onboarding api to accept multipart data and send the same from client side
   also make a city dropdown make it optional
3. On homapge fetch data based on common count, only_barter based on same city then score
4. Get a list of dropdown of all availiable subject make it searchable and filter based on it
5. Make a settings page to be able to sign out and edit info
6. Make a all connections page
7. Make a bottom navigation bar 3 options homepage, add book, settings on top bar there will be 
   chat and profile

8. Make sure all the naviagtion is working
9. Notifications for message and reminder to use the app 
10. Implemnet the likes, comment if u like a specifc book do show more with same subjects
11. Option to delete the post cannot be edited
12. For home page consider the following give them common_book_count of user 
   + common_subject_count of your books  +  bias if it is from your connetion or book you liked 
    common subject count 

    there will be bias for liked book common subject count and liked book user
    everything will also have a weight
13. either show post image or cover image make titleclickable and show info about book
  in show dialog
  
*/
