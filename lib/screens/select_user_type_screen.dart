import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_up_screen.dart';
import '../widgets/custom_back_button.dart';

class SelectUserTypeScreen extends StatelessWidget {
  const SelectUserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradients (same as before)
          Positioned(
            right: -size.width * 1.3,
            bottom: -size.height * 1.4,
            child: SizedBox(
              width: size.width * 3,
              height: size.height * 3,
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
            left: -size.width * 1.3,
            top: -size.height * 1.4,
            child: SizedBox(
              width: size.width * 3,
              height: size.height * 3,
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(height: size.height * 0.0625), // 1/4 of the upper quarter
                      _buildLogo(),
                      SizedBox(height: size.height * 0.1875), // 3/4 of the upper quarter
                    ],
                  ),
                ),
                Hero(
                  tag: 'contentBox',
                  child: Material(
                    color: Colors.transparent,
                    child: _buildContent(context),
                  ),
                ),
                const Expanded(child: SizedBox()), // To balance the layout
              ],
            ),
          ),
          
          // Add CustomBackButton
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: const CustomBackButton(),
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
    return Container(
      width: double.infinity,
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
          const SizedBox(height: 20),
          _buildUserTypeCard(
            context,
            'Trainer',
            'Guide and motivate others',
            const Color(0xFF007AFF),
            Icons.fitness_center,
          ),
          const SizedBox(height: 16),
          _buildUserTypeCard(
            context,
            'Member',
            'Achieve your fitness goals',
            const Color(0xFF4CD964),
            Icons.directions_run,
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeCard(BuildContext context, String title,
      String description, Color color, IconData icon) {
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
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
              Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
