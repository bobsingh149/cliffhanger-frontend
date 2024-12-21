import 'dart:async';

import 'package:barter_frontend/constants/constant_data.dart';
import 'package:barter_frontend/models/post.dart';
import 'package:barter_frontend/provider/book_provider.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StaticSearchbar extends StatefulWidget {
  final Function(String) onItemSelected;
  final FocusNode? focusNode;
  final String? initialValue;

  const StaticSearchbar({
    Key? key,
    required this.onItemSelected,
    this.focusNode,
    this.initialValue,
  }) : super(key: key);

  @override
  State<StaticSearchbar> createState() => _StaticSearchbarState();
}

class _StaticSearchbarState extends State<StaticSearchbar> {
  List<String> filteredCities = cities;
  String? _selectedCity;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selectedCity = widget.initialValue;
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void didUpdateWidget(StaticSearchbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != null &&
        widget.initialValue != _controller.text) {
      setState(() {
        _selectedCity = widget.initialValue;
        _controller.text = widget.initialValue!;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _openDropdown() {
    if (!_isDropdownOpen) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      setState(() {
        _isDropdownOpen = true;
      });
    } else {
      _closeDropdown();
      _openDropdown();
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    setState(() {
      _isDropdownOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox;
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
              child: InkWell(
                onTap: () {}, // Prevent taps on the dropdown from closing it
                child: Container(
                  constraints:
                      BoxConstraints(minHeight: 230.h, maxHeight: 230.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        child: ListTile(
                          title: Text(filteredCities[index]),
                          onTap: () {
                            _handleItemSelection(filteredCities[index]);
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

  void _handleItemSelection(String city) {
    setState(() {
      _selectedCity = city;
      _controller.text = _selectedCity!;
      widget.onItemSelected(_selectedCity!);
      if (_isDropdownOpen) _closeDropdown();
    });
    widget.focusNode?.nextFocus(); // Move focus to the next field
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          key: _textFieldKey,
          child: TextField(
            controller: _controller,
            focusNode: widget.focusNode,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 10.w, top: 7.h),
                child: const FaIcon(FontAwesomeIcons.magnifyingGlass),
              ),
              hintText: 'Search your city ...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                filteredCities = cities
                    .where((city) =>
                        city.toLowerCase().startsWith(value.toLowerCase()))
                    .toList();
                _openDropdown();
              });
            },
            onTap: () {
              if (!_isDropdownOpen) {
                _openDropdown();
              }
            },
            onSubmitted: (value) {
              if (filteredCities.isNotEmpty) {
                _handleItemSelection(filteredCities.first);
              }
            },
          ),
        ),
      ],
    );
  }
}
