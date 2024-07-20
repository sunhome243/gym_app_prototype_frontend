import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'select_user_type_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(color: const Color(0xFFF5F7FA)),

          // Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),  // Adjusted top padding
                          child: Column(
                            children: [
                              Text(
                                'FitSync',
                                style: GoogleFonts.pacifico(
                                  fontSize: 29,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),  // Reduced space between logo and greeting
                              Text(
                                'Hi!\nNice to Meet You! 👋',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildLoginBox(context),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBox(BuildContext context) {
    return Container(
      width: 282,
      padding: const EdgeInsets.all(30),
      decoration: ShapeDecoration(
        color: const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFC6C6C6)),
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Log in',
            style: GoogleFonts.lato(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField('Email'),
          const SizedBox(height: 10),
          _buildTextField('Password', isPassword: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement login functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              minimumSize: const Size(182, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
            child: Text(
              'Log in',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SelectUserTypeScreen()),
              );
            },
            child: Text(
              'Create Account',
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hintText, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.lato(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFBABABA),
        ),
        filled: true,
        fillColor: const Color(0xFFE2E2E2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 13,
        ),
      ),
    );
  }
}