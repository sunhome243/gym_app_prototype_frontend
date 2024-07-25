import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/services/auth_service.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  final String userType;

  const SignUpScreen({super.key, required this.userType});

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
      appBar: AppBar(
        title: Text(
          'Sign Up as ${widget.userType}',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: GoogleFonts.lato(),
              ),
              style: GoogleFonts.lato(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: GoogleFonts.lato(),
              ),
              style: GoogleFonts.lato(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: GoogleFonts.lato(),
              ),
              style: GoogleFonts.lato(),
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: GoogleFonts.lato(),
              ),
              style: GoogleFonts.lato(),
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters long';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      'Sign Up',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: GoogleFonts.lato(
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
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