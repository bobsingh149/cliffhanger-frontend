import 'package:barter_frontend/models/book.dart';
import 'package:barter_frontend/models/book_category.dart';
import 'package:barter_frontend/provider/book_provider.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/common_decoration.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:barter_frontend/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PostBookPage extends StatefulWidget {
  static const String routePath = "/postBook";
  const PostBookPage({super.key});

  @override
  _PostBookPageState createState() => _PostBookPageState();
}

class _PostBookPageState extends State<PostBookPage> {
  final TextEditingController _captionController = TextEditingController();
  PostCategory? _selectedCategory = PostCategory.currentlyReading;
  final List<String> mockBooks = ["book1", "book2", "book3"];
  bool isLoading = true;
  bool isInit = true;
  BookProvider? bookProvider;
  bool _isHovered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      bookProvider = Provider.of<BookProvider>(context, listen: true);
      isInit = false;
    }

    
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: bookProvider!.isLoading
          ? CommonWidget.getLoader()
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 0.2.sw, vertical: 30.h),
              child: Container(
                padding: EdgeInsets.all(20.r),
                decoration: CommonDecoration.getContainerDecoration,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                        child: Text(
                      'Post Your Book',
                      style: Theme.of(context).textTheme.displayLarge,
                    )),
                    const Divider(
                      color: Colors.black26,
                    ),
                    SizedBox(height: 30.h),
                    SearchableDropdown(
                      provider: bookProvider!
                    ),
                    SizedBox(height: 30.h),

                    // Dropdown for Book Category
                    DropdownButtonFormField<PostCategory>(
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
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Caption Text Field
                    TextField(
                      controller: _captionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Write a caption...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Image Upload Section

                    // Image and Buttons using Stack
                    MouseRegion(
                      onEnter: (event) {
                        setState(() {
                          _isHovered = true;
                        });
                      },
                      onHover: (event) {
                        setState(() {
                          _isHovered = true;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          _isHovered = false;
                        });
                      },
                      child: SizedBox(
                        width: 200.w,
                        height: 200.h, // Adjusted height for buttons space
                        child: Stack(
                          children: [
                            // Image Container
                            Container(
                              width: double.infinity,
                              height: 200.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: bookProvider!.fileData != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: Image.memory(
                                        bookProvider!.fileData!,
                                        width: double.infinity,
                                        height: 200.h,
                                        fit: BoxFit.cover,
                                      ))
                                  : Center(
                                      child: Text(
                                        'Upload Image',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                            ),

                            // White Transparent Overlay on Hover
                            if (_isHovered && bookProvider!.fileData != null)
                              Container(
                                width: 200.w,
                                height: 200.h,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),

                            // Centered Delete Button on Hover
                            if (_isHovered && bookProvider!.fileData != null)
                              Positioned.fill(
                                child: Center(
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    iconSize: 30.r,
                                    onPressed: () {
                                      setState(() {
                                        bookProvider!.fileData =
                                            null; // Remove the image
                                      });
                                    },
                                  ),
                                ),
                              ),

                            // Positioned Camera Button
                            Positioned(
                              bottom: 0.h,
                              left: 50.w,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(
                                      0.85), // Semi-transparent black background
                                ),
                                child: IconButton(
                                    icon: const FaIcon(FontAwesomeIcons.camera),
                                    iconSize: 30.r,
                                    onPressed: () {
                                      setState(() {
                                        _isHovered = false;
                                      });
                                      bookProvider!
                                          .pickImage(ImageSource.camera);
                                    }),
                              ),
                            ),

                            // Positioned Gallery Button
                            Positioned(
                              bottom: 0.h,
                              right: 50.w,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(
                                      0.85), // Semi-transparent black background
                                ),
                                child: IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.image),
                                  iconSize: 30.r,
                                  onPressed: () {
                                    setState(() {
                                      _isHovered = false;
                                    });
                                    bookProvider!
                                        .pickImage(ImageSource.gallery);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 17.h),

                    // Submit Button
                    SizedBox(
                      width: 0.20.sw,
                      child: ElevatedButton(
                        onPressed: () async {
                          Book? book = bookProvider!.selectedBook;
                          await bookProvider!.postBook(PostUserBook(
                            title: book!.title,
                            score: book.score,
                            category: _selectedCategory!,
                            userId: "userid",
                            caption: _captionController.text.trim(),
                            authors: book.authors,
                            coverImages: book.coverImages,
                            subjects: book.subjects,
                            postImage: bookProvider!.fileData,
                          ));
                        },
                        child: const Text(
                          'Post Book',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
