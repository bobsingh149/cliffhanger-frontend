import 'package:barter_frontend/models/post.dart';
import 'package:barter_frontend/models/post_category.dart';
import 'package:barter_frontend/provider/book_provider.dart';
import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/common_utils.dart';
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
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      bookProvider = Provider.of<BookProvider>(context, listen: true);
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(_searchFocusNode);
        }
      });
      
      isInit = false;
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
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
      body: SafeArea(
        child: bookProvider.isLoading
            ? CommonWidget.getLoader()
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: kIsWeb ? 0.15.sw : 0.w,
                    vertical: kIsWeb ? 30.h : 5.h
                  ),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: kIsWeb 
                      ? CommonWidget.getCustomCard(
                          isDark: Theme.of(context).brightness == Brightness.dark,
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: kIsWeb ? 0.85.sh : 0.85.sh,
                            ),
                            padding: EdgeInsets.all(kIsWeb ? 20.r : 5.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Post Your Book',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: AppTheme.primaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: kIsWeb ? 20.h : 36.h),
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
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      hintText: 'Write a caption...',
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                FadeInUp(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: kIsWeb ? 200.w : 200.w,
                                        height: kIsWeb ? 220.h : 220.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(kIsWeb ? 15 : 10),
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
                                                    BorderRadius.circular(15),
                                                child: Image.memory(
                                                  bookProvider.fileData!,
                                                  width: double.infinity,
                                                  height: 200.h,
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
                                        bottom: kIsWeb ? 10.h : 5.h,
                                        right: kIsWeb ? 160.w : 50.w,
                                        child: FloatingActionButton(
                                          backgroundColor: AppTheme.primaryColor.withOpacity(0.5),
                                          mini: true,
                                          child: Icon(Icons.add_a_photo),
                                          onPressed: () => _showImageSourceDialog(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: kIsWeb ? 20.h : 36.h),
                                FadeInUp(
                                  child: ElevatedButton(
                                    onPressed: () => _postBook(),
                                    child: Text('Post Book',),
                                   
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          constraints: BoxConstraints(
                            minHeight: 0.85.sh,
                          ),
                          padding: EdgeInsets.all(5.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Post Your Book',
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: AppTheme.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 36.h),
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
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Write a caption...',
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              FadeInUp(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 200.w,
                                      height: 220.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
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
                                                  BorderRadius.circular(15),
                                              child: Image.memory(
                                                bookProvider.fileData!,
                                                width: double.infinity,
                                                height: 200.h,
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
                                      bottom: 5.h,
                                      right: 50.w,
                                      child: FloatingActionButton(
                                        backgroundColor: AppTheme.primaryColor.withOpacity(0.5),
                                        mini: true,
                                        child: Icon(Icons.add_a_photo),
                                        onPressed: () => _showImageSourceDialog(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 36.h),
                              FadeInUp(
                                child: ElevatedButton(
                                  onPressed: () => _postBook(),
                                  child: Text('Post Book',),
                                 
                                ),
                              ),
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
      try {
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
        
        // Show success message
        CommonUtils.displaySnackbar(
          context: context,
          message: "Book posted successfully!",
          mode: SnackbarMode.success,
        );

     
        
      } catch (e) {
        // Show error message
        CommonUtils.displaySnackbar(
          context: context,
          message: "Failed to post book: ${e.toString()}",
          mode: SnackbarMode.error,
        );
      }
    } else {
      // Show error message for no book selected
      CommonUtils.displaySnackbar(
        context: context,
        message: "Please select a book to post",
        mode: SnackbarMode.error,
      );
    }
  }
}
