import 'package:barter_frontend/provider/user_provider.dart';
import 'package:barter_frontend/screens/home_page.dart';
import 'package:barter_frontend/screens/user_onboarding.dart';
import 'package:barter_frontend/screens/user_profile.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
        HomePage.routePath: (context) => HomePage(), // Home route
        OnboardingPage.routePath : (context) => OnboardingPage(), // Add Book screen route
        ProfilePage.routePath: (context) => ProfilePage(), // Profile screen route
      },
          );
        });
  }
}
