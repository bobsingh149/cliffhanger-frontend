import 'package:barter_frontend/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LinksPage extends StatelessWidget {
  static const String routePath = "/links";

  const LinksPage({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Links'),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Cliffhanger',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color:AppTheme.primaryColor),
              ),
              SizedBox(height: 10.h),
              Text(
                'Book Social Media',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 40.h),
              _buildLinkCard(
                context,
                'Frontend Repository',
                'https://github.com/dushyantsingh-ds/cliffhanger-frontend',
                FontAwesomeIcons.github,
              ),
              SizedBox(height: 15.h),
              _buildLinkCard(
                context,
                'Backend Repository',
                'https://github.com/dushyantsingh-ds/cliffhanger-backend',
                FontAwesomeIcons.github,
              ),
              SizedBox(height: 15.h),
              _buildLinkCard(
                context,
                'Website',
                'https://cliffhanger-frontend.web.app',
                FontAwesomeIcons.globe,
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: _buildLinkCard(
                      context,
                      'Android App',
                      'https://play.google.com/store/apps/details?id=com.dushyant.cliffhanger',
                      FontAwesomeIcons.googlePlay,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: _buildLinkCard(
                      context,
                      'iOS App',
                      'https://apps.apple.com/app/cliffhanger',
                      FontAwesomeIcons.appStore,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkCard(
      BuildContext context, String title, String url, IconData icon) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: () => _launchUrl(url),
        leading: FaIcon(icon),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
