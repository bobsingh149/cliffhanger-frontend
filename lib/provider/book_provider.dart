import 'package:barter_frontend/models/post.dart';
import 'package:barter_frontend/services/book_services.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart' if (dart.library.io) 'package:barter_frontend/utils/mock_image_picker_web.dart';

class BookProvider with ChangeNotifier {
  List<Book> _searchResults = [];
  final BookService bookService = BookService.getInstance;
  bool isLoading = false;
  Book? selectedBook;
  final ImagePicker picker = ImagePicker();
  Uint8List? fileData;

  List<Book> get searchResults {
    return _searchResults;
  }

  Future<List<Book>> query(String query) async {
    try {
      return _searchResults = await bookService.getResults(query);
    } catch (err) {
      AppLogger.instance.e("error message:  ${err.toString()}");
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> postBook(SavePost userBook) async {
    isLoading = true;
    notifyListeners();
    try {
      await bookService.postBook(userBook);
      AppLogger.instance.i("success");

      return true;
    } catch (err) {
      AppLogger.instance.e("error message:  ${err.toString()}");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Method to pick an image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    if (kIsWeb) {
      fileData = await ImagePickerWeb.getImageAsBytes();
    } else {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        fileData = await pickedFile.readAsBytes();
      }
    }
    notifyListeners();
  }
}
