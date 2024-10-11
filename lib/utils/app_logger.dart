import 'package:logger/logger.dart';

class AppLogger extends Logger {
 static AppLogger? _instance;

  AppLogger() : super(
     filter: null,
      printer: PrettyPrinter(
        methodCount: 5, // Number of method calls to be displayed
        errorMethodCount:
            10, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        // Should each log print contain a timestamp
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  )
  );
 static AppLogger get instance {
    _instance ??= AppLogger();
    return _instance!;
  }
}
