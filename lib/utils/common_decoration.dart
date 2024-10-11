import 'package:barter_frontend/theme/theme.dart';
import 'package:flutter/material.dart';

class CommonDecoration
{
  static BoxDecoration get getContainerDecoration {
    return BoxDecoration(
      border: const Border(top: BorderSide(color: AppTheme.secondaryColor,width: 5)),
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(15),
    );
  } 
}