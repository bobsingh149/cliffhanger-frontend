import 'package:barter_frontend/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticateProvider with ChangeNotifier {
  final AuthService _authService;
  String? email;
  String? password;
  bool isLoading = false;

  AuthenticateProvider({AuthService? authService})
      : _authService = authService ?? AuthService.getInstance;

  void setCredentials(String email, String password) {
    this.email = email;
    this.password = password;
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<User?> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      return await _authService.signInWithEmail(email, password);
    } finally {
      _setLoading(false);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    _setLoading(true);
    try {
      return await _authService.signInWithGoogle();
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      return await _authService.signUpWithEmail(email, password);
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> signInAnonymously() async {
    _setLoading(true);
    try {
      return await _authService.signInWithDemoAccount();
    } finally {
      _setLoading(false);
    }
  }
}
