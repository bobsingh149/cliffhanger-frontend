import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  static const String routePath = "/profile";

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<String> tabTitles = [
    'Currently Reading',
    'Barter Books',
    'Favourite Books'
  ];

  final Map<String, List<Map<String, String>>> tabData = {
    'Currently Reading': [
      {'title': 'Book 1', 'subtitle': 'Author: Author 1'},
      {'title': 'Book 2', 'subtitle': 'Author: Author 2'}
    ],
    'Barter Books': [
      {'title': 'Barter Book 1', 'subtitle': 'Status: Available'},
      {'title': 'Barter Book 2', 'subtitle': 'Status: Traded'}
    ],
    'Favourite Books': [
      {'title': 'Favourite Book 1', 'subtitle': 'Author: Author A'},
      {'title': 'Favourite Book 2', 'subtitle': 'Author: Author B'}
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mansi Great"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: DefaultTabController(
        length: tabTitles.length,
        child: Column(
          children: <Widget>[
            // User profile section
            UserProfileSection(),

            // TabBar for the three sections
            TabBar(
              tabs: tabTitles.map((title) => Tab(text: title)).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: tabTitles.map((title) {
                  return buildTabContent(title);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabContent(String tabTitle) {
    List<Map<String, String>> items = tabData[tabTitle] ?? [];

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index]['title']!),
          subtitle: Text(items[index]['subtitle']!),
        );
      },
    );
  }
}

class UserProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0.r),
      child: Column(
        children: [
          // Profile picture and details
          Row(
            children: [
              // Profile picture
              CircleAvatar(
                radius:60.r,
                backgroundImage: AssetImage(
                    'assets/profile.jpg'), // Add profile image path here
              ),
              SizedBox(width: 16.w),

              // Name and bio
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mansi Great',
                    style:
                        TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Book lover and avid reader!',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
