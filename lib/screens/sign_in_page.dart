import 'package:barter_frontend/provider/auth_provider.dart';
import 'package:barter_frontend/screens/main_screen.dart';
import 'package:barter_frontend/screens/user_onboarding.dart';
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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:barter_frontend/screens/link_screen.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInPage extends StatefulWidget {
  static const String routePath = '/SignIn';

  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late AuthenticateProvider _authProvider;
  final _logger = AppLogger.instance;
  final _formKey = GlobalKey<FormState>();

  // Create controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isDialogShown = false;

  // Add these new variables
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;
  bool isInit = true;

  // Add this new state variable
  bool isSignInView = true;

  // Add animation duration
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final Curve _animationCurve = Curves.easeInOut;

  // Add this variable at the top of _SignInPageState class
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser();
  }

  final String _preferencesKey = "welcome_dialog_shown";

  // Add this new method
  Future<void> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = !prefs.containsKey(_preferencesKey);
      if (_isFirstTime) {
        _showWelcomeDialog();
      }
    });
  }

  // Update the toggle method
  void _toggleView() {
    setState(() {
      // Add a slight delay to allow text fields to animate out before clearing
      Future.delayed(_animationDuration, () {
        if (mounted) {
          _emailController.clear();
          _passwordController.clear();
        }
      });
      isSignInView = !isSignInView;
    });
  }

  void _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      User? user = await _authProvider.signInWithEmail(email, password);
      _logger.i(user!.email);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(MainScreen.routePath);
    } catch (e) {
      if (!mounted) return;
      CommonUtils.displaySnackbar(context: context, message: e.toString());
    }
  }

  void _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    User? user = await _authProvider.signUpWithEmail(email, password);
    _logger.i(user!.email);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(OnboardingPage.routePath);
  }

  void _signInWithGoogle() async {
    try {
      UserCredential? userCredential = await _authProvider.signInWithGoogle();
      if (userCredential == null || userCredential.user == null) {
        throw Exception('Google sign-in failed');
      }
      User user = userCredential.user!;
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      _logger.i(user.email);
      if (!mounted) return;

      if (isNewUser) {
        _logger.i("New user signed up with Google");
        Navigator.of(context).pushReplacementNamed(OnboardingPage.routePath);
      } else {
        _logger.i("Existing user signed in with Google");
        Navigator.of(context).pushReplacementNamed(MainScreen.routePath);
      }
    } catch (e) {
      if (!mounted) return;
      CommonUtils.displaySnackbar(context: context, message: e.toString());
      _logger.e(e.toString());
    }
  }

  void _signInWithGuest() async {
    try {
      User? user = await _authProvider.signInAnonymously();
      if (user == null) {
        throw Exception('Guest sign-in failed');
      }

      _logger.i("New guest user signed in");
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(MainScreen.routePath);
    } catch (e) {
      if (!mounted) return;
      CommonUtils.displaySnackbar(context: context, message: e.toString());
      _logger.e(e.toString());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isInit) {
      _authProvider = Provider.of<AuthenticateProvider>(context);

      _emailFocusNode = FocusNode();
      _passwordFocusNode = FocusNode();

      isInit = false;
    }
  }

  // Method to show the welcome dialog
  void _showWelcomeDialog() async {
    if (_isFirstTime && !_isDialogShown) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_preferencesKey, true);

      setState(() {
        _isDialogShown = true;
      });

      if (!mounted) return;

      QuickAlert.show(
        context: context,
        type: QuickAlertType.custom,
        barrierDismissible: false,
        confirmBtnText: 'See Demo',
        cancelBtnText: 'Sign In',
        showCancelBtn: true,
        title: 'Welcome to Cliffhanger',
        titleColor: AppTheme.textColorDark,
        widget: Container(
          padding: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 20.w : 16.w,
            vertical: kIsWeb ? 21.h : 16.h,
          ),
          child: Text(
            'Try Demo or \n sign in to your account',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textColorDark,
                ),
          ),
        ),
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          setState(() {
            _isDialogShown = false;
          });
          _signInWithGuest();
        },
        onCancelBtnTap: () {
          Navigator.of(context).pop();
          setState(() {
            _isDialogShown = false;
          });
        },
        confirmBtnColor: AppTheme.primaryColor.withOpacity(0.7),
        cancelBtnTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppTheme.primaryColor,
            ),
        backgroundColor: AppTheme.surfaceColorDark,
      );
    }
  }

  // Method to navigate to the Demo (assuming MainScreen as Demo)
  void _navigateToDemo() {
    Navigator.of(context).pushReplacementNamed(MainScreen.routePath);
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
      body: SafeArea(
        child: Container(
          child: _authProvider.isLoading
              ? CommonWidget.getLoader()
              : Center(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: kIsWeb ? 330.w : 5.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Cliffhanger',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                            if (kIsWeb) ...[
                              SizedBox(width: 10.w),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(LinksPage.routePath);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                child: Text('Get App'),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 35.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 25.h),
                          decoration:
                              CommonDecoration.getContainerDecoration(context)
                                  .copyWith(
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .shadowColor
                                    .withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                AnimatedSwitcher(
                                  duration: _animationDuration,
                                  switchInCurve: _animationCurve,
                                  switchOutCurve: _animationCurve,
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: Offset(0, 0.1),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Column(
                                    key: ValueKey<bool>(isSignInView),
                                    children: [
                                      TextFormField(
                                        controller: _emailController,
                                        focusNode: _emailFocusNode,
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                          FocusScope.of(context)
                                              .requestFocus(_passwordFocusNode);
                                        },
                                      ),
                                      SizedBox(height: 18.h),
                                      TextFormField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocusNode,
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                          isSignInView
                                              ? _signInWithEmail()
                                              : _signUpWithEmail();
                                        },
                                      ),
                                      SizedBox(height: 18.h),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(double.infinity,
                                              kIsWeb ? 45.h : 36.h),
                                        ),
                                        onPressed: isSignInView
                                            ? _signInWithEmail
                                            : _signUpWithEmail,
                                        child: Text(
                                          isSignInView ? 'Sign In' : 'Sign Up',
                                        ),
                                      ),
                                      SizedBox(height: 18.h),
                                      Row(
                                        children: [
                                          const Expanded(
                                              child: Divider(thickness: 1)),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10.0.w),
                                            child: Text(
                                              'OR',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 1.5,
                                                  ),
                                            ),
                                          ),
                                          const Expanded(
                                              child: Divider(thickness: 1)),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      SignInButton(
                                        btnTextColor: Colors.white,
                                        btnColor: AppTheme.tertiaryColor,
                                        buttonType: ButtonType.google,
                                        onPressed: _signInWithGoogle,
                                        btnText: isSignInView
                                            ? 'Sign in with Google'
                                            : 'Sign up with Google',
                                      ),
                                      SizedBox(height: 12.h),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 15.h),
                          decoration:
                              CommonDecoration.getContainerDecoration(context)
                                  .copyWith(
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .shadowColor
                                    .withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                kIsWeb
                                    ? SizedBox(
                                        width: 100.w,
                                      )
                                    : SizedBox(
                                        width: 5.w,
                                      ),
                                TextButton(
                                  onPressed: _signInWithGuest,
                                  style: TextButton.styleFrom(
                                    padding: kIsWeb
                                        ? EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 15.h)
                                        : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: AppTheme.primaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    foregroundColor: AppTheme.primaryColor,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                  child: Text('Use Demo Account'),
                                ),
                                SizedBox(width: 16.w),
                                SizedBox(
                                  height: 30.h, // Adjust this value as needed
                                  child: VerticalDivider(
                                    thickness: 1.5,
                                    width: 1,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                TextButton(
                                  onPressed: _toggleView,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: kIsWeb ? 15.h : 8.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    backgroundColor: Theme.of(context)
                                                .brightness ==
                                            Brightness.light
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.7),
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                        ),
                                  ),
                                  child: Text(
                                      isSignInView ? 'Sign up' : 'Sign in'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
