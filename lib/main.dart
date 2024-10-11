import 'package:barter_frontend/provider/book_provider.dart';
import 'package:barter_frontend/provider/chat_provider.dart';
import 'package:barter_frontend/provider/post_provider.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/screens/chat_screeen.dart';
import 'package:barter_frontend/screens/home_page.dart';
import 'package:barter_frontend/screens/post_book.dart';
import 'package:barter_frontend/screens/sign_in_page.dart';
import 'package:barter_frontend/screens/user_onboarding.dart';
import 'package:barter_frontend/screens/user_profile.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/common_decoration.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async{

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
        ChangeNotifierProvider(create: (_)=>PostProvider()),
        ChangeNotifierProvider(create: (_)=>ChatProvider())

  
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
            theme: AppTheme.lightTheme, // Light theme
            darkTheme: AppTheme.darkTheme, // Dark theme
            themeMode: _themeMode, // Set theme mode
            routes: {
        HomePage.routePath: (context) => const AuthCheck(),
        OnboardingPage.routePath : (context) => OnboardingPage(), // Add Book screen route
        ProfilePage.routePath: (context) => ProfilePage(),
        SignInPage.routePath:(context) => SignInPage(),
        PostBookPage.routePath:(context) => PostBookPage(),
      },
          );
        });
  }
}



class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

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
          return const HomePage();
        } 
        
        // If no user is signed in, go to LoginPage
        return const SignInPage();
      },
    );
  }
}




