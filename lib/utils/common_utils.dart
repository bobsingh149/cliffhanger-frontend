import 'package:barter_frontend/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

enum SnackbarMode {
  success,
  error,
  info,
}

class CommonUtils {
  static String formatDateTime(DateTime dateTime) {
    // Extract day and append the ordinal suffix
    String day = DateFormat('d').format(dateTime);
    String dayWithSuffix = _getDayWithSuffix(int.parse(day));

    // Format the time and month part
    String formattedTime =
        DateFormat('HH:mm').format(dateTime); // 24-hour format
    String formattedMonth =
        DateFormat('MMM').format(dateTime); // Short month format

    // Combine everything
    return '$formattedTime, $dayWithSuffix $formattedMonth';
  }

// Helper function to get day with the ordinal suffix (st, nd, rd, th)
  static String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static void displaySnackbar(
      {required BuildContext context,
      required String message,
      SnackbarMode mode = SnackbarMode.error}) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    switch (mode) {
      case SnackbarMode.success:
        backgroundColor = Colors.green;
        borderColor = Colors.white;
        textColor = Colors.white;
        break;
      case SnackbarMode.error:
        backgroundColor = AppTheme.secondaryColor;
        borderColor = Colors.white;
        textColor = Colors.white;
        break;
      case SnackbarMode.info:
        backgroundColor = Colors.blue;
        borderColor = Colors.white;
        textColor = Colors.white;
        break;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: textColor, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ],
      ),
      width: kIsWeb ? 370 : null,
      backgroundColor: backgroundColor,
      behavior: kIsWeb ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kIsWeb ? 5 : 7),
      ),
      duration: const Duration(seconds: 4),
      elevation: kIsWeb ? 6 : 0,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static String formatDateOnly(DateTime date) {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }
}
