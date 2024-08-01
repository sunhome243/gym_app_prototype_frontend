import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_up_screen.dart';
import '../widgets/custom_back_button.dart';

class SelectUserTypeScreen extends StatelessWidget {
  const SelectUserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradients (same as login screen)
          Positioned(
            right: -MediaQuery.of(context).size.width * 1.3,
            bottom: -MediaQuery.of(context).size.height * 1.4,
            child: Hero(
              tag: 'background_bottom',
              child: Container(
                width: MediaQuery.of(context).size.width * 3,
                height: MediaQuery.of(context).size.height * 3,
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
          Positioned(
            left: -MediaQuery.of(context).size.width * 1.3,
            top: -MediaQuery.of(context).size.height * 1.4,
            child: Hero(
              tag: 'background_top',
              child: Container(
                width: MediaQuery.of(context).size.width * 3,
                height: MediaQuery.of(context).size.height * 3,
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
                    SafeArea(
            child: Stack(
              children: [
                // Logo
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildLogo(),
                  ),
                ),

                // Content Box
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.28,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Center(
                      child: _buildContent(context),
                    ),
                  ),
                ),

                // CustomBackButton (unchanged)
                const Positioned(
                  top: 16,
                  left: 16,
                  child: CustomBackButton(),
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
        const SizedBox(height: 12),
        Text(
          'Choose Your Fitness Path',
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Hero(
      tag: 'content_box',
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'I am a...',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildUserTypeCard(
                context,
                'Trainer',
                'Guide and motivate others',
                const Color(0xFF007AFF),
                Icons.fitness_center,
              ),
              const SizedBox(height: 24),
              _buildUserTypeCard(
                context,
                'Member',
                'Achieve your fitness goals',
                const Color(0xFF4CD964),
                Icons.directions_run,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(
      BuildContext context,
      String title,
      String description,
      Color color,
      IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  SignUpScreen(userType: title),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }
}