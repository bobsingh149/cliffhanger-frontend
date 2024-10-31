import 'package:barter_frontend/models/book.dart';
import 'package:barter_frontend/models/book_category.dart';
import 'package:barter_frontend/provider/book_provider.dart';
import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:barter_frontend/widgets/search_bar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

class PostBookPage extends StatefulWidget {
  static const String routePath = "/postBook";
  const PostBookPage({Key? key}) : super(key: key);

  @override
  _PostBookPageState createState() => _PostBookPageState();
}

class _PostBookPageState extends State<PostBookPage> {
  final TextEditingController _captionController = TextEditingController();
  PostCategory? _selectedCategory = PostCategory.currentlyReading;
  late BookProvider bookProvider;
  bool isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      bookProvider = Provider.of<BookProvider>(context, listen: true);
      isInit = false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      await bookProvider.pickImage(kIsWeb ? ImageSource.gallery : source);
      setState(() {});
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _removeImage() {
    setState(() {
      bookProvider.fileData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bookProvider.isLoading
          ? CommonWidget.getLoader()
          : SingleChildScrollView(
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 0.1.sw, vertical: 15.h),
                child: FadeInUp(
                  duration: Duration(milliseconds: 500),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r)),
                    child: Padding(
                      padding: EdgeInsets.all(30.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Post Your Book',
                            style: Theme.of(context).textTheme.displayLarge,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30.h),
                          FadeInLeft(
                              child:
                                  SearchableDropdown(provider: bookProvider)),
                          SizedBox(height: 20.h),
                          FadeInRight(
                            child: DropdownButtonFormField<PostCategory>(
                              value: _selectedCategory,
                              items: PostCategory.values.map((category) {
                                return DropdownMenuItem<PostCategory>(
                                  value: category,
                                  child: Text(category.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 20.h),
                          FadeInLeft(
                            child: TextField(
                              controller: _captionController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Write a caption...',
                              ),
                            ),
                          ),
                          SizedBox(height: 30.h),
                          FadeInUp(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 250.w,
                                  height: 250.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.r),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: bookProvider.fileData != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15.r),
                                          child: Image.memory(
                                            bookProvider.fileData!,
                                            width: double.infinity,
                                            height: 250.h,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.add_photo_alternate,
                                            size: 50.r,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                ),
                                Positioned(
                                  bottom: 10.h,
                                  right: 300.w,
                                  child: FloatingActionButton(
                                    mini: true,
                                    child: Icon(Icons.add_a_photo),
                                    onPressed: () => _showImageSourceDialog(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30.h),
                          FadeInUp(
                            child: ElevatedButton(
                              onPressed: () => _postBook(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.h),
                                child: Text('Post Book',
                                    style: TextStyle(fontSize: 18)),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!kIsWeb)
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (bookProvider.fileData != null)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title:
                    Text('Remove photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _postBook() async {
    Book? book = bookProvider.selectedBook;
    if (book != null) {
      await bookProvider.postBook(SavePost(
        title: book.title,
        score: book.score,
        category: _selectedCategory!,
        userId: AuthService.getInstance.currentUser!.uid,
        caption: _captionController.text.trim(),
        authors: book.authors,
        coverImages: book.coverImages,
        subjects: book.subjects,
        postImage: bookProvider.fileData,
      ));
      // Show success message or navigate to another page
    } else {
      // Show error message
    }
  }
}
