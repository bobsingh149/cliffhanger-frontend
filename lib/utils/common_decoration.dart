import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:barter_frontend/theme/theme.dart';

class CommonDecoration
{
  static BoxDecoration getContainerDecoration(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      border: Border(
        top: const BorderSide(color: AppTheme.secondaryColor, width: 2),
        left: const BorderSide(color: AppTheme.secondaryColor, width: 0.5),
        right: const BorderSide(color: AppTheme.secondaryColor, width: 0.5),
        bottom: const BorderSide(color: AppTheme.secondaryColor, width: 0.5),
      ),
      borderRadius: BorderRadius.circular(15),
      color: isDarkMode 
          ? Colors.grey[850]  
          : Colors.grey[100],
    );
  } 

  static BorderSide getWebAwareBorderSide(BuildContext context, {bool isWeb = kIsWeb}) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BorderSide(
      color: isWeb
          ? theme.colorScheme.outline.withOpacity(0.1)
          : theme.colorScheme.outline.withOpacity(0.05),
      width: (isWeb && isDarkMode) ? 1.0 : 0.5,
      style: isWeb ? BorderStyle.solid : BorderStyle.none,
    );
  }
}