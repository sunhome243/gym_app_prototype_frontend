import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'select_user_type_screen.dart';
import 'member_home_screen.dart';
import 'trainer_home_screen.dart';

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
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
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
          // Background gradients
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
            child: Stack(
              children: [
                // Content Box
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.28,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        // Login box
                        Hero(
                          tag: 'content_box',
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: _buildLoginBox(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Sign up button
                        _buildSignUpButton(),
                        SizedBox(height: size.height * 0.16),
                      ],
                    ),
                  ),
                ),
                // Logo
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildLogo(),
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
          child: Text(
            'FitSync',
            style: GoogleFonts.pacifico(
              fontSize: 48,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF333333),
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
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
            ],
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Sign Up',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF007AFF),
              ),
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