import 'package:barter_frontend/models/post.dart';
import 'package:barter_frontend/provider/post_provider.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

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

  static void displaySnackbar({
    required BuildContext context,
    required String message,
    SnackbarMode mode = SnackbarMode.error,
  }) {
    ContentType contentType;
    String title;

    switch (mode) {
      case SnackbarMode.success:
        contentType = ContentType.success;
        title = 'Success';
        break;
      case SnackbarMode.error:
        contentType = ContentType.failure;
        title = 'Error';
        break;
      case SnackbarMode.info:
        contentType = ContentType.help;
        title = 'Info';
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
        inMaterialBanner: false,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
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
