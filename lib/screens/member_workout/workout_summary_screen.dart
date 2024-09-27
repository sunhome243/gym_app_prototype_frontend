import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/background.dart';
import '../../services/schemas.dart';
import '../../services/api_services.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final List<ExerciseSave> completedExercises;
  final int workoutType;
  final SessionIDMap sessionIDMap;
  final ApiService apiService;
  final VoidCallback onEndSession;
  final Function refreshRecentSessions;

  const WorkoutSummaryScreen({
    super.key,
    required this.completedExercises,
    required this.workoutType,
    required this.sessionIDMap,
    required this.apiService,
    required this.onEndSession,
    required this.refreshRecentSessions,
  });

  @override
  _WorkoutSummaryScreenState createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  bool _isSaving = false;

  Color get _themeColor {
    switch (widget.workoutType) {
      case 1:
        return const Color(0xFF00CED1); // AI
      case 2:
        return const Color(0xFFF39C12); // Quest
      case 3:
        return const Color(0xFF6F42C1); // Custom
      default:
        return Colors.blue;
    }
  }

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
                        _buildCongratulations(),
                        const SizedBox(height: 24),
                        _buildWorkoutSummary(),
                        const SizedBox(height: 24),
                        _buildMotivationalQuote(),
                        const SizedBox(height: 24),
                        _buildEndSessionButton(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        'Workout Summary',
        style: GoogleFonts.lato(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCongratulations() {
    return Text(
      'Congratulations!',
      style: GoogleFonts.lato(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _themeColor,
      ),
    ).animate().fadeIn(duration: 600.ms, curve: Curves.easeInOut).slide(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
        duration: 600.ms,
        curve: Curves.easeInOut);
  }

  Widget _buildWorkoutSummary() {
    int totalExercises = widget.completedExercises.length;
    int totalSets = widget.completedExercises
        .fold(0, (sum, exercise) => sum + exercise.sets.length);
    int totalReps = widget.completedExercises.fold(
        0,
        (sum, exercise) =>
            sum + exercise.sets.fold(0, (setSum, set) => setSum + set.reps));

    return CustomCard(
      title: 'Your Achievements',
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

  Widget _buildMotivationalQuote() {
    const String quote = "The only bad workout is the one that didn't happen.";
    const String author = "Unknown";

    return CustomCard(
      title: 'Motivation',
      titleColor: Colors.black,
      children: [
        Text(
          '"$quote"',
          style: GoogleFonts.lato(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "- $author",
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
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
        onPressed: _isSaving ? null : _saveSession,
        style: ElevatedButton.styleFrom(
          backgroundColor: _themeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 3,
        ),
        child: _isSaving
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
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

  Future<void> _saveSession() async {
    setState(() => _isSaving = true);
    try {
      final sessionSave = SessionSave(
        session_id: widget.sessionIDMap.session_id,
        exercises: widget.completedExercises,
      );
      await widget.apiService.saveSession(sessionSave);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Session saved successfully!'),
              backgroundColor: Colors.green),
        );
        HapticFeedback.mediumImpact();
        await widget.refreshRecentSessions(); // 최근 세션 새로고침
        widget.onEndSession();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save session: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
