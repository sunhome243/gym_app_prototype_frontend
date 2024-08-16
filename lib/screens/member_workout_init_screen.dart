import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_inkwell.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/custom_card.dart';
import '../services/api_services.dart';
import 'member_custom_workout_init.dart';

// 페이드 애니메이션을 위한 PageRouteBuilder
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// 슬라이드 애니메이션을 위한 PageRouteBuilder
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class MemberWorkoutInitScreen extends StatefulWidget {
  final ApiService apiService;

  const MemberWorkoutInitScreen({super.key, required this.apiService});

  @override
  _MemberWorkoutInitScreenState createState() => _MemberWorkoutInitScreenState();
}

class _MemberWorkoutInitScreenState extends State<MemberWorkoutInitScreen> {
  Color _backgroundColor = const Color(0xFF3CD687);
  String _selectedSession = '';
  int _selectedWorkoutType = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradients
          Positioned(
            right: -size.width * 1.5,
            bottom: -size.height * 1.5,
            child: SizedBox(
              width: size.width * 4,
              height: size.height * 4,
              child: Hero(
                tag: 'background',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_backgroundColor, Colors.white.withOpacity(0)],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      const CustomBackButton(),
                      const SizedBox(width: 16),
                      Text(
                        'Start Your Session',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomCard(
                              title: 'Select Session Type',
                              titleColor: Colors.black,
                              children: [
                                _buildSessionOption(
                                  'AI Session with FitThink AI',
                                  Icons.lightbulb_outline,
                                  const Color(0xFF00CED1),
                                  1,
                                ),
                                _buildSessionOption(
                                  'Quest Session by Trainer',
                                  Icons.edit_outlined,
                                  const Color(0xFFF39C12),
                                  2,
                                ),
                                _buildSessionOption(
                                  'Custom Session',
                                  Icons.dashboard_outlined,
                                  const Color(0xFF6F42C1),
                                  3,
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            AnimatedInkWell(
                              onTap: _selectedSession.isNotEmpty
                                  ? _navigateToSession
                                  : null,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: _selectedSession.isNotEmpty
                                      ? const Color(0xFF4CD964)
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Next',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildSessionOption(String title, IconData icon, Color color, int workoutType) {
    return AnimatedInkWell(
      onTap: () {
        setState(() {
          _selectedSession = title;
          _backgroundColor = color;
          _selectedWorkoutType = workoutType;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _selectedSession == title
              ? color.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _selectedSession == title ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (_selectedSession == title)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  void _navigateToSession() {
    switch (_selectedSession) {
      case 'Custom Session':
        Navigator.push(
          context,
          FadePageRoute(
            page: CustomWorkoutInitScreen(
              apiService: widget.apiService,
              workoutType: _selectedWorkoutType,
            ),
          ),
        );
        break;
      case 'AI Session with FitThink AI':
        // TODO: AI Session 화면으로 이동 구현
        print('Navigating to AI Session');
        break;
      case 'Quest Session by Trainer':
        // TODO: Quest Session 화면으로 이동 구현
        print('Navigating to Quest Session');
        break;
      default:
        print('Navigating to $_selectedSession');
    }
  }
}