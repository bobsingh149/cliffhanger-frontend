import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommonWidget {
  static Widget getLoader() {
    return Center(
      child: LoadingAnimationWidget.inkDrop(color: Colors.white, size: 50.r),
    );
  }
}
