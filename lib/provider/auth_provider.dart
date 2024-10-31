import 'package:barter_frontend/services/auth_services.dart';
import 'package:flutter/material.dart';

class AuthenticateProvider with ChangeNotifier {
  final AuthService _authService;
  String? email;
  String? password;

  AuthenticateProvider({AuthService? authService})
      : _authService = authService ?? AuthService.getInstance;

    void setCredentials(String email, String password){
    this.email = email;
    this.password = password;
  }
}
