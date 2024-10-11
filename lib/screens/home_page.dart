import 'package:barter_frontend/screens/post_book.dart';
import 'package:barter_frontend/screens/user_profile.dart';
import 'package:barter_frontend/theme/theme.dart';
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
  bool _onlyBarter = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'NovelNest',
            style: GoogleFonts.medievalSharp(
              textStyle: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add), // Add book icon
              onPressed: () {
                Navigator.pushNamed(context, PostBookPage.routePath);
                // Implement add book functionality
              },
            ),
            SizedBox(
              width: 5.w,
            ),
            IconButton(
              icon: Icon(Icons.person), // Profile icon
              onPressed: () {
                Navigator.pushNamed(context, ProfilePage.routePath);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 7.h),
                    child: Text(
                      "Only Barter",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  SizedBox(
                    width: 3.w,
                  ),
                  Switch(
                      value: _onlyBarter,
                      onChanged: (value) {
                        setState(() {
                          _onlyBarter = value;
                        });
                      }),
                ],
              ),
              
            ],
          ),
        ));
  }
}
