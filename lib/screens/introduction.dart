import 'package:barter_frontend/screens/sign_in_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class AppIntroductionScreen extends StatelessWidget {
  static const String routePath = '/introduction';
  const AppIntroductionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double imageWidth = kIsWeb ? 900 : double.infinity;
    const double imageHeight = kIsWeb ? 300 : 300;

    return SafeArea(
      child: IntroductionScreen(
        pages: [
          // First Page - App Overview
          PageViewModel(
            title: "Welcome to Cliffhanger",
            body:
                "Connect with book lovers, share your reading journey, and discover new books.",
            image: Center(
              child: Image.asset(
                'assets/books.png',
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
              ),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(fontSize: 18.0),
            ),
          ),

          // Second Page - Book Buddy & Feed
          PageViewModel(
            title: "Find Your Perfect Book Buddy",
            body:
                "Find and become book buddies with readers who share your interests through our smart matching algorithm.",
            image: Center(
              child: Image.asset(
                'assets/buddy.png',
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
              ),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(fontSize: 18.0),
            ),
          ),

          // Third Page - Book Bartering
          PageViewModel(
            title: "Barter Books Locally",
            body:
                "Exchange books with readers in your city and discover hidden gems nearby.",
            image: Center(
              child: Image.asset(
                'assets/barter.png',
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
              ),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
        showSkipButton: true,
        skip: const Text("Skip"),
        next: const Text("Next"),
        done: const Text("Continue"),
        onDone: () {
          // Navigate to sign in page when done
          Navigator.of(context).pushReplacementNamed(SignInPage.routePath);
        },
        onSkip: () {
          // Navigate to sign in page when skipped
          Navigator.of(context).pushReplacementNamed(SignInPage.routePath);
        },
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Theme.of(context).colorScheme.secondary,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}
