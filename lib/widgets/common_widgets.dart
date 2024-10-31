import 'package:barter_frontend/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommonWidget {
  static Widget getLoader({Color color = AppTheme.primaryColor}) {
    return Center(
      child: LoadingAnimationWidget.inkDrop(color: color, size: 50.r),
    );
  }
}
