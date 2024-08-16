import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/background.dart';
import '../services/api_services.dart';
import '../services/schemas.dart';
import 'add_workout_screen.dart';

class ReviewSessionPlanScreen extends StatefulWidget {
  final List<WorkoutInfo> sessionPlan;
  final int workoutType;
  final ApiService apiService;
  final int currentWorkoutIndex;
  final List<ExerciseSave> completedExercises;

  const ReviewSessionPlanScreen({
    super.key,
    required this.sessionPlan,
    required this.workoutType,
    required this.apiService,
    required this.currentWorkoutIndex,
    required this.completedExercises,
  });

  @override
  _ReviewSessionPlanScreenState createState() => _ReviewSessionPlanScreenState();
}

class _ReviewSessionPlanScreenState extends State<ReviewSessionPlanScreen> {
  late List<WorkoutInfo> _sessionPlan;
  bool _isLoading = false;
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
  void initState() {
    super.initState();
    _sessionPlan = List.from(widget.sessionPlan);
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
                _buildAppBar(),
                Expanded(
                  child: _buildSessionPlanList(),
                ),
                _buildBottomControls(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator(color: _themeColor)),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          const CustomBackButton(),
          const SizedBox(width: 8),
          Text(
            'Review Session Plan',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _navigateToAddWorkout,
            tooltip: 'Add workout',
          ),
        ],
      ),
    );
  }

  Widget _buildSessionPlanList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessionPlan.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final WorkoutInfo item = _sessionPlan.removeAt(oldIndex);
          _sessionPlan.insert(newIndex, item);
        });
        HapticFeedback.mediumImpact();
      },
      itemBuilder: (context, index) {
        final workout = _sessionPlan[index];
        return _buildWorkoutItem(workout, index);
      },
    );
  }

  Widget _buildWorkoutItem(WorkoutInfo workout, int index) {
    final isCurrent = index == widget.currentWorkoutIndex;
    final isCompleted = index < widget.currentWorkoutIndex;
    final completedExercise = widget.completedExercises.firstWhere(
      (exercise) => exercise.workout_key == workout.workout_key,
      orElse: () => ExerciseSave(workout_key: workout.workout_key, sets: []),
    );

    return Dismissible(
      key: ValueKey(workout.workout_key),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeWorkout(workout),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _navigateToWorkout(index),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildWorkoutStatusIcon(isCurrent, isCompleted, completedExercise),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.workout_name,
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            workout.workout_part,
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.drag_handle, color: Colors.grey[400]),
                  ],
                ),
              ),
              _buildWorkoutProgress(workout, completedExercise),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutStatusIcon(bool isCurrent, bool isCompleted, ExerciseSave completedExercise) {
    if (isCurrent) {
      return Icon(Icons.play_arrow, color: _themeColor, size: 24);
    } else if (isCompleted && completedExercise.sets.length == _sessionPlan[widget.currentWorkoutIndex].workoutSets.length) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 24);
    } else {
      return const Icon(Icons.circle_outlined, color: Colors.grey, size: 24);
    }
  }

  Widget _buildWorkoutProgress(WorkoutInfo workout, ExerciseSave completedExercise) {
    final completedSets = completedExercise.sets.length;
    final totalSets = workout.workoutSets.length;
    final progress = totalSets > 0 ? (completedSets / totalSets) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Progress: $completedSets / $totalSets sets',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(_themeColor),
          minHeight: 6,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: _isSaving ? null : _saveAndReturn,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _isSaving ? Colors.grey : _themeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isSaving
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Text(
                  'Save and Return',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  void _navigateToWorkout(int index) {
    Navigator.pop(context, index);
  }

  void _navigateToAddWorkout() async {
    setState(() => _isLoading = true);
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddWorkoutScreen(
            apiService: widget.apiService,
            initialSessionPlan: _sessionPlan,
            workoutType: widget.workoutType,
          ),
        ),
      );
      if (result != null && result is List<WorkoutInfo>) {
        setState(() {
          _sessionPlan = result;
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load workouts: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeWorkout(WorkoutInfo workout) {
    setState(() {
      _sessionPlan.removeWhere((item) => item.workout_key == workout.workout_key);
    });
    HapticFeedback.lightImpact();
  }

  void _saveAndReturn() async {
    setState(() => _isSaving = true);
    // Here you might want to add any save logic, e.g., API calls
    await Future.delayed(const Duration(milliseconds: 500)); // Simulating a save operation
    setState(() => _isSaving = false);
    Navigator.pop(context, _sessionPlan);
  }
}