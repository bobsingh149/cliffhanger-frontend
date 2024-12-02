import 'package:barter_frontend/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommonWidget {

  static Widget getButtonLoader({Color color = AppTheme.primaryColor}) {
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color,
        ),
      ),
    );
  }

  static Widget getLoader({Color color = AppTheme.primaryColor}) {
    return Center(
      child: LoadingAnimationWidget.inkDrop(color: color, size: 50),
    );
  }

  static Widget getCustomCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    required bool isDark,
  }) {
    const elevation = kIsWeb ? 3.0 : 3.0;
    
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: backgroundColor ?? (isDark ? AppTheme.surfaceColorDark : AppTheme.surfaceColorLight),
      shadowColor: isDark ? AppTheme.primaryColor.withOpacity(0.7) : null,
      child: child,
    );
  }
}
