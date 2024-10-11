import 'package:barter_frontend/models/book.dart';
import 'package:barter_frontend/services/book_services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';

class BookProvider with ChangeNotifier {
  List<Book> _searchResults = [];
  final BookService bookService = BookService.getInstance;
  String? errorMessage;
  bool isLoading = false;
  Book? selectedBook;
  final ImagePicker picker = ImagePicker(); 
  Uint8List? fileData;

  List<Book> get searchResults {
    return _searchResults;
  }

  Future<void> query(String query) async {
    try {
      _searchResults = await bookService.getResults(query);
    } catch (err) {
      errorMessage = err.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> postBook(PostUserBook userBook) async {
    isLoading = true;
    notifyListeners();
    try {
      await bookService.postBook(userBook);
      print("success");

      return true;
    } catch (err) {
      errorMessage = err.toString();
      print("error message:  $errorMessage");
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
