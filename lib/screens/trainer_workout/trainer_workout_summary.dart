import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/background.dart';
import '../../services/schemas.dart';

class TrainerWorkoutSummaryScreen extends StatelessWidget {
  final List<ExerciseSave> completedExercises;
  final VoidCallback onEndSession;
  final String memberName;

  const TrainerWorkoutSummaryScreen({
    super.key,
    required this.completedExercises,
    required this.onEndSession,
    required this.memberName,
  });

  Color get _themeColor => const Color(0xFF6EB6FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(
            height: MediaQuery.of(context).size.height,
            colors: [_themeColor, Colors.white],
            stops: const [0.0, 0.3],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            heroTag: 'background_top',
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildSessionComplete(),
                        const SizedBox(height: 24),
                        _buildWorkoutSummary(),
                        const SizedBox(height: 24),
                        _buildFeedbackPrompt(),
                        const SizedBox(height: 24),
                        _buildEndSessionButton(context),
                      ],
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        'Session Summary',
        style: GoogleFonts.lato(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSessionComplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Complete!',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _themeColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Great job training $memberName',
          style: GoogleFonts.lato(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, curve: Curves.easeInOut).slide(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
        duration: 600.ms,
        curve: Curves.easeInOut);
  }

  Widget _buildWorkoutSummary() {
    int totalExercises = completedExercises.length;
    int totalSets = completedExercises.fold(
        0, (sum, exercise) => sum + exercise.sets.length);
    int totalReps = completedExercises.fold(
        0,
        (sum, exercise) =>
            sum + exercise.sets.fold(0, (setSum, set) => setSum + set.reps));

    return CustomCard(
      title: 'Session Overview',
      titleColor: Colors.black,
      children: [
        _buildSummaryItem(
            Icons.fitness_center, 'Exercises', totalExercises.toString()),
        _buildSummaryItem(Icons.repeat, 'Total Sets', totalSets.toString()),
        _buildSummaryItem(Icons.show_chart, 'Total Reps', totalReps.toString()),
      ],
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 300.ms, curve: Curves.easeInOut)
        .slide(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
            duration: 800.ms,
            delay: 300.ms,
            curve: Curves.easeInOut);
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: _themeColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _themeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackPrompt() {
    return CustomCard(
      title: 'Feedback',
      titleColor: Colors.black,
      children: [
        Text(
          'Consider providing feedback to $memberName on their performance and areas for improvement.',
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement feedback functionality
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _themeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Provide Feedback',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 600.ms, curve: Curves.easeInOut)
        .slide(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
            duration: 800.ms,
            delay: 600.ms,
            curve: Curves.easeInOut);
  }

  Widget _buildEndSessionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onEndSession();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _themeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 3,
        ),
        child: Text(
          'End Session',
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms, delay: 900.ms, curve: Curves.easeInOut)
        .slide(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
            duration: 800.ms,
            delay: 900.ms,
            curve: Curves.easeInOut);
  }
}
