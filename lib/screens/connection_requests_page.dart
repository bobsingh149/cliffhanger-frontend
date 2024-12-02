import 'package:barter_frontend/models/user.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:barter_frontend/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:barter_frontend/models/user_setup.dart';
import 'package:barter_frontend/utils/common_decoration.dart';

class ConnectionRequestsPage extends StatelessWidget {
  static const String routePath = "/connection-requests";
  const ConnectionRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !kIsWeb,
        title: Text(
          'Connection Requests',
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: kIsWeb ? 800.w : double.infinity,
              ),
              child: FutureBuilder<List<RequestModel>>(
                future: Provider.of<UserProvider>(context, listen: false)
                    .getRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CommonWidget.getLoader();
                  }

                  if (snapshot.hasError) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      CommonUtils.displaySnackbar(
                        context: context,
                        message: 'Could not load connection requests',
                        mode: SnackbarMode.error,
                      );
                    });
                    return const SizedBox.shrink();
                  }

                  final requests = snapshot.data ?? [];

                  return ListView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.h, horizontal: 10.w),
                        child: Text(
                          'You have ${requests.length} pending requests',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ...requests.map((request) => _buildRequestCard(
                            name: request.userResponse.name,
                            imageUrl: request.userResponse.profileImage ?? '',
                            isBookBuddy: true,
                          )),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard({
    required String name,
    required String imageUrl,
    required bool isBookBuddy,
  }) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      return Card(
        margin: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 16.w : 3.w,
          vertical: 3.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        
          side: CommonDecoration.getWebAwareBorderSide(context),
          
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          child: Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 26,
                backgroundImage: CachedNetworkImageProvider(
                  imageUrl,
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  imageBuilder: (context, imageProvider) => Container(),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.person),
                ),
              ),
              SizedBox(width: 16.w),

              // Request Info
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleLarge,
                          ),
                          if (isBookBuddy) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Action Text Links
                    Row(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Accept',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Decline',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
