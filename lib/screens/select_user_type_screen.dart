import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_up_screen.dart';
import '../widgets/custom_back_button.dart';

class SelectUserTypeScreen extends StatefulWidget {
  const SelectUserTypeScreen({super.key});

  @override
  _SelectUserTypeScreenState createState() => _SelectUserTypeScreenState();
}

class _SelectUserTypeScreenState extends State<SelectUserTypeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background ellipses
          Positioned(
            right: -size.width * 1.5,
            bottom: -size.height * 1,
            child: Hero(
              tag: 'background_bottom',
              child: Container(
                width: size.width * 4,
                height: size.width * 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFF4CD964), Colors.white.withOpacity(0)],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -size.width * 1.5,
            top: -size.height * 0.9,
            child: Hero(
              tag: 'background_top',
              child: Container(
                width: size.width * 4,
                height: size.width * 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFF6EB6FF), Colors.white.withOpacity(0)],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 30),
                      _buildContent(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomBackButton(),
          Spacer(),
          SizedBox(width: 40), // To balance the back button
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
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
        const SizedBox(height: 8),
        Text(
          'Choose Your Fitness Path',
          style: GoogleFonts.lato(
            fontSize: 16,
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
        ),
      ),
    );
  }

Widget _buildUserTypeCard(BuildContext context, String title, String description, Color color, IconData icon) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => SignUpScreen(userType: title),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
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
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}