import 'package:barter_frontend/provider/auth_provider.dart';
import 'package:barter_frontend/screens/main_screen.dart';
import 'package:barter_frontend/screens/user_onboarding.dart';
import 'package:barter_frontend/services/auth_services.dart';
import 'package:barter_frontend/theme/theme.dart';
import 'package:barter_frontend/utils/app_logger.dart';
import 'package:barter_frontend/utils/common_decoration.dart';
import 'package:barter_frontend/utils/common_utils.dart';
import 'package:barter_frontend/widgets/common_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/sign_button.dart';

class SignInPage extends StatefulWidget {
  static const String routePath = '/SignIn';

  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late AuthenticateProvider _authProvider;
  final _authService = AuthService.getInstance;
  final _logger = AppLogger.instance;
  final _formKey = GlobalKey<FormState>();

  // Create controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  // Add these new variables
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  bool isInit = true;

 

  void _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      isLoading = true;
    });
    try {
      User? user = await _authService.signInWithEmail(email, password);
      _logger.i(user!.email);

      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(MainScreen.routePath);
    } catch (e) {
      if (!mounted) {
        return;
      }
      CommonUtils.displaySnackbar(context: context, message: e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

   _authProvider.setCredentials(email, password);

    Navigator.of(context).pushReplacementNamed(OnboardingPage.routePath);


    setState(() {
      isLoading = true;
    });
  }

  void _signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    try {
      UserCredential? userCredential = await _authService.signInWithGoogle();
      if (userCredential == null || userCredential.user == null) {
        throw Exception('Google sign-in failed');
      }
      User user = userCredential.user!;
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      _logger.i(user.email);
      if (!mounted) return;

      if (isNewUser) {
        _logger.i("New user signed up with Google");
        // Navigate to onboarding or profile completion
        Navigator.of(context).pushReplacementNamed(OnboardingPage.routePath);
      } else {
        _logger.i("Existing user signed in with Google");
        Navigator.of(context).pushReplacementNamed(MainScreen.routePath);
      }
    } catch (e) {
      if (!mounted) return;
      CommonUtils.displaySnackbar(context: context, message: e.toString());
      _logger.e(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(isInit){
      _authProvider = Provider.of<AuthenticateProvider>(context);

      _emailFocusNode = FocusNode();
      _passwordFocusNode = FocusNode();
      FocusScope.of(context).requestFocus(_emailFocusNode);
      isInit = false;
    }
  }

  @override
  void dispose() {
    // Dispose of the focus nodes
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    // Dispose of the controllers when the widget is removed from the widget tree
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppTheme.primaryColor),
        child: isLoading
            ? CommonWidget.getLoader(color: Colors.white)
            : Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 0.15.sw),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Name or Logo
                      Text(
                        'Cliffhanger',
                        style: TextStyle(
                            fontSize: 50,
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
                                controller: _emailController,
                                focusNode: _emailFocusNode,
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
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                                },
                              ),
                              SizedBox(height: 15.h),

                              // Password Input
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
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
                                onFieldSubmitted: (_) {
                                  _signInWithEmail();
                                },
                              ),
                              SizedBox(height: 15.h),

                              // SignIn Button
                              ElevatedButton(
                                onPressed: _signInWithEmail,
                                child: Text(
                                  'Log In',
                                ),
                              ),
                              SizedBox(height: 15.h),

                              // OR Divider
                              Row(
                                children: [
                                  const Expanded(child: Divider(thickness: 1)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.0.w),
                                    child: const Text(
                                      'OR',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  const Expanded(child: Divider(thickness: 1)),
                                ],
                              ),
                              SizedBox(height: 15.h),

                              // Google SignIn Button
                              SignInButton(
                                btnTextColor: Colors.white,
                                btnColor: const Color.fromARGB(133, 139, 69, 19),
                                  buttonType: ButtonType.google,
                                  onPressed: _signInWithGoogle,
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
                              onPressed: _signUpWithEmail,
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
