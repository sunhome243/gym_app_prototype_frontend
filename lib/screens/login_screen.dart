import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'select_user_type_screen.dart';
import 'member_home_screen.dart';
import 'trainer_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthService _auth;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _auth = Provider.of<AuthService>(context, listen: false);
  }

String _getErrorMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'Oops! No account with that email. Double-check your email or create a new account!';
    case 'wrong-password':
      return 'Uh-oh! That password doesn’t match. Give it another shot!';
    case 'invalid-email':
      return 'Hmm, that doesn’t look like a valid email. Can you check it again?';
    case 'user-disabled':
      return 'This account has been put on pause. Reach out to support for help!';
    case 'too-many-requests':
      return 'Whoa, slow down! Too many attempts. Please wait a bit before trying again.';
    case 'operation-not-allowed':
      return 'Email sign-in isn’t switched on right now. Contact support if you need assistance.';
    case 'network-request-failed':
      return 'Yikes! Network hiccup. Check your internet and try again.';
    default:
      return 'Something went wrong. Give it another try in a bit!';
  }
}

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        await _auth.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Map<String, dynamic> userInfo = await _auth.getCurrentUserInfo();
        String userRole = userInfo['role'];
        Widget homeScreen;
        if (userRole == 'trainer') {
          homeScreen = const TrainerHomeScreen();
        } else if (userRole == 'member') {
          homeScreen = const MemberHomeScreen();
        } else {
          throw Exception('Invalid user role');
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => homeScreen),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _getErrorMessage(e);
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradients (그대로 유지)
          Positioned(
            right: -size.width * 1.5,
            bottom: -size.height * 2,
            child: SizedBox(
              width: size.width * 4,
              height: size.height * 4,
              child: Hero(
                tag: 'background_bottom',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4CD964),
                        Colors.white.withOpacity(0)
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -size.width * 1.5,
            top: -size.height * 2,
            child: SizedBox(
              width: size.width * 4,
              height: size.height * 4,
              child: Hero(
                tag: 'background_top',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6EB6FF),
                        Colors.white.withOpacity(0)
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.01), // 상단 여백 조정
                _buildLogo(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.00), // 로고와 컨텐츠 박스 사이 간격 조정
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Hero(
                              tag: 'contentBox',
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 400),
                                  child: _buildLoginBox(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 9),
                          _buildSignUpButton(),
                          SizedBox(height: size.height * 0.05), // 하단 여백 추가
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: 'logo',
          child: Material(
            color: Colors.transparent,
            child: Text(
              'FitSync',
              style: GoogleFonts.pacifico(
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome Back 🔥',
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildTextField(_emailController, 'Email', Icons.email),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, 'Password', Icons.lock,
                    isPassword: true),
                const SizedBox(height: 24),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Log In',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      style: GoogleFonts.lato(fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SelectUserTypeScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          child: Text(
            'Sign Up',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF007AFF),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
