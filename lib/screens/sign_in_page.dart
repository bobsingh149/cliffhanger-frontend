import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:barter_frontend/utils/common_decoration.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInPage extends StatefulWidget {
  static const String routePath = '/SignIn';

  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _authService = AuthService.getInstance;
  final _logger = AppLogger.instance;
  final _formKey = GlobalKey<FormState>();

  // Create controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signInWithEmail() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      User? user = await _authService.signInWithEmail(email, password);
      _logger.i(user!.email);
    } catch (e) {
      CommonUtils.displaySnackbar(context: context, message: e.toString());
    }
  }

  void _signUpWithEmail() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      User? user = await _authService.signUpWithEmail(email, password);
      _logger.i(user!.email);

    } catch (e) {
      CommonUtils.displaySnackbar(context: context, message: e.toString());
    }
  }

  void _signInWithGoogle() async {
    try {
      User? user = await _authService.signInWithGoogle();
      _logger.i(user!.email);
    } catch (e) {
      CommonUtils.displaySnackbar(context: context, message: e.toString());
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
            AppTheme.secondaryColor,
            
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 0.15.sw),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Name or Logo
                Text(
                  'NovelNest',
                  style: TextStyle(
                      fontSize: 50.w,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor),
                ),
                SizedBox(height: 30.h),

                // SignIn Form
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: CommonDecoration.getContainerDecoration,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Input
                        TextFormField(
                          controller: _emailController, // Attach the controller
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15.h),

                        // Password Input
                        TextFormField(
                          controller:
                              _passwordController, // Attach the controller
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15.h),

                        // SignIn Button
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Use the controllers' text values
                              String email = _emailController.text;
                              String password = _passwordController.text;

                              print('Email: $email');
                              print('Password: $password');
                              // Perform your sign-in logic with the email and password
                            }
                          },
                          child: Text(
                            'Log In',
                          ),
                        ),
                        SizedBox(height: 15.h),

                        // OR Divider
                        Row(
                          children: [
                            Expanded(child: Divider(thickness: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'OR',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Expanded(child: Divider(thickness: 1)),
                          ],
                        ),
                        SizedBox(height: 15.h),

                        // Google SignIn Button
                        ElevatedButton.icon(
                          onPressed: () {
                            // Handle Google SignIn
                          },
                          icon: FaIcon(FontAwesomeIcons.google),
                          label: Text('Log in with Google'),
                        ),
                        SizedBox(height: 15.h),

                        // Forgot Password
                        TextButton(
                          onPressed: () {
                            // Navigate to forgot password page
                          },
                          child: Text(
                            'Forgot password?',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Sign Up Link
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: CommonDecoration.getContainerDecoration,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(
                        width: 7.w,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to sign-up page
                        },
                        child: Text(
                          'Sign up',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
