import 'package:barter_frontend/services/auth_services.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier
{
    final AuthService _authService;
    String? errorMessage;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService.getInstance;


  
}