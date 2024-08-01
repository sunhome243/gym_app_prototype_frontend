import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/services/auth_service.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_back_button.dart';

class SignUpScreen extends StatefulWidget {
  final String userType;
  final Alignment backgroundGradientAlignment;
  final double backgroundGradientSize;

  const SignUpScreen({
    super.key,
    required this.userType,
    this.backgroundGradientAlignment = Alignment.center,
    this.backgroundGradientSize = 1,
  });

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final AuthService _auth;

  @override
  void initState() {
    super.initState();
    _auth = Provider.of<AuthService>(context, listen: false);
  }

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        await _auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          userType: widget.userType,
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
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
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Hero(
              tag: widget.userType == 'Trainer'
                  ? 'background_top'
                  : 'background_bottom',
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: widget.backgroundGradientAlignment,
                    radius: widget.backgroundGradientSize,
                    colors: [
                      widget.userType == 'Trainer'
                          ? const Color(0xFF6EB6FF)
                          : const Color(0xFF4CD964),
                      Colors.white,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 16, left: 16),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CustomBackButton(),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40),
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
                          const SizedBox(height: 12),
                          Text(
                            'Sign Up as ${widget.userType}',
                            style: GoogleFonts.lato(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          Hero(
                            tag: 'content_box',
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
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
                                  padding: const EdgeInsets.all(24.0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildInputField(
                                          controller: _firstNameController,
                                          label: 'First Name',
                                          icon: Icons.person_outline,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInputField(
                                          controller: _lastNameController,
                                          label: 'Last Name',
                                          icon: Icons.person_outline,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInputField(
                                          controller: _emailController,
                                          label: 'Email',
                                          icon: Icons.email_outlined,
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInputField(
                                          controller: _passwordController,
                                          label: 'Password',
                                          icon: Icons.lock_outline,
                                          isPassword: true,
                                        ),
                                        const SizedBox(height: 24),
                                        if (_errorMessage.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 16),
                                            child: Text(
                                              _errorMessage,
                                              style: GoogleFonts.lato(
                                                color: Colors.red,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ElevatedButton(
                                          onPressed: _isLoading ? null : _signUp,
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            backgroundColor: widget.userType == 'Trainer'
                                                ? const Color(0xFF6EB6FF)
                                                : const Color(0xFF4CD964),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Text(
                                                  'Sign Up',
                                                  style: GoogleFonts.lato(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: Colors.grey[600]),
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: widget.userType == 'Trainer'
                ? const Color(0xFF6EB6FF)
                : const Color(0xFF4CD964),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      style: GoogleFonts.lato(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Email' && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        if (label == 'Password' && value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}