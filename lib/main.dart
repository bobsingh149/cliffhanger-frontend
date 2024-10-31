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
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:barter_frontend/screens/contacts_screen.dart';

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
      ],
      child: const BarterApp(),
    ),
  );
}

class BarterApp extends StatelessWidget {
  final _themeMode = ThemeMode.system;
  const BarterApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1217, 674),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: AppTheme.getAppropriateLightTheme(), // Light theme
            darkTheme: AppTheme.getAppropriateDarkTheme(),
             // Dark theme
            themeMode: _themeMode, // Set theme mode
            routes: {
              AuthCheck.routePath: (context) =>  const ContactsScreen(),
              MainScreen.routePath: (context) => MainScreen(),
              HomePage.routePath: (context) => HomePage(),
              OnboardingPage.routePath: (context) =>
                  OnboardingPage(), // Add Book screen route
              ProfilePage.routePath: (context) => ProfilePage(),
              SignInPage.routePath: (context) => SignInPage(),
              PostBookPage.routePath: (context) => PostBookPage(),
              ConnectionRequestsPage.routePath: (context) => const ConnectionRequestsPage(),
              ContactsScreen.routePath: (context) => ContactsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == ChatScreen.routePath) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    contact: args['contact'],
                  ),
                );
              }
              return null;
              // ... handle other routes or return null ...
            },
          );
        });
  }
}


class AuthCheck extends StatefulWidget {
  static const String routePath = "/";
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      // Checking the Firebase auth status
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        // While the future is resolving (loading)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CommonWidget.getLoader(); // Show loading indicator
        }

        // If user is signed in, go to HomePage
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }

        // If no user is signed in, go to LoginPage
        return const SignInPage();
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
