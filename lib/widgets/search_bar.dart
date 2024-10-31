import 'dart:async';

import 'package:barter_frontend/models/book.dart';
import 'package:barter_frontend/provider/book_provider.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchableDropdown extends StatefulWidget {
  final BookProvider provider;
  final bool isHomePage;
  Function(Book)? onItemSelected;

  SearchableDropdown({super.key, required this.provider, this.onItemSelected, this.isHomePage = false});

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  Book? _selectedBook;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _textFieldKey = GlobalKey();
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
    setState(() {
      _isDropdownOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = _textFieldKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height,
            width: size.width,
            child: Material(
              elevation: 2,
              child: GestureDetector(
                onTap: () {}, // Prevent taps on the dropdown from closing it
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
                              child: Text("Start typing to see books"),
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
                                      borderRadius: BorderRadius.circular(7.r),
                                      child: CachedNetworkImage(
                                        imageUrl: widget.provider.searchResults[index].coverImages![0],
                                        width: 50.w,
                                        height: 50.h,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => CircularProgressIndicator(),
                                        errorWidget: (context, url, error) => FaIcon(FontAwesomeIcons.bookOpen, size: 50.r),
                                      ),
                                    ),
                                    title: Text(widget.provider.searchResults[index].title),
                                    onTap: () {
                                      setState(() {
                                        _selectedBook = widget.provider.searchResults[index];
                                        widget.provider.selectedBook = _selectedBook;
                                        _controller.text = widget.provider.searchResults[index].title;
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          key: _textFieldKey,
          child: SizedBox(
            height: widget.isHomePage ? 35.h : 50.h,
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
            
                if (_debounce?.isActive ?? false) _debounce?.cancel();
            
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
                });
              },
              onTap: () {
                if (!_isDropdownOpen) {
                  openDropdown();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
