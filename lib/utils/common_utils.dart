import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

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

  static void displaySnackbar(
      {required BuildContext context,required String message, SnackbarMode mode=SnackbarMode.error}) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    switch (mode) {
      case SnackbarMode.success:
        backgroundColor = Colors.lightGreen.withOpacity(0.23);
        borderColor = Colors.green.shade700;
        textColor = Colors.green.shade800;
        break;
      case SnackbarMode.error:
        backgroundColor = Colors.red.withOpacity(0.23);
        borderColor = Colors.red.shade700;
        textColor = Colors.red.shade800;
        break;
      case SnackbarMode.info:
        backgroundColor = Colors.blue.withOpacity(0.23);
        borderColor = Colors.blue.shade700;
        textColor = Colors.blue.shade800;
        break;
    }

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(7),
      ),
      margin: EdgeInsets.all(10.r), // Add margin to float the snackbar
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
