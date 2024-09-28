import 'package:barter_frontend/screens/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  static const String routePath = "/";
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book Barter',
          style: GoogleFonts.medievalSharp(
            textStyle: TextStyle(fontSize: 26.sp),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add), // Add book icon
            onPressed: () {
              // Implement add book functionality
              print('Add Book button pressed');
            },
          ),
          SizedBox(width: 5.w,),
          IconButton(
            icon: Icon(Icons.person), // Profile icon
            onPressed: () {
              Navigator.pushNamed(context, ProfilePage.routePath);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to BookBarter!',
        ),
      ),
    );
  }
}
