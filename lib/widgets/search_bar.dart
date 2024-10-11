import 'dart:async';

import 'package:barter_frontend/models/book.dart';
import 'package:barter_frontend/provider/book_provider.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchableDropdown extends StatefulWidget {
  final BookProvider provider;
  Function(Book)? onItemSelected;

  SearchableDropdown({super.key, required this.provider, this.onItemSelected});

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  Book? _selectedBook;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _textFieldKey =
      GlobalKey(); // Key for the TextField to get its position
  OverlayEntry? _overlayEntry;

  bool _isDropdownOpen = false;
  Timer? _debounce;
  bool isLoading = false;
  bool _startedTyping = false;
  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void openDropdown() {
    if (!_isDropdownOpen) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      setState(() {
        _isDropdownOpen = true;
      });
    } else {
      _closeDropdown();
      openDropdown();
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _isDropdownOpen = false;
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 2,
          child: Container(
            constraints: BoxConstraints(minHeight: 230.h, maxHeight: 230.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: isLoading
                ? CommonWidget.getLoader()
                : !_startedTyping
                    ? Center(
                        child: Text("Start to typing to see books"),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: widget.provider.searchResults.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    7.r), // Adjust the radius as needed
                                child: Image.network(
                                  widget.provider.searchResults[index]
                                      .coverImages![0],
                                  width: 50.w, // Width of the image
                                  height: 50.h, // Height of the image
                                  fit: BoxFit
                                      .cover, // Ensure the image covers the container
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback widget in case the image fails to load
                                    return Icon(Icons.book, size: 50.r);
                                  },
                                ),
                              ),
                              title: Text(
                                  widget.provider.searchResults[index].title),
                              onTap: () {
                                setState(() {
                                  _selectedBook =
                                      widget.provider.searchResults[index];
                                  widget.provider.selectedBook = _selectedBook;
                                  _controller.text = widget
                                      .provider.searchResults[index].title;
                                  if (_isDropdownOpen) _closeDropdown();
                                });
                              },
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          key: _textFieldKey, // Assign the GlobalKey to the widget
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              prefixIcon: _selectedBook == null
                  ? Padding(
                      padding: EdgeInsets.only(left: 10.w, top: 5.h),
                      child: FaIcon(FontAwesomeIcons.searchengin),
                    )
                  : null,
              hintText: 'Search your book ...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _startedTyping = value.isNotEmpty;
                openDropdown();
              });

              // Debounce logic: cancel the previous timer if it's active
              if (_debounce?.isActive ?? false) _debounce?.cancel();

              // Start a new timer that will trigger after 300ms
              _debounce = Timer(const Duration(milliseconds: 300), () async {
                setState(() {
                  if (widget.provider.searchResults.isEmpty) {
                    isLoading = true;
                    openDropdown();
                  }
                });

                await widget.provider.query(value);
                setState(() {
                  openDropdown();
                  isLoading = false;
                });
                // await widget.provider.query(
                //     value); // Call the search function after the debounce interval
              });
            },
            // onTapOutside: (event) {
            //   if (_isDropdownOpen) _closeDropdown();
            // },

            // onEditingComplete: () {
            //   _addItem(
            //       _controller.text); // Add item to list when Enter is pressed
            //   if (!_isDropdownOpen) {
            //     _openDropdown(); // Reopen the dropdown to show updated items
            //   }
            // },
            onTap: () {
              if (!_isDropdownOpen) {
                openDropdown(); // Open the dropdown when the text field is tapped
              }
            },
          ),
        ),
      ],
    );
  }
}
